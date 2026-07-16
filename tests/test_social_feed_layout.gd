extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "main scene should load for social layout verification")
	if scene == null:
		_finish()
		return
	var game_root := scene.instantiate()
	root.add_child(game_root)
	game_root._on_language_selected("ja")
	game_root.new_game()
	game_root._skip_prologue()
	game_root._open_app_windows["social"] = true
	game_root.game.set_active_app("social")
	game_root._set_social_screen("home")
	for _frame in 8:
		await process_frame

	var grid := _find_node_by_name(game_root, "SocialFeedMasonry") as GridContainer
	_assert_true(grid != null and grid.columns == 2, "Japanese feed should use one strict two-column grid")
	var cards: Array[PanelContainer] = []
	_collect_social_cards(game_root, cards)
	_assert_true(cards.size() >= 4, "Japanese feed should lay out enough cards to compare both columns")
	if cards.size() >= 2:
		var expected_width := cards[0].size.x
		_assert_true(expected_width >= 150.0, "social cards should remain comfortably readable")
		var has_staggered_height := false
		for card in cards:
			_assert_near(card.size.x, expected_width, 0.5, "left and right Japanese cards must have identical rendered width")
			if absf(card.size.y - cards[0].size.y) > 1.0:
				has_staggered_height = true
		_assert_true(has_staggered_height, "equal card width should not force every masonry card to the same height")
		var first_clip := _find_node_by_name(cards[0], "SocialPostClip0") as Control
		_assert_true(first_clip != null and first_clip.clip_contents, "localized content should be isolated from column width calculation")

	game_root.queue_free()
	await process_frame
	_finish()


func _collect_social_cards(node: Node, result: Array[PanelContainer]) -> void:
	if node is PanelContainer and str(node.name).begins_with("SocialPostCard"):
		result.append(node as PanelContainer)
	for child in node.get_children():
		_collect_social_cards(child, result)


func _find_node_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child in node.get_children():
		var found := _find_node_by_name(child, node_name)
		if found != null:
			return found
	return null


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s (expected %.2f +/- %.2f, got %.2f)" % [message, expected, tolerance, actual])


func _finish() -> void:
	if _failures.is_empty():
		print("social feed layout tests passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)
