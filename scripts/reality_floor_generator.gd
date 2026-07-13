extends Node3D
class_name RealityFloorGenerator

const BASE_ROOM_COUNT := 4
const WORLD_LENGTH_SCALE := 5.0
const LOT_SPACING := 9.4 * WORLD_LENGTH_SCALE
const LOT_WIDTH := 7.4
const LOT_DEPTH := 6.8
const STREET_WIDTH := 14.0
const SUNLIT_CROSSROAD_OPENING := STREET_WIDTH + 2.0
const SUNLIT_EDGE_WALL_HEIGHT := 5.9
const SUNLIT_EDGE_WALL_THICKNESS := 0.68
const MIN_MAP_WIDTH := 34.0
const MIN_MAP_LENGTH := 46.0 * WORLD_LENGTH_SCALE
const MAP_END_MARGIN := 12.0 * WORLD_LENGTH_SCALE
const WALL_HEIGHT := 3.4
const AIR_WALL_HEIGHT := 6.0
const AIR_WALL_THICKNESS := 0.5
const DISTRICT_STYLES := ["sunlit_brick_street", "night_white_blocks", "overgrown_gallery"]
const DISTRICT_REFERENCE_TEXTURES := {
	"sunlit_brick_street": "res://assets/generated/world/reference_districts/sunlit_brick_street.png",
	"night_white_blocks": "res://assets/generated/world/reference_districts/night_white_blocks.png",
	"overgrown_gallery": "res://assets/generated/world/reference_districts/overgrown_gallery.png",
}
const MOOD_TEXTURE_PATHS := [
	"res://assets/generated/1/IMG_4485.PNG",
	"res://assets/generated/1/IMG_4744.PNG",
	"res://assets/generated/1/IMG_4750.PNG",
	"res://assets/generated/1/IMG_4835.PNG",
	"res://assets/generated/1/IMG_4834.PNG",
	"res://assets/generated/1/IMG_4711.PNG",
	"res://assets/generated/1/IMG_4461.PNG",
	"res://assets/generated/1/IMG_4460.PNG",
]

var built_floor: int = 0
var room_count: int = 0
var ordinary_npc_count: int = 0
var useful_item_count: int = 0
var map_width: float = MIN_MAP_WIDTH
var map_length: float = MIN_MAP_LENGTH
var district_style := DISTRICT_STYLES[0]
var _actors: Array[Area3D] = []
var _items: Array[Area3D] = []
var _environment: WorldEnvironment


static func room_count_for_floor(floor_number: int) -> int:
	var normalized := maxi(1, floor_number) - 1
	return BASE_ROOM_COUNT + normalized * 2 + int(normalized / 2)


static func npc_count_for_floor(floor_number: int) -> int:
	return maxi(2, 6 - maxi(1, floor_number))


static func district_style_for_floor(floor_number: int) -> String:
	return DISTRICT_STYLES[posmod(maxi(1, floor_number) - 1, DISTRICT_STYLES.size())]


func rebuild(floor_number: int, palette: Dictionary, actor_textures: Dictionary) -> void:
	_clear_floor()
	built_floor = clampi(floor_number, 1, 5)
	district_style = district_style_for_floor(built_floor)
	room_count = room_count_for_floor(built_floor)
	ordinary_npc_count = npc_count_for_floor(built_floor)
	useful_item_count = 0
	var lot_rows := int(ceil(float(room_count) / 2.0))
	map_width = MIN_MAP_WIDTH + float(built_floor - 1) * 1.5
	map_length = maxf(MIN_MAP_LENGTH, float(lot_rows) * LOT_SPACING + MAP_END_MARGIN * 2.0)
	set_meta("built_floor", built_floor)
	set_meta("room_count", room_count)
	set_meta("ordinary_npc_count", ordinary_npc_count)
	set_meta("layout_mode", "shared_street")
	set_meta("map_width", map_width)
	set_meta("map_length", map_length)
	set_meta("world_length_scale", WORLD_LENGTH_SCALE)
	set_meta("air_wall_count", 4)
	set_meta("district_style", district_style)

	_build_environment(palette)
	_build_architecture(palette)
	_build_actors(palette, actor_textures)
	set_meta("useful_item_count", useful_item_count)


func get_interactable_actors() -> Array[Area3D]:
	var live_actors: Array[Area3D] = []
	for actor in _actors:
		if is_instance_valid(actor):
			live_actors.append(actor)
	return live_actors


func get_interactable_items() -> Array[Area3D]:
	var live_items: Array[Area3D] = []
	for item in _items:
		if is_instance_valid(item) and item.visible and not bool(item.get_meta("collected", false)):
			live_items.append(item)
	return live_items


func sync_collected_items(collected_ids: Array[String]) -> void:
	for item in _items:
		if not is_instance_valid(item):
			continue
		var collected := str(item.get_meta("item_id", "")) in collected_ids
		item.set_meta("collected", collected)
		item.visible = not collected
		item.monitoring = not collected
		item.monitorable = not collected


func start_position() -> Vector3:
	return Vector3(0.0, 0.08, map_length * 0.5 - 9.0)


