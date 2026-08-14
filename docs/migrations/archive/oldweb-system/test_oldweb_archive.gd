extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "main scene should load")
	if scene == null:
		_finish()
		return
	var game_root = scene.instantiate()
	root.add_child(game_root)
	await process_frame
	game_root.new_game()
	game_root._skip_prologue()
	game_root._set_social_screen("profile")
	await process_frame
	var archive_button := _find_node(game_root, "OldWebArchiveButton") as Button
	_assert_true(archive_button != null, "profile should expose the old-web archive")
	var actions_before: int = game_root.game.actions_remaining
	if archive_button != null:
		archive_button.pressed.emit()
	await process_frame
	_assert_true(_find_node(game_root, "OldWebArchivePage") != null, "archive button should open the nested old website")
	var archive_header := _find_node(game_root, "OldWebArchiveHeader") as PanelContainer
	_assert_true(archive_header != null and archive_header.has_meta("oldweb_dark_panel"), "old-web title should retain its dedicated dark square style")
	var source_button := _find_node(game_root, "OldWebNavSource") as Button
	_assert_true(source_button != null, "archive should expose a source-code page")
	if source_button != null:
		source_button.pressed.emit()
	await process_frame
	var input := _find_node(game_root, "OldWebArchiveCodeInput") as LineEdit
	var verify := _find_node(game_root, "OldWebArchiveVerifyButton") as Button
	_assert_true(input != null and verify != null, "source page should expose the four-digit cache puzzle")
	if input != null and verify != null:
		input.text = "0000"
		verify.pressed.emit()
		await process_frame
		var wrong_status := _find_node(game_root, "OldWebArchiveStatus") as Label
		_assert_true(wrong_status != null and not wrong_status.text.strip_edges().is_empty(), "wrong archive code should receive diegetic feedback in every locale")
		input = _find_node(game_root, "OldWebArchiveCodeInput") as LineEdit
		verify = _find_node(game_root, "OldWebArchiveVerifyButton") as Button
		input.text = "1305"
		verify.pressed.emit()
		await process_frame
		_assert_true(_find_node(game_root, "OldWebArchiveUnlocked") != null, "code 1305 should unlock the original archive record")
	_assert_eq(game_root.game.actions_remaining, actions_before, "old-web exploration should not spend a daily action")
	game_root.queue_free()
	await process_frame
	_finish()


func _find_node(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found := _find_node(child, target_name)
		if found != null:
			return found
	return null


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func _finish() -> void:
	if _failures.is_empty():
		print("old web archive tests passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)
