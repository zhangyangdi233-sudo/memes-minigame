extends Node3D
class_name RealityFloorGenerator

const BASE_ROOM_COUNT := 4
const ROOM_SPACING := 4.8
const ROOM_WIDTH := 3.8
const ROOM_DEPTH := 4.2
const CORRIDOR_WIDTH := 3.2
const WALL_HEIGHT := 2.8

var built_floor: int = 0
var room_count: int = 0
var ordinary_npc_count: int = 0
var useful_item_count: int = 0
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
	set_meta("built_floor", built_floor)
	set_meta("room_count", room_count)
	set_meta("ordinary_npc_count", ordinary_npc_count)

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
	return Vector3(0.0, 0.08, 3.6)


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
	environment.fog_density = 0.022 + built_floor * 0.004
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
	var bay_count := int(ceil(float(room_count) / 2.0))
	var corridor_length := bay_count * ROOM_SPACING + 8.0
	var corridor_center_z := 4.6 - corridor_length * 0.5
	_add_box(architecture, "CorridorFloor", Vector3(CORRIDOR_WIDTH, 0.14, corridor_length), Vector3(0.0, -0.07, corridor_center_z), "floor", palette, true)
	_add_box(architecture, "EntryWall", Vector3(CORRIDOR_WIDTH + 0.4, WALL_HEIGHT, 0.18), Vector3(0.0, WALL_HEIGHT * 0.5, 4.7), "wall_dark", palette, true)
	_add_box(architecture, "EndWall", Vector3(CORRIDOR_WIDTH + 0.4, WALL_HEIGHT, 0.18), Vector3(0.0, WALL_HEIGHT * 0.5, 4.6 - corridor_length), "wall_dark", palette, true)

	for room_index in room_count:
		var bay := int(room_index / 2)
		var side := -1.0 if room_index % 2 == 0 else 1.0
		var center_z := 1.2 - bay * ROOM_SPACING
		var center_x := side * (CORRIDOR_WIDTH * 0.5 + ROOM_WIDTH * 0.5)
		_build_room(architecture, room_index, Vector3(center_x, 0.0, center_z), side, palette)

	for bay in bay_count:
		var center_z := 1.2 - bay * ROOM_SPACING
		for side in [-1.0, 1.0]:
			var room_index := bay * 2 + (1 if side > 0.0 else 0)
			if room_index < room_count:
				continue
			_add_box(architecture, "ClosedBay%d" % room_index, Vector3(0.18, WALL_HEIGHT, ROOM_DEPTH), Vector3(side * CORRIDOR_WIDTH * 0.5, WALL_HEIGHT * 0.5, center_z), "wall", palette, true)


func _build_room(parent: Node3D, room_index: int, center: Vector3, side: float, palette: Dictionary) -> void:
	var room := Node3D.new()
	room.name = "Room%02d" % room_index
	room.set_meta("room_index", room_index)
	parent.add_child(room)
	_add_box(room, "Floor", Vector3(ROOM_WIDTH, 0.14, ROOM_DEPTH), center + Vector3(0.0, -0.07, 0.0), "floor_alt" if room_index % 3 == 0 else "floor", palette, true)
	_add_box(room, "Ceiling", Vector3(ROOM_WIDTH, 0.12, ROOM_DEPTH), center + Vector3(0.0, WALL_HEIGHT + 0.06, 0.0), "ceiling", palette, true)
	_add_box(room, "OuterWall", Vector3(0.18, WALL_HEIGHT, ROOM_DEPTH), center + Vector3(side * ROOM_WIDTH * 0.5, WALL_HEIGHT * 0.5, 0.0), "wall_dark", palette, true)
	_add_box(room, "FrontWall", Vector3(ROOM_WIDTH, WALL_HEIGHT, 0.18), center + Vector3(0.0, WALL_HEIGHT * 0.5, ROOM_DEPTH * 0.5), "wall", palette, true)
	_add_box(room, "BackWall", Vector3(ROOM_WIDTH, WALL_HEIGHT, 0.18), center + Vector3(0.0, WALL_HEIGHT * 0.5, -ROOM_DEPTH * 0.5), "wall", palette, true)
	_add_box(room, "DoorLintel", Vector3(0.18, 0.48, ROOM_DEPTH), center + Vector3(-side * ROOM_WIDTH * 0.5, WALL_HEIGHT - 0.24, 0.0), "accent", palette, true)

	if (room_index + built_floor) % 3 == 0:
		_build_useful_item(room, room_index, center + Vector3(side * 0.65, 0.0, 0.12), palette)
	elif (room_index + built_floor) % 4 == 0:
		_add_box(room, "EmptyPlinth", Vector3(0.72, 0.42, 0.72), center + Vector3(side * 0.64, 0.21, 0.14), "wall_dark", palette, false)


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
	var merchant_room := mini(1, room_count - 1)
	var merchant := _make_actor("Merchant", "merchant", "信号商人", _room_actor_position(merchant_room, 0.15), npc_texture, palette, 0)
	actors.add_child(merchant)
	_actors.append(merchant)

	var labels := ["迟到者", "回声住户", "抄写员", "无名信徒", "旧帖目击者"]
	for index in ordinary_npc_count:
		var room_index := posmod(index * 3 + built_floor, room_count)
		if room_index == merchant_room:
			room_index = posmod(room_index + 2, room_count)
		var actor := _make_actor("NPC%d" % index, "npc", labels[index % labels.size()], _room_actor_position(room_index, -0.25 if index % 2 == 0 else 0.28), npc_texture, palette, index % 3)
		actors.add_child(actor)
		_actors.append(actor)


func _room_actor_position(room_index: int, z_offset: float) -> Vector3:
	var bay := int(room_index / 2)
	var side := -1.0 if room_index % 2 == 0 else 1.0
	return Vector3(side * 2.65, 0.0, 1.2 - bay * ROOM_SPACING + z_offset)


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