func contains_playable_position(position: Vector3, inset: float = 0.0) -> bool:
	var half_width := maxf(0.5, map_width * 0.5 - inset)
	var half_length := maxf(0.5, map_length * 0.5 - inset)
	return absf(position.x) <= half_width and absf(position.z) <= half_length


func clamp_to_playable_position(position: Vector3, inset: float = 1.2) -> Vector3:
	var half_width := maxf(0.5, map_width * 0.5 - inset)
	var half_length := maxf(0.5, map_length * 0.5 - inset)
	return Vector3(
		clampf(position.x, -half_width, half_width),
		maxf(0.08, position.y),
		clampf(position.z, -half_length, half_length)
	)


func apply_palette(palette: Dictionary) -> void:
	if _environment != null and _environment.environment != null:
		var environment := _environment.environment
		environment.background_color = _style_background_color(palette)
		environment.ambient_light_color = _style_ambient_color(palette)
		environment.fog_light_color = _style_fog_color(palette)
	for mesh_node in find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh_node as MeshInstance3D
		if mesh_instance == null or not mesh_instance.has_meta("theme_role"):
			continue
		var material := mesh_instance.material_override as StandardMaterial3D
		if material != null:
			material.albedo_color = _role_color(str(mesh_instance.get_meta("theme_role")), palette)
	for actor in get_interactable_actors():
		var sprite := actor.get_node_or_null("Billboard") as Sprite3D
		if sprite == null:
			continue
		if str(actor.get_meta("actor_type", "npc")) == "merchant":
			sprite.modulate = _color(palette, "surface")
		else:
			var tint_index := int(actor.get_meta("tint_index", 0))
			sprite.modulate = Color.WHITE.lerp(_color(palette, "muted"), 0.08 + tint_index * 0.04)


func _clear_floor() -> void:
	_actors.clear()
	_items.clear()
	_environment = null
	for child in get_children():
		remove_child(child)
		child.free()


func _build_environment(palette: Dictionary) -> void:
	_environment = WorldEnvironment.new()
	_environment.name = "RealityWorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = _style_background_color(palette)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = _style_ambient_color(palette)
	environment.ambient_light_energy = 0.22 if district_style == "night_white_blocks" else (0.58 if district_style == "overgrown_gallery" else 0.78)
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.fog_enabled = true
	environment.fog_light_color = _style_fog_color(palette)
	environment.fog_light_energy = 0.28 if district_style == "night_white_blocks" else 0.52
	environment.fog_density = (0.012 if district_style == "night_white_blocks" else 0.005) + built_floor * 0.0012
	environment.fog_height = 1.1
	environment.fog_height_density = 0.16
	_environment.environment = environment
	add_child(_environment)

	var key_light := DirectionalLight3D.new()
	key_light.name = "RealityKeyLight"
	key_light.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	key_light.light_color = Color("DCE8E1") if district_style == "night_white_blocks" else Color("FFF3D3")
	key_light.light_energy = 0.46 if district_style == "night_white_blocks" else (1.65 if district_style == "overgrown_gallery" else 1.32)
	key_light.shadow_enabled = true
	add_child(key_light)


func _build_architecture(palette: Dictionary) -> void:
	var architecture := Node3D.new()
	architecture.name = "Architecture"
	add_child(architecture)
	var ground_role := "grass" if district_style == "night_white_blocks" else ("gallery_floor" if district_style == "overgrown_gallery" else "sunlit_paving")
	var street_ground := _add_box(
		architecture,
		"StreetGround",
		Vector3(map_width, 0.20, map_length),
		Vector3(0.0, -0.10, 0.0),
		ground_role,
		palette,
		true
	)
	street_ground.set_meta("continuous_ground", true)
	match district_style:
		"night_white_blocks":
			_build_night_white_blocks(architecture, palette)
		"overgrown_gallery":
			_build_overgrown_gallery(architecture, palette)
		_:
			_build_sunlit_brick_street(architecture, palette)

	_build_air_walls(architecture)


