extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	_run()
	if _failures.is_empty():
		print("drag control tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	var drag_script := load("res://scripts/ui/draggable_button.gd") as Script
	var drop_script := load("res://scripts/ui/drop_button.gd") as Script
	_assert_true(drag_script != null, "draggable button script should exist")
	_assert_true(drop_script != null, "drop button script should exist")
	if drag_script == null or drop_script == null:
		return
	var drag: Button = drag_script.new()
	drag.set_drag_payload("token", "n1", "哈吉米")
	var payload: Variant = drag._get_drag_data(Vector2.ZERO)
	_assert_eq(payload.get("kind", ""), "token", "drag payload should expose kind")
	_assert_eq(payload.get("id", ""), "n1", "drag payload should expose id")

	var drop: Button = drop_script.new()
	drop.configure_drop_target("token", "target")
	var accepted: bool = drop._can_drop_data(Vector2.ZERO, payload)
	var rejected: bool = drop._can_drop_data(Vector2.ZERO, {"kind": "meme", "id": "m1"})
	_assert_true(accepted, "drop target should accept matching drag kind")
	_assert_true(not rejected, "drop target should reject mismatched drag kind")
	drag.free()
	drop.free()


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s. Expected %s, got %s" % [message, str(expected), str(actual)])
