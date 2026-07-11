extends Node3D
class_name RealityFloorGenerator

const BASE_ROOM_COUNT := 4
const LOT_SPACING := 9.4
const LOT_WIDTH := 7.4
const LOT_DEPTH := 6.8
const STREET_WIDTH := 14.0
const MIN_MAP_WIDTH := 34.0
const MIN_MAP_LENGTH := 46.0
const MAP_END_MARGIN := 12.0
const WALL_HEIGHT := 3.4
const AIR_WALL_HEIGHT := 6.0
const AIR_WALL_THICKNESS := 0.5

var built_floor: int = 0
var room_count: int = 0
var ordinary_npc_count: int = 0
var useful_item_count: int = 0
var map_width: float = MIN_MAP_WIDTH
var map_length: float = MIN_MAP_LENGTH
var _actors: Array[Area3D] = []
var _environment: WorldEnvironment


static func room_count_for_floor(floor_number: int) -> int:
	var normalized := maxi(1, floor_number) - 1
	return BASE_ROOM_COUNT + normalized * 2 + int(normalized / 2)


static func npc_count_for_floor(floor_number: int) -> int:
	return maxi(2, 6 - maxi(1, floor_number))


func rebuild(floor_number: int, palette: Dictionary, npc_texture: Texture2D) -> void:
	_clear_floor()
	built_floor = clampi(floor_number, 1, 5)
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
	set_meta("air_wall_count", 4)

	_build_environment(palette)
	_build_architecture(palette)
	_build_actors(palette, npc_texture)
	set_meta("useful_item_count", useful_item_count)


func get_interactable_actors() -> Array[Area3D]:
	var live_actors: Array[Area3D] = []
	for actor in _actors:
		if is_instance_valid(actor):
			live_actors.append(actor)
	return live_actors


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
		environment.background_color = _color(palette, "ink").darkened(0.18)
		environment.ambient_light_color = _color(palette, "muted")
		environment.fog_light_color = _color(palette, "accent").darkened(0.14)
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
	_environment = null
	for child in get_children():
		remove_child(child)
		child.free()


func _build_environment(palette: Dictionary) -> void:
	_environment = WorldEnvironment.new()
	_environment.name = "RealityWorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = _color(palette, "ink").darkened(0.18)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = _color(palette, "muted")
	environment.ambient_light_energy = 0.52
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.fog_enabled = true
	environment.fog_light_color = _color(palette, "accent").darkened(0.14)
	environment.fog_light_energy = 0.42
	environment.fog_density = 0.012 + built_floor * 0.0025
	environment.fog_height = 1.1
	environment.fog_height_density = 0.16
	_environment.environment = environment
	add_child(_environment)

	var key_light := DirectionalLight3D.new()
	key_light.name = "RealityKeyLight"
	key_light.rotation_degrees = Vector3(-54.0, -28.0, 0.0)
	key_light.light_color = _color(palette, "surface")
	key_light.light_energy = 0.62
	key_light.shadow_enabled = true
	add_child(key_light)


func _build_architecture(palette: Dictionary) -> void:
	var architecture := Node3D.new()
	architecture.name = "Architecture"
	add_child(architecture)
	var street_ground := _add_box(
		architecture,
		"StreetGround",
		Vector3(map_width, 0.20, map_length),
		Vector3(0.0, -0.10, 0.0),
		"ground",
		palette,
		true
	)
	street_ground.set_meta("continuous_ground", true)

	_add_box(
		architecture,
		"MainRoad",
		Vector3(STREET_WIDTH, 0.025, map_length - 1.0),
		Vector3(0.0, 0.008, 0.0),
		"road",
		palette,
		false
	)
	var sidewalk_width := (map_width - STREET_WIDTH) * 0.5
	for side in [-1.0, 1.0]:
		_add_box(
			architecture,
			"Sidewalk%s" % ("West" if side < 0.0 else "East"),
			Vector3(sidewalk_width, 0.055, map_length - 1.0),
			Vector3(side * (STREET_WIDTH * 0.5 + sidewalk_width * 0.5), 0.018, 0.0),
			"sidewalk",
			palette,
			false
		)
		_add_box(
			architecture,
			"Curb%s" % ("West" if side < 0.0 else "East"),
			Vector3(0.16, 0.10, map_length - 1.4),
			Vector3(side * (STREET_WIDTH * 0.5 + 0.08), 0.048, 0.0),
			"accent",
			palette,
			false
		)

	_build_road_markings(architecture, palette)
	var lot_rows := int(ceil(float(room_count) / 2.0))
	for room_index in room_count:
		var row := int(room_index / 2)
		var side := -1.0 if room_index % 2 == 0 else 1.0
		var center_z := (float(lot_rows - 1) * LOT_SPACING * 0.5) - float(row) * LOT_SPACING
		var center_x := side * (STREET_WIDTH * 0.5 + 1.0 + LOT_DEPTH * 0.5)
		_build_street_lot(architecture, room_index, Vector3(center_x, 0.0, center_z), side, palette)

	_build_air_walls(architecture)


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
	var item := Area3D.new()
	item.name = "UsefulItem%02d" % room_index
	item.position = position
	item.set_meta("useful_item", true)
	item.set_meta("room_index", room_index)
	item.set_meta("item_id", "signal_fragment_%d_%d" % [built_floor, room_index])
	parent.add_child(item)
	var pedestal := MeshInstance3D.new()
	pedestal.name = "Pedestal"
	var pedestal_mesh := BoxMesh.new()
	pedestal_mesh.size = Vector3(0.72, 0.42, 0.72)
	pedestal.mesh = pedestal_mesh
	pedestal.position.y = 0.21
	pedestal.set_meta("theme_role", "wall_dark")
	pedestal.material_override = _material("wall_dark", palette, false)
	item.add_child(pedestal)
	var shard := MeshInstance3D.new()
	shard.name = "SignalShard"
	var shard_mesh := SphereMesh.new()
	shard_mesh.radius = 0.22
	shard_mesh.height = 0.58
	shard_mesh.radial_segments = 6
	shard_mesh.rings = 4
	shard.mesh = shard_mesh
	shard.position.y = 0.78
	shard.set_meta("theme_role", "item")
	shard.material_override = _material("item", palette, true)
	item.add_child(shard)
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.52
	collision.shape = shape
	collision.position.y = 0.58
	item.add_child(collision)


func _build_actors(palette: Dictionary, npc_texture: Texture2D) -> void:
	var actors := Node3D.new()
	actors.name = "Actors"
	add_child(actors)
	var spawn := start_position()
	var merchant_position := Vector3(-3.4, 0.0, spawn.z - 8.0)
	var merchant := _make_actor("Merchant", "merchant", "信号商人", merchant_position, npc_texture, palette, 0)
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
	if emission:
		material.emission_enabled = true
		material.emission = _role_color(role, palette)
		material.emission_energy_multiplier = 1.6
	return material


func _role_color(role: String, palette: Dictionary) -> Color:
	match role:
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


func _color(palette: Dictionary, key: String) -> Color:
	return Color(str(palette.get(key, "FFF1C9")))