func _build_sunlit_brick_street(parent: Node3D, palette: Dictionary) -> void:
	_add_box(parent, "MainRoad", Vector3(STREET_WIDTH, 0.025, map_length - 1.0), Vector3(0.0, 0.008, 0.0), "road", palette, false)
	var crossroad := _add_box(parent, "CrossRoad", Vector3(map_width - 1.0, 0.032, STREET_WIDTH), Vector3(0.0, 0.064, 0.0), "road", palette, false)
	crossroad.set_meta("crossroad_surface", true)
	crossroad.set_meta("crossroad_width", STREET_WIDTH)
	set_meta("crossroad_opening_span", SUNLIT_CROSSROAD_OPENING)
	set_meta("crossroad_layout", "open_center")
	var sidewalk_width := 3.15
	var edge_segment_length := (map_length - SUNLIT_CROSSROAD_OPENING) * 0.5
	for side in [-1.0, 1.0]:
		_add_box(parent, "Sidewalk%s" % ("West" if side < 0.0 else "East"), Vector3(sidewalk_width, 0.055, map_length - 1.0), Vector3(side * (STREET_WIDTH * 0.5 + sidewalk_width * 0.5), 0.018, 0.0), "sunlit_paving", palette, false)
		for direction in [-1.0, 1.0]:
			var curb_suffix := "%s%s" % ["West" if side < 0.0 else "East", "North" if direction < 0.0 else "South"]
			var center_z: float = direction * (SUNLIT_CROSSROAD_OPENING * 0.5 + edge_segment_length * 0.5)
			_add_box(parent, "Curb%s" % curb_suffix, Vector3(0.16, 0.10, edge_segment_length), Vector3(side * (STREET_WIDTH * 0.5 + 0.08), 0.048, center_z), "accent", palette, false)
	_build_sunlit_edge_walls(parent, palette)
	_build_road_markings(parent, palette)
	_build_crossroad_markings(parent, palette)
	for stripe_index in 5:
		_add_box(parent, "Crosswalk%02d" % stripe_index, Vector3(1.25, 0.024, 4.2), Vector3(-3.0 + float(stripe_index) * 1.5, 0.032, map_length * 0.5 - 6.4), "crosswalk", palette, false)
	var lot_rows := int(ceil(float(room_count) / 2.0))
	for room_index in room_count:
		var row := int(room_index / 2)
		var side := -1.0 if room_index % 2 == 0 else 1.0
		var center_z := (float(lot_rows - 1) * LOT_SPACING * 0.5) - float(row) * LOT_SPACING
		_build_sunlit_brick_room(parent, room_index, row, side, center_z, palette)
	_build_reference_portal(parent, str(DISTRICT_REFERENCE_TEXTURES[district_style]), palette)


func _build_sunlit_brick_room(parent: Node3D, room_index: int, row: int, side: float, center_z: float, palette: Dictionary) -> void:
	var room := _new_room(parent, room_index)
	var edge_wall_x := side * (map_width * 0.5 - SUNLIT_EDGE_WALL_THICKNESS)
	_add_box(room, "SidewalkInset", Vector3(3.1, 0.08, LOT_WIDTH + 1.2), Vector3(side * (STREET_WIDTH * 0.5 + 1.55), 0.045, center_z), "sunlit_paving", palette, false)
	if row % 2 == 1:
		_add_box(room, "BrickTurn", Vector3(3.35, 4.6, 0.52), Vector3(side * (STREET_WIDTH * 0.5 + 1.75), 2.3, center_z + LOT_WIDTH * 0.53), "brick_dark", palette, true)
	if row % 2 == 0:
		_build_street_lamp(room, Vector3(side * (STREET_WIDTH * 0.5 - 0.65), 0.0, center_z - 2.6), palette, true)
	if room_index % 4 == 1:
		_build_mood_panel(room, room_index, Vector3(edge_wall_x - side * 0.40, 2.15, center_z), side, palette)
	_place_room_reward(room, room_index, Vector3(side * (STREET_WIDTH * 0.5 + 1.45), 0.0, center_z), palette)


func _build_sunlit_edge_walls(parent: Node3D, palette: Dictionary) -> void:
	var segment_length := (map_length - SUNLIT_CROSSROAD_OPENING) * 0.5
	var edge_x := map_width * 0.5 - SUNLIT_EDGE_WALL_THICKNESS * 0.5
	for side in [-1.0, 1.0]:
		var side_name := "west" if side < 0.0 else "east"
		for direction in [-1.0, 1.0]:
			var section_name := "North" if direction < 0.0 else "South"
			var node_name := "BrickWall" if side < 0.0 and direction < 0.0 else "TerrainEdgeWall%s%s" % [side_name.capitalize(), section_name]
			var center_z: float = direction * (SUNLIT_CROSSROAD_OPENING * 0.5 + segment_length * 0.5)
			var wall := _add_box(
				parent,
				node_name,
				Vector3(SUNLIT_EDGE_WALL_THICKNESS, SUNLIT_EDGE_WALL_HEIGHT, segment_length),
				Vector3(side * edge_x, SUNLIT_EDGE_WALL_HEIGHT * 0.5, center_z),
				"brick",
				palette,
				true
			)
			wall.set_meta("terrain_edge_wall", true)
			wall.set_meta("edge_side", side_name)
			wall.set_meta("edge_section", section_name.to_lower())
			wall.set_meta("edge_length", segment_length)
			wall.set_meta("intersection_clearance", SUNLIT_CROSSROAD_OPENING)
			_add_box(
				parent,
				"TerrainEdgeCap%s%s" % [side_name.capitalize(), section_name],
				Vector3(SUNLIT_EDGE_WALL_THICKNESS + 0.14, 0.16, segment_length),
				Vector3(side * edge_x, SUNLIT_EDGE_WALL_HEIGHT + 0.08, center_z),
				"brick_light",
				palette,
				false
			)


