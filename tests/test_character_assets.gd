extends SceneTree

const CHARACTER_ASSETS := {
	"merchant": {
		"path": "res://assets/generated/characters/merchant_frame_vendor.png",
		"sha256": "d2971622e77e4534ceae23896b701bdf8bfde6c407c105953f03efde47637ee8",
	},
	"late_arrival": {
		"path": "res://assets/generated/characters/npc_late_arrival.png",
		"sha256": "6983f6000cf5ee282f27cab1a8edd56c2894cb1dc9efdcba10ebed85f3a4df3e",
	},
	"echo_tenant": {
		"path": "res://assets/generated/characters/npc_echo_tenant.png",
		"sha256": "bf173484a3feedae21c3a2ce70f88d7135d995d5d5b70001f8522c74335f4f3f",
	},
	"archive_witness": {
		"path": "res://assets/generated/characters/npc_archive_witness.png",
		"sha256": "df351ab9e5373eb07d9e1fd1db56295d3c3bc9622b048a02bc65cbf60ee019c3",
	},
}

var _failures: Array[String] = []


func _init() -> void:
	_run()
	if _failures.is_empty():
		print("character asset tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	for character_id: String in CHARACTER_ASSETS:
		var contract := CHARACTER_ASSETS[character_id] as Dictionary
		var path := str(contract["path"])
		_assert_true(FileAccess.file_exists(path), "%s portrait should exist" % character_id)
		if not FileAccess.file_exists(path):
			continue
		_assert_eq(FileAccess.get_sha256(path), str(contract["sha256"]), "%s portrait should match its curated faceless source" % character_id)
		var image := Image.new()
		var load_error := image.load(ProjectSettings.globalize_path(path))
		_assert_eq(load_error, OK, "%s portrait should decode as a PNG" % character_id)
		if load_error != OK:
			continue
		_assert_eq(image.get_size(), Vector2i(1024, 1536), "%s portrait should keep the shared full-body canvas" % character_id)
		_assert_true(image.get_pixel(0, 0).a <= 0.01 and image.get_pixel(image.get_width() - 1, image.get_height() - 1).a <= 0.01, "%s portrait should retain a transparent background" % character_id)
		_assert_featureless_face(image, character_id)


func _assert_featureless_face(image: Image, character_id: String) -> void:
	var opaque_samples := 0
	var dark_samples := 0
	var red_samples := 0
	var total_samples := 0
	for y_step in range(9):
		var v := lerpf(0.155, 0.205, float(y_step) / 8.0)
		for x_step in range(9):
			var u := lerpf(0.465, 0.535, float(x_step) / 8.0)
			var pixel := image.get_pixel(clampi(int(u * image.get_width()), 0, image.get_width() - 1), clampi(int(v * image.get_height()), 0, image.get_height() - 1))
			total_samples += 1
			if pixel.a < 0.80:
				continue
			opaque_samples += 1
			var luminance := pixel.get_luminance()
			if luminance < 0.25:
				dark_samples += 1
			if pixel.r > pixel.g * 1.35 and pixel.r > pixel.b * 1.35:
				red_samples += 1
	_assert_true(opaque_samples >= int(float(total_samples) * 0.88), "%s face center should be a solid cream silhouette" % character_id)
	_assert_true(dark_samples <= 12, "%s source portrait should contain only sparse photocopy grain, not eyes, nose, mouth, or other facial marks (dark samples: %d)" % [character_id, dark_samples])
	_assert_true(red_samples <= 2, "%s face should not regain the old red/magenta floor tint beyond isolated registration noise" % character_id)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
