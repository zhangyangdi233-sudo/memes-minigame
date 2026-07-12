extends SceneTree

const RicherTextLabelScript = preload("res://addons/richtext2/richer_text_label.gd")

var failures := 0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var label := RicherTextLabelScript.new() as RichTextLabel
	label.bbcode_enabled = true
	root.add_child(label)
	label.call("set_bbcode", "[curspull pull=0.12]正常[cuss]污染[][]")
	await process_frame
	await process_frame
	_assert_true(_has_effect(label, "curspull"), "curspull should install from the requested BBCode tag")
	_assert_true(_has_effect(label, "cuss"), "cuss should install from the requested BBCode tag")
	label.queue_free()
	await process_frame
	if failures == 0:
		print("rich text effect tests passed")
	quit(1 if failures > 0 else 0)


func _has_effect(label: RichTextLabel, effect_name: String) -> bool:
	for effect in label.custom_effects:
		if str(effect.resource_name) == effect_name:
			return true
	return false


func _assert_true(value: bool, message: String) -> void:
	if value:
		return
	failures += 1
	push_error(message)