func _build_crossroad_markings(parent: Node3D, palette: Dictionary) -> void:
	var dash_count := int(floor((map_width - 4.0) / 4.8))
	for dash_index in dash_count:
		var x := -map_width * 0.5 + 3.0 + float(dash_index) * 4.8
		if absf(x) < 2.0:
			continue
		_add_box(parent, "CrossroadStripe%02d" % dash_index, Vector3(2.1, 0.018, 0.14), Vector3(x, 0.088, 0.0), "accent", palette, false)


func _build_night_white_blocks(parent: Node3D, palette: Dictionary) -> void:
	_add_box(parent, "NightWalk", Vector3(4.8, 0.035, map_length - 1.2), Vector3(-2.35, 0.018, 0.0), "night_path", palette, false)
	var lot_rows := int(ceil(float(room_count) / 2.0))
	for room_index in room_count:
		var row := int(room_index / 2)
		var side := -1.0 if room_index % 2 == 0 else 1.0
		var center_z := (float(lot_rows - 1) * LOT_SPACING * 0.5) - float(row) * LOT_SPACING
		_build_night_house(parent, room_index, row, side, center_z, palette)
	_build_reference_portal(parent, str(DISTRICT_REFERENCE_TEXTURES[district_style]), palette)


func _build_night_house(parent: Node3D, room_index: int, row: int, side: float, center_z: float, palette: Dictionary) -> void:
	var room := _new_room(parent, room_index)
	var height := 4.5 + float((room_index + built_floor) % 3) * 0.8
	var depth := 5.4
	var center_x := side * (4.35 + depth * 0.5)
	_add_box(room, "WhiteHouse", Vector3(depth, height, LOT_WIDTH), Vector3(center_x, height * 0.5, center_z), "white_wall", palette, true)
	var face_x := center_x - side * (depth * 0.5 + 0.025)
	for window_index in 3:
		var window_y := 1.35 + float(window_index % 2) * 1.75
		var window_z := center_z - 2.0 + float(window_index) * 2.0
		_add_box(room, "Window%d" % window_index, Vector3(0.06, 0.92, 0.92), Vector3(face_x, window_y, window_z), "window", palette, false)
	if row % 2 == 0:
		_build_street_lamp(room, Vector3(-4.25, 0.0, center_z - 2.2), palette, false)
	if room_index % 4 == 2:
		_build_mood_panel(room, room_index, Vector3(face_x - side * 0.04, 2.4, center_z + 1.4), side, palette)
	_place_room_reward(room, room_index, Vector3(side * 3.65, 0.0, center_z), palette)


func _build_overgrown_gallery(parent: Node3D, palette: Dictionary) -> void:
	_add_box(parent, "GalleryWalk", Vector3(6.2, 0.05, map_length - 1.0), Vector3(0.0, 0.025, 0.0), "gallery_floor", palette, false)
	var lot_rows := int(ceil(float(room_count) / 2.0))
	for room_index in room_count:
		var row := int(room_index / 2)
		var side := -1.0 if room_index % 2 == 0 else 1.0
		var center_z := (float(lot_rows - 1) * LOT_SPACING * 0.5) - float(row) * LOT_SPACING
		_build_gallery_bay(parent, room_index, row, side, center_z, palette)
	_build_reference_portal(parent, str(DISTRICT_REFERENCE_TEXTURES[district_style]), palette)


func _build_gallery_bay(parent: Node3D, room_index: int, row: int, side: float, center_z: float, palette: Dictionary) -> void:
	var room := _new_room(parent, room_index)
	var bay_center_x := side * 5.15
	_add_box(room, "GalleryRoof", Vector3(5.1, 0.28, LOT_WIDTH + 1.3), Vector3(bay_center_x, 3.55, center_z), "white_wall", palette, true)
	if side < 0.0:
		_add_box(room, "GalleryCeilingSpan", Vector3(5.4, 0.24, LOT_WIDTH + 1.3), Vector3(0.0, 3.55, center_z), "white_wall", palette, true)
	_add_box(room, "OuterWall", Vector3(0.34, 3.55, LOT_WIDTH + 1.3), Vector3(side * 7.7, 1.78, center_z), "white_wall", palette, true)
	for column_index in 4:
		var column_z := center_z - 3.1 + float(column_index) * 2.05
		_add_box(room, "Column%d" % column_index, Vector3(0.52, 3.55, 0.52), Vector3(side * 2.75, 1.78, column_z), "white_wall", palette, true)
	for patch_index in 4:
		var patch_side := -1.0 if (room_index + patch_index) % 2 == 0 else 1.0
		var patch_pos := Vector3(patch_side * (0.85 + float(patch_index % 2) * 0.75), 0.0, center_z - 2.6 + float(patch_index) * 1.65)
		_build_grass_patch(room, patch_pos, room_index * 4 + patch_index, palette)
	if row % 2 == 1:
		_build_mood_panel(room, room_index, Vector3(side * 7.5, 2.0, center_z), side, palette)
	_place_room_reward(room, room_index, Vector3(side * 2.15, 0.0, center_z), palette)


func _new_room(parent: Node3D, room_index: int) -> Node3D:
	var room := Node3D.new()
	room.name = "Room%02d" % room_index
	room.set_meta("room_index", room_index)
	room.set_meta("street_lot", true)
	room.set_meta("district_style", district_style)
	parent.add_child(room)
	return room


func _place_room_reward(room: Node3D, room_index: int, position: Vector3, palette: Dictionary) -> void:
	if (room_index + built_floor) % 3 == 0:
		_build_useful_item(room, room_index, position, palette)
	elif (room_index + built_floor) % 4 == 0:
		_add_box(room, "EmptyPlinth", Vector3(0.72, 0.42, 0.72), position + Vector3(0.0, 0.21, 0.0), "wall_dark", palette, false)


func _build_street_lamp(parent: Node3D, position: Vector3, palette: Dictionary, daylight: bool) -> void:
	var lamp := Node3D.new()
	lamp.name = "StreetLamp"
	lamp.position = position
	parent.add_child(lamp)
	_add_box(lamp, "Pole", Vector3(0.12, 4.6, 0.12), Vector3(0.0, 2.3, 0.0), "lamp", palette, false)
	_add_box(lamp, "Head", Vector3(0.58, 0.18, 0.30), Vector3(0.0, 4.54, -0.12), "lamp_light", palette, false)
	if not daylight:
		var light := OmniLight3D.new()
		light.name = "WarmPool"
		light.position = Vector3(0.0, 4.2, 0.0)
		light.light_color = Color("FFB54A")
		light.light_energy = 2.4
		light.omni_range = 7.5
		light.shadow_enabled = false
		lamp.add_child(light)


func _build_mood_panel(parent: Node3D, room_index: int, position: Vector3, side: float, _palette: Dictionary) -> void:
	var texture_path: String = str(MOOD_TEXTURE_PATHS[posmod(room_index + built_floor * 2, MOOD_TEXTURE_PATHS.size())])
	var texture := _load_runtime_texture(texture_path)
	if texture == null:
		return
	var panel := MeshInstance3D.new()
	panel.name = "MemoryPanel%02d" % room_index
	var quad := QuadMesh.new()
	quad.size = Vector2(2.35, 2.35)
	panel.mesh = quad
	panel.position = position
	panel.rotation_degrees.y = -90.0 * side
	panel.set_meta("mood_texture", texture_path)
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission_enabled = true
	material.emission_texture = material.albedo_texture
	material.emission_energy_multiplier = 0.45
	panel.material_override = material
	parent.add_child(panel)


func _build_grass_patch(parent: Node3D, position: Vector3, seed_index: int, palette: Dictionary) -> void:
	var patch := Node3D.new()
	patch.name = "GrassPatch%02d" % seed_index
	patch.position = position
	parent.add_child(patch)
	for tuft_index in 30:
		var tuft := MeshInstance3D.new()
		tuft.name = "Blade%d" % tuft_index
		var blade_width := 0.07 + float((seed_index + tuft_index) % 4) * 0.018
		var blade_height := 0.30 + float((seed_index * 3 + tuft_index) % 8) * 0.055
		tuft.mesh = _grass_blade_mesh(blade_width, blade_height, -0.04 + float((seed_index + tuft_index) % 5) * 0.02)
		var angle := float(seed_index * 17 + tuft_index * 53) * 0.11
		var radius := 0.10 + float(tuft_index % 10) * 0.11
		tuft.position = Vector3(cos(angle) * radius, blade_height * 0.5, sin(angle) * radius)
		tuft.rotation_degrees = Vector3(0.0, rad_to_deg(angle) + float(tuft_index % 3) * 37.0, -9.0 + float((seed_index + tuft_index) % 7) * 3.0)
		tuft.set_meta("theme_role", "grass")
		tuft.material_override = _material("grass", palette, false)
		patch.add_child(tuft)


func _grass_blade_mesh(width: float, height: float, tip_offset: float) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(-width * 0.5, -height * 0.5, 0.0),
		Vector3(width * 0.5, -height * 0.5, 0.0),
		Vector3(tip_offset, height * 0.5, 0.0),
	])
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(0.5, 0.0),
	])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _build_reference_portal(parent: Node3D, texture_path: String, _palette: Dictionary) -> void:
	var texture := _load_runtime_texture(texture_path)
	if texture == null:
		return
	var aspect := float(texture.get_width()) / maxf(1.0, float(texture.get_height()))
	var portal_width := 12.8
	if district_style == "night_white_blocks":
		portal_width = 10.8
	elif district_style == "overgrown_gallery":
		portal_width = 8.2
	portal_width = minf(portal_width, map_width - 5.0)
	var portal_height := minf(16.0, portal_width / aspect)
	var portal := MeshInstance3D.new()
	portal.name = "ReferencePortal"
	var quad := QuadMesh.new()
	quad.size = Vector2(portal_width, portal_height)
	portal.mesh = quad
	portal.position = Vector3(0.0, portal_height * 0.5, -map_length * 0.5 + 0.32)
	portal.set_meta("reference_texture", texture_path)
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission_enabled = true
	material.emission_texture = texture
	material.emission_energy_multiplier = 0.28
	portal.material_override = material
	parent.add_child(portal)


func _load_runtime_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource := load(path) as Texture2D
		if resource != null:
			return resource
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)


func _build_road_markings(parent: Node3D, palette: Dictionary) -> void:
	var stripe_count := int(floor(map_length / 4.8))
	for stripe_index in stripe_count:
		var z := -map_length * 0.5 + 2.8 + float(stripe_index) * 4.8
		_add_box(parent, "SignalStripe%02d" % stripe_index, Vector3(0.14, 0.018, 2.1), Vector3(0.0, 0.028, z), "accent", palette, false)
	for side in [-1.0, 1.0]:
		for marker_index in 3:
			var z := -6.0 + float(marker_index) * 6.0
			_add_box(
				parent,
				"PlazaMark%s%d" % ["W" if side < 0.0 else "E", marker_index],
				Vector3(1.8, 0.018, 0.10),
				Vector3(side * 5.4, 0.029, z),
				"accent",
				palette,
				false
			)


func _build_street_lot(parent: Node3D, room_index: int, center: Vector3, side: float, palette: Dictionary) -> void:
	var room := Node3D.new()
	room.name = "Room%02d" % room_index
	room.set_meta("room_index", room_index)
	room.set_meta("street_lot", true)
	parent.add_child(room)

	var facade_height := WALL_HEIGHT + float((room_index + built_floor) % 3) * 0.55
	_add_box(room, "LotPad", Vector3(LOT_DEPTH, 0.045, LOT_WIDTH), center + Vector3(0.0, 0.025, 0.0), "lot_floor", palette, false)
	_add_box(
		room,
		"BackFacade",
		Vector3(0.34, facade_height, LOT_WIDTH),
		center + Vector3(side * LOT_DEPTH * 0.5, facade_height * 0.5, 0.0),
		"wall_dark" if room_index % 2 == 0 else "wall",
		palette,
		true
	)
	_add_box(
		room,
		"Canopy",
		Vector3(LOT_DEPTH * 0.72, 0.14, LOT_WIDTH * 0.68),
		center + Vector3(side * 0.70, 2.55 + float(room_index % 2) * 0.22, 0.0),
		"ceiling",
		palette,
		true
	)
	for edge in [-1.0, 1.0]:
		_add_box(
			room,
			"Frame%s" % ("North" if edge < 0.0 else "South"),
			Vector3(0.28, 2.55, 0.28),
			center + Vector3(-side * (LOT_DEPTH * 0.5 - 0.72), 1.275, edge * (LOT_WIDTH * 0.34)),
			"accent",
			palette,
			true
		)

	if (room_index + built_floor) % 3 == 0:
		_build_useful_item(room, room_index, center + Vector3(-side * 1.55, 0.0, 0.15), palette)
	elif (room_index + built_floor) % 4 == 0:
		_add_box(room, "EmptyPlinth", Vector3(0.72, 0.42, 0.72), center + Vector3(-side * 1.25, 0.21, 0.14), "wall_dark", palette, false)


func _build_air_walls(parent: Node3D) -> void:
	var walls := Node3D.new()
	walls.name = "AirWalls"
	parent.add_child(walls)
	_add_air_wall(walls, "WestAirWall", Vector3(AIR_WALL_THICKNESS, AIR_WALL_HEIGHT, map_length + AIR_WALL_THICKNESS * 2.0), Vector3(-map_width * 0.5, AIR_WALL_HEIGHT * 0.5, 0.0))
	_add_air_wall(walls, "EastAirWall", Vector3(AIR_WALL_THICKNESS, AIR_WALL_HEIGHT, map_length + AIR_WALL_THICKNESS * 2.0), Vector3(map_width * 0.5, AIR_WALL_HEIGHT * 0.5, 0.0))
	_add_air_wall(walls, "NorthAirWall", Vector3(map_width, AIR_WALL_HEIGHT, AIR_WALL_THICKNESS), Vector3(0.0, AIR_WALL_HEIGHT * 0.5, -map_length * 0.5))
	_add_air_wall(walls, "SouthAirWall", Vector3(map_width, AIR_WALL_HEIGHT, AIR_WALL_THICKNESS), Vector3(0.0, AIR_WALL_HEIGHT * 0.5, map_length * 0.5))


func _add_air_wall(parent: Node3D, node_name: String, size: Vector3, position: Vector3) -> void:
	var wall := StaticBody3D.new()
	wall.name = node_name
	wall.position = position
	wall.collision_layer = 1
	wall.collision_mask = 1
	wall.set_meta("air_wall", true)
	parent.add_child(wall)
	var collision := CollisionShape3D.new()
	collision.name = "Collision"
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	wall.add_child(collision)


func _build_useful_item(parent: Node3D, room_index: int, position: Vector3, palette: Dictionary) -> void:
	useful_item_count += 1
	var definitions := [
		{"label": "信号筹码", "effect": "publish_base", "value": 8, "description": "下一次发布的传播基础 +8。"},
		{"label": "回声镜片", "effect": "publish_multiplier_bonus", "value": 1, "description": "下一次发布的整数倍率 +1。"},
		{"label": "清晰线", "effect": "clarity", "value": 7, "description": "立即恢复 7 点清晰。"},
	]
	var definition: Dictionary = definitions[posmod(int(room_index / 3) + built_floor, definitions.size())]
	var item := Area3D.new()
	item.name = "UsefulItem%02d" % room_index
	item.position = position
	item.collision_layer = 2
	item.collision_mask = 0
	item.set_meta("useful_item", true)
	item.set_meta("room_index", room_index)
	item.set_meta("item_id", "signal_fragment_%d_%d" % [built_floor, room_index])
	item.set_meta("display_name", str(definition.get("label", "街区遗物")))
	item.set_meta("item_effect", str(definition.get("effect", "")))
	item.set_meta("item_value", definition.get("value", 0))
	item.set_meta("item_description", str(definition.get("description", "")))
	parent.add_child(item)
	_items.append(item)
	var pedestal := MeshInstance3D.new()
	pedestal.name = "Pedestal"
	var pedestal_mesh := BoxMesh.new()
	pedestal_mesh.size = Vector3(0.72, 0.42, 0.72)
	pedestal.mesh = pedestal_mesh
	pedestal.position.y = 0.21
	pedestal.set_meta("theme_role", "wall_dark")
	pedestal.material_override = _material("wall_dark", palette, false)
	item.add_child(pedestal)
	var shard_material := _material("item", palette, true)
	var lower_shard := MeshInstance3D.new()
	lower_shard.name = "SignalShardLower"
	var lower_mesh := CylinderMesh.new()
	lower_mesh.top_radius = 0.20
	lower_mesh.bottom_radius = 0.0
	lower_mesh.height = 0.34
	lower_mesh.radial_segments = 6
	lower_mesh.rings = 1
	lower_shard.mesh = lower_mesh
	lower_shard.position.y = 0.64
	lower_shard.set_meta("theme_role", "item")
	lower_shard.material_override = shard_material
	item.add_child(lower_shard)
	var upper_shard := MeshInstance3D.new()
	upper_shard.name = "SignalShardUpper"
	var upper_mesh := CylinderMesh.new()
	upper_mesh.top_radius = 0.0
	upper_mesh.bottom_radius = 0.20
	upper_mesh.height = 0.44
	upper_mesh.radial_segments = 6
	upper_mesh.rings = 1
	upper_shard.mesh = upper_mesh
	upper_shard.position.y = 1.03
	upper_shard.set_meta("theme_role", "item")
	upper_shard.material_override = shard_material
	item.add_child(upper_shard)
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.52
	collision.shape = shape
	collision.position.y = 0.58
	item.add_child(collision)


func _build_actors(palette: Dictionary, actor_textures: Dictionary) -> void:
	var actors := Node3D.new()
	actors.name = "Actors"
	add_child(actors)
	var spawn := start_position()
	var merchant_position := Vector3(-3.4, 0.0, spawn.z - 8.0)
	var merchant_texture := actor_textures.get("merchant") as Texture2D
	var npc_textures: Array = actor_textures.get("npcs", [])
	var fallback_texture := merchant_texture
	if not npc_textures.is_empty() and npc_textures[0] is Texture2D:
		fallback_texture = npc_textures[0]
	var merchant := _make_actor("Merchant", "merchant", "信号商人", merchant_position, merchant_texture if merchant_texture != null else fallback_texture, palette, 0)
	actors.add_child(merchant)
	_actors.append(merchant)

	var labels := ["迟到者", "回声住户", "抄写员", "无名信徒", "旧帖目击者"]
	var street_south := map_length * 0.5 - 12.5
	var street_north := -map_length * 0.5 + 8.0
	var lateral_positions := [3.4, -3.0, 1.6, -3.3, 0.5]
	for index in ordinary_npc_count:
		var progress := float(index + 1) / float(ordinary_npc_count + 1)
		var actor_position := Vector3(
			float(lateral_positions[index % lateral_positions.size()]),
			0.0,
			lerpf(street_south, street_north, progress)
		)
		var npc_texture: Texture2D = fallback_texture
		if not npc_textures.is_empty() and npc_textures[index % npc_textures.size()] is Texture2D:
			npc_texture = npc_textures[index % npc_textures.size()]
		var actor := _make_actor("NPC%d" % index, "npc", labels[index % labels.size()], actor_position, npc_texture, palette, index % 3)
		actors.add_child(actor)
		_actors.append(actor)


func _make_actor(node_name: String, actor_type: String, display_name: String, position: Vector3, npc_texture: Texture2D, palette: Dictionary, tint_index: int) -> Area3D:
	var actor := Area3D.new()
	actor.name = node_name
	actor.position = position
	actor.collision_layer = 2
	actor.collision_mask = 0
	actor.set_meta("actor_id", "%s_%d_%s" % [actor_type, built_floor, node_name.to_lower()])
	actor.set_meta("actor_type", actor_type)
	actor.set_meta("display_name", display_name)
	actor.set_meta("tint_index", tint_index)
	var collision := CollisionShape3D.new()
	collision.name = "InteractionShape"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.58
	capsule.height = 2.0
	collision.shape = capsule
	collision.position.y = 1.0
	actor.add_child(collision)

	var sprite := Sprite3D.new()
	sprite.name = "Billboard"
	sprite.texture = npc_texture
	sprite.pixel_size = 0.00134
	sprite.position.y = 1.03
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.double_sided = true
	if actor_type == "merchant":
		sprite.modulate = _color(palette, "surface")
		sprite.scale = Vector3(1.05, 1.05, 1.05)
	else:
		sprite.modulate = Color.WHITE.lerp(_color(palette, "muted"), 0.08 + tint_index * 0.04)
	actor.add_child(sprite)
	return actor


func _add_box(parent: Node3D, node_name: String, size: Vector3, position: Vector3, role: String, palette: Dictionary, with_collision: bool) -> Node3D:
	var holder: Node3D
	if with_collision:
		holder = StaticBody3D.new()
	else:
		holder = Node3D.new()
	holder.name = node_name
	holder.position = position
	parent.add_child(holder)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.set_meta("theme_role", role)
	mesh_instance.material_override = _material(role, palette, false)
	holder.add_child(mesh_instance)
	if with_collision:
		var collision := CollisionShape3D.new()
		collision.name = "Collision"
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		holder.add_child(collision)
	return holder


func _material(role: String, palette: Dictionary, emission: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = _role_color(role, palette)
	material.roughness = 0.94
	material.metallic = 0.0
	if role == "grass":
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if emission or role == "lamp_light":
		material.emission_enabled = true
		material.emission = _role_color(role, palette)
		material.emission_energy_multiplier = 1.6
	return material


func _role_color(role: String, palette: Dictionary) -> Color:
	match role:
		"brick":
			return Color("D7B77F").lerp(_color(palette, "surface"), 0.12)
		"brick_light":
			return Color("E8CEA0").lerp(_color(palette, "surface"), 0.10)
		"brick_dark":
			return Color("8F7655").lerp(_color(palette, "accent"), 0.08)
		"white_wall":
			return Color("F0F2E9") if district_style == "night_white_blocks" else Color("EEF0E4")
		"window":
			return Color("0B0D0B").lerp(_color(palette, "ink"), 0.35)
		"grass":
			return (Color("17321D") if district_style == "night_white_blocks" else Color("4F7134")).lerp(_color(palette, "accent"), 0.18)
		"gallery_floor":
			return Color("E1E5D8").lerp(_color(palette, "surface"), 0.12)
		"sunlit_paving":
			return Color("D7C8A8").lerp(_color(palette, "surface"), 0.16)
		"night_path":
			return Color("151613").lerp(_color(palette, "ink"), 0.42)
		"crosswalk":
			return Color("F3E8CD").lerp(_color(palette, "surface"), 0.24)
		"lamp":
			return Color("22241F").lerp(_color(palette, "ink"), 0.35)
		"lamp_light":
			return Color("FFBE58") if district_style == "night_white_blocks" else Color("E4D6A0")
		"ground":
			return _color(palette, "ink").lightened(0.055)
		"road":
			return _color(palette, "accent").darkened(0.54)
		"sidewalk":
			return _color(palette, "bg").darkened(0.36)
		"lot_floor":
			return _color(palette, "accent").darkened(0.30)
		"floor":
			return _color(palette, "accent").darkened(0.38)
		"floor_alt":
			return _color(palette, "accent").darkened(0.24)
		"wall":
			return _color(palette, "bg").darkened(0.38)
		"wall_dark":
			return _color(palette, "ink").lightened(0.035)
		"ceiling":
			return _color(palette, "surface").darkened(0.58)
		"accent":
			return _color(palette, "accent").darkened(0.10)
		"item":
			return _color(palette, "flash_text")
		_:
			return _color(palette, "muted")


func _style_background_color(palette: Dictionary) -> Color:
	match district_style:
		"sunlit_brick_street":
			return Color("1479B8").lerp(_color(palette, "accent"), 0.10)
		"night_white_blocks":
			return Color("10090B").lerp(_color(palette, "ink"), 0.22)
		"overgrown_gallery":
			return Color("D4DDD0").lerp(_color(palette, "muted"), 0.18)
		_:
			return _color(palette, "ink")


func _style_ambient_color(palette: Dictionary) -> Color:
	match district_style:
		"night_white_blocks":
			return Color("AEB8A2").lerp(_color(palette, "muted"), 0.18)
		"overgrown_gallery":
			return Color("F3F2DD").lerp(_color(palette, "surface"), 0.24)
		_:
			return Color("FFE4B8").lerp(_color(palette, "surface"), 0.18)


func _style_fog_color(palette: Dictionary) -> Color:
	match district_style:
		"night_white_blocks":
			return Color("23181A").lerp(_color(palette, "accent"), 0.10)
		"overgrown_gallery":
			return Color("C9D6C0").lerp(_color(palette, "muted"), 0.20)
		_:
			return Color("7DB5C2").lerp(_color(palette, "accent"), 0.12)


func _color(palette: Dictionary, key: String) -> Color:
	return Color(str(palette.get(key, "FFF1C9")))
