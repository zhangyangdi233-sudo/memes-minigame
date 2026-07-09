extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run_async")


func _run_async() -> void:
	await _run()
	if _failures.is_empty():
		print("main scene tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "main scene should exist")
	if scene == null:
		return
	var root := scene.instantiate()
	_assert_true(root is Node3D, "main scene root should be a Node3D")
	_assert_true(root.has_method("new_game"), "main scene script should expose new_game")
	_assert_true(root.has_method("show_main_menu"), "main scene script should expose main menu entry")
	if root.has_method("show_main_menu"):
		root.show_main_menu()
		var main_menu := _find_node_by_name(root, "MainMenuLayer") as Control
		var main_menu_start := _find_node_by_name(root, "MainMenuStartButton") as Button
		var main_menu_exit := _find_node_by_name(root, "MainMenuExitButton") as Button
		var main_menu_title := _find_node_by_name(root, "MainMenuTitle") as Label
		_assert_true(main_menu != null and main_menu.visible, "running scene should first expose a reference-style main menu")
		_assert_true(main_menu_title != null and str(main_menu_title.text).contains("HAJIMI"), "main menu should use the large Hajimi title treatment")
		_assert_true(main_menu_start != null, "main menu should expose a start game button")
		_assert_true(main_menu_exit != null, "main menu should expose an exit game button")
	if root.has_method("new_game"):
		root.new_game()
		_assert_true(root.get_node_or_null("Camera3D") is Camera3D, "main scene should contain a Camera3D")
		_assert_true(root.get_node_or_null("CanvasLayer") is CanvasLayer, "main scene should contain a CanvasLayer")
		_assert_true(root.get_node_or_null("Road") is Node3D, "main scene should contain scrolling road node")
		_assert_true(root.get_node_or_null("PhoneRig") is Node3D, "main scene should contain phone rig")
		_assert_true(root.get_node_or_null("NPC") is Node3D, "main scene should contain NPC node")
		_assert_true(root.has_method("_active_palette"), "main scene should expose active palette lookup")
		_assert_true(root.has_method("_theme_color"), "main scene should expose semantic theme colors")
		_assert_true(root.has_method("_play_pollution_flashback"), "main scene should expose pollution flashback playback")
		_assert_true(root.has_method("_finish_pollution_flashback"), "main scene should expose pollution flashback completion")
		_assert_true(root.has_method("begin_reality_player_turn"), "main scene should expose player turn transition")
		_assert_true(root.has_method("_toggle_meme_bank"), "main scene should expose meme bank drawer toggle")
		_assert_true(root.has_method("_move_window_for_test"), "main scene should expose test window movement helper")
		_assert_true(root.has_method("_window_position_for_test"), "main scene should expose test window position helper")
		_assert_true(root.has_method("set_view_state"), "main scene should expose set_view_state")
		_assert_true(root.has_method("_should_show_meme_bank"), "main scene should expose meme bank context visibility")
		_assert_true(root.has_method("_should_peek_meme_bank"), "main scene should expose meme bank peek visibility")
		_assert_true(root.has_method("_social_post_for_index"), "social feed should expose per-card post variants")
		_assert_true(root.has_method("_on_social_feed_scroll_gui_input"), "social feed should expose controlled slow scroll input")
		_assert_true(root.has_method("_play_action_spend_animation"), "main scene should expose action spend animation playback")
		_assert_true(root.has_method("_finish_action_spend_animation"), "main scene should expose action spend animation completion")
		_assert_true(root.has_method("_toggle_settings_window"), "main scene should expose settings window toggle")
		_assert_true(root.has_method("_on_vhs_toggled"), "main scene should expose VHS toggle handler")
		for asset_path in [
			"res://assets/generated/world/road_loop_green.png",
			"res://assets/generated/world/hand_phone_down.png",
			"res://assets/generated/world/phone_down_backdrop.png",
			"res://assets/generated/world/npc_front.png",
			"res://assets/generated/ui/player_portrait.png",
			"res://assets/generated/ui/no_signal_icon.png",
			"res://assets/generated/ui/hud_day_icon.png",
			"res://assets/generated/ui/hud_pollution_icon.png",
			"res://assets/generated/ui/hud_money_icon.png",
			"res://assets/generated/ui/hud_settings_icon.png",
			"res://assets/generated/social/poster_sheet.png",
			"res://assets/generated/social/poster_00.png",
			"res://assets/generated/social/poster_11.png",
		]:
			_assert_true(FileAccess.file_exists(asset_path), "generated asset should exist: %s" % asset_path)
		var camera := root.get_node_or_null("Camera3D") as Camera3D
		var road_tile := root.get_node_or_null("Road/RoadTile0") as MeshInstance3D
		var phone_rig := root.get_node_or_null("PhoneRig") as Node3D
		var npc_plane := root.get_node_or_null("NPC/NPCPlane") as MeshInstance3D
		var phone_down_backdrop_image := root.get_node_or_null("CanvasLayer/UIRoot/PhoneDownBackdropImage") as TextureRect
		var hand_phone_image := root.get_node_or_null("CanvasLayer/UIRoot/HandPhoneDownImage") as TextureRect
		var legacy_status_bar := _find_node_by_name(root, "StatusBar")
		var apple_hud := _find_node_by_name(root, "AppleHUDPanel") as PanelContainer
		var international_hud := _find_node_by_name(root, "InternationalHUDRail") as PanelContainer
		var hud_title := _find_node_by_name(root, "HUDTitle") as Label
		var hud_subtitle := _find_node_by_name(root, "HUDSubtitle") as Label
		var hud_actions_label := _find_node_by_name(root, "HUDActionsLabel") as Label
		var hud_day_value := _find_node_by_name(root, "HUDDayValue") as Label
		var hud_heat_value := _find_node_by_name(root, "HUDHeatValue") as Label
		var hud_pollution_value := _find_node_by_name(root, "HUDPollutionValue") as Label
		var hud_clarity_value := _find_node_by_name(root, "HUDClarityValue") as Label
		var hud_floor_value := _find_node_by_name(root, "HUDFloorValue") as Label
		var hud_money_value := _find_node_by_name(root, "HUDMoneyValue") as Label
		var hud_day_icon := _find_node_by_name(root, "HUDDayIcon") as Button
		var hud_pollution_icon := _find_node_by_name(root, "HUDPollutionIcon") as Button
		var hud_money_icon := _find_node_by_name(root, "HUDMoneyIcon") as Button
		var hud_settings_icon := _find_node_by_name(root, "HUDSettingsIcon") as Button
		var hud_tooltip := _find_node_by_name(root, "HUDTooltip") as PanelContainer
		var hud_tooltip_label := _find_node_by_name(root, "HUDTooltipLabel") as Label
		var settings_window := _find_node_by_name(root, "SettingsWindow") as PanelContainer
		var settings_close := _find_node_by_name(root, "SettingsCloseButton") as Button
		var settings_volume := _find_node_by_name(root, "SettingsVolumeSlider") as HSlider
		var settings_vhs_toggle := _find_node_by_name(root, "SettingsVHSToggle") as CheckButton
		var settings_return_main := _find_node_by_name(root, "SettingsReturnMainButton") as Button
		var vhs_overlay := _find_node_by_name(root, "VHSOverlay") as Control
		var vhs_tint := _find_node_by_name(root, "VHSTint") as ColorRect
		var vhs_side_noise := _find_node_by_name(root, "VHSSideNoise") as ColorRect
		var view_toggle_button := _find_node_by_name(root, "PhoneViewToggleButton") as Button
		var action_overlay := root.get_node_or_null("CanvasLayer/UIRoot/ActionSpendOverlay") as Control
		var action_blackout := root.get_node_or_null("CanvasLayer/UIRoot/ActionSpendOverlay/ActionSpendBlackout") as ColorRect
		var action_label := root.get_node_or_null("CanvasLayer/UIRoot/ActionSpendOverlay/ActionSpendLabel") as Label
		var phone_popup := _find_node_by_name(root, "PhonePopup") as PanelContainer
		var phone_tab := _find_node_by_name(root, "PhoneTab") as Button
		var phone_content := _find_node_by_name(root, "PhoneContent") as Control
		var phone_app_babel := _find_node_by_name(root, "PhoneAppIconBabel") as Button
		var phone_app_social := _find_node_by_name(root, "PhoneAppIconSocial") as Button
		var phone_app_shop := _find_node_by_name(root, "PhoneAppIconShop") as Button
		var phone_app_notebook := _find_node_by_name(root, "PhoneAppIconNotebook") as Button
		var babel_app_window := _find_node_by_name(root, "BabelAppWindow") as PanelContainer
		var social_app_window := _find_node_by_name(root, "SocialAppWindow") as PanelContainer
		var social_drag_bar := _find_node_by_name(root, "SocialWindowDragBar") as HBoxContainer
		var shop_app_window := _find_node_by_name(root, "ShopAppWindow") as PanelContainer
		var notebook_app_window := _find_node_by_name(root, "NotebookAppWindow") as PanelContainer
		var phone_handle := _find_node_by_name(root, "PhoneWindowHandle") as Label
		var babel_handle := _find_node_by_name(root, "BabelAppWindowHandle") as Label
		var shop_handle := _find_node_by_name(root, "ShopAppWindowHandle") as Label
		var notebook_handle := _find_node_by_name(root, "NotebookAppWindowHandle") as Label
		var babel_close := _find_node_by_name(root, "BabelAppWindowCloseButton") as Button
		var social_close := _find_node_by_name(root, "SocialAppWindowCloseButton") as Button
		var shop_close := _find_node_by_name(root, "ShopAppWindowCloseButton") as Button
		var notebook_close := _find_node_by_name(root, "NotebookAppWindowCloseButton") as Button
		var social_phone_view := _find_node_by_name(root, "SocialPhoneView") as PanelContainer
		var social_status_bar := _find_node_by_name(root, "SocialPhoneStatusBar") as HBoxContainer
		var social_inline_close := _find_node_by_name(root, "SocialAppInlineCloseButton") as Button
		var social_no_signal_icon := _find_node_by_name(root, "SocialNoSignalIcon") as TextureRect
		var social_no_signal_label := _find_node_by_name(root, "SocialNoSignalLabel") as Label
		var social_no_signal_group := social_no_signal_icon.get_parent() if social_no_signal_icon != null else null
		var social_search_bar := _find_node_by_name(root, "SocialSearchBar") as PanelContainer
		var social_refresh_button := _find_node_by_name(root, "SocialRefreshButton") as Button
		var social_channel_tabs := _find_node_by_name(root, "SocialChannelTabs") as HBoxContainer
		var social_channel_tab_discover := _find_node_by_name(root, "SocialChannelTab发现") as Button
		var social_channel_tab_tower := _find_node_by_name(root, "SocialChannelTab塔下") as Button
		var social_channel_tab_underline_discover := _find_node_by_name(root, "SocialChannelTabUnderline发现") as ColorRect
		var social_home_page := _find_node_by_name(root, "SocialHomePage") as VBoxContainer
		var social_feed_scroll := _find_node_by_name(root, "SocialFeedScroll") as ScrollContainer
		var social_feed_masonry := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
		var social_masonry_column_0 := _find_node_by_name(root, "SocialMasonryColumn0") as VBoxContainer
		var social_masonry_column_1 := _find_node_by_name(root, "SocialMasonryColumn1") as VBoxContainer
		var social_publish_page := _find_node_by_name(root, "SocialPublishPage") as VBoxContainer
		var social_publish_composer := _find_node_by_name(root, "SocialPublishComposer") as PanelContainer
		var social_post_detail_page := _find_node_by_name(root, "SocialPostDetailPage") as VBoxContainer
		var social_profile_page := _find_node_by_name(root, "SocialProfilePage") as VBoxContainer
		var social_bottom_nav := _find_node_by_name(root, "SocialBottomNav") as HBoxContainer
		var social_nav_home := _find_node_by_name(root, "SocialNavHome") as Button
		var social_nav_create := _find_node_by_name(root, "SocialNavCreate") as Button
		var social_nav_mine := _find_node_by_name(root, "SocialNavMine") as Button
		var social_home_indicator := _find_node_by_name(root, "SocialHomeIndicator") as ColorRect
		var social_post_card := _find_node_by_name(root, "SocialPostCard0") as PanelContainer
		var social_post_card_1 := _find_node_by_name(root, "SocialPostCard1") as PanelContainer
		var social_post_card_4 := _find_node_by_name(root, "SocialPostCard4") as PanelContainer
		var social_post_poster := _find_node_by_name(root, "SocialPostPoster0") as PanelContainer
		var social_post_caption := _find_node_by_name(root, "SocialPostCaption0") as Label
		var social_post_caption_1 := _find_node_by_name(root, "SocialPostCaption1") as Label
		var social_post_meta_likes := _find_node_by_name(root, "SocialPostMetaLikes0") as Label
		var social_post_texture := _find_node_by_name(root, "SocialPostTexture0") as TextureRect
		var social_post_open := _find_node_by_name(root, "SocialPostOpen0") as Button
		var social_detail_window := _find_node_by_name(root, "SocialDetailWindow") as PanelContainer
		var social_detail_close := _find_node_by_name(root, "SocialDetailWindowCloseButton") as Button
		var social_scroll_hint := _find_node_by_name(root, "SocialScrollHint") as Label
		var external_publish_panel := _find_node_by_name(root, "PublishPanel") as PanelContainer
		var flashback_overlay := root.get_node_or_null("CanvasLayer/UIRoot/PollutionFlashbackOverlay") as Control
		var npc_bubble := root.get_node_or_null("CanvasLayer/UIRoot/NPCChatBubble") as PanelContainer
		var dim_overlay := root.get_node_or_null("CanvasLayer/UIRoot/RealityDimOverlay") as ColorRect
		var npc_focus_image := root.get_node_or_null("CanvasLayer/UIRoot/NPCFocusImage") as TextureRect
		var player_portrait := root.get_node_or_null("CanvasLayer/UIRoot/PlayerPortrait") as Control
		var thought_layer := root.get_node_or_null("CanvasLayer/UIRoot/ThoughtWordLayer") as Control
		var thought_flow := _find_node_by_name(root, "RealityThoughtFlow") as HFlowContainer
		var puzzle_frame := root.get_node_or_null("CanvasLayer/UIRoot/LanguagePuzzleFrame") as PanelContainer
		var confirm_reality_button := _find_node_by_text(root, "尽量正常地说出口") as Button
		var meme_bank_popup := _find_node_by_name(root, "MemeBankPopup") as PanelContainer
		var meme_bank_tab := _find_node_by_name(root, "MemeBankTab") as Button
		var meme_bank_drag_handle := _find_node_by_name(root, "MemeBankDragHandle") as Label
		var meme_bank_content := _find_node_by_name(root, "MemeBankContent") as Control
		_assert_true(legacy_status_bar == null, "legacy top status bar should be removed")
		_assert_true(camera != null, "scene should expose a camera for low/high view transitions")
		if camera != null and root.has_method("_animate_world"):
			root._animate_world(0.35)
			_assert_true(camera.rotation_degrees.x < -35.0, "phone-down view should tilt the 3D camera downward toward the phone")
		_assert_true(road_tile != null, "scene should expose a road tile")
		if road_tile != null:
			var road_mat := road_tile.material_override as StandardMaterial3D
			_assert_true(road_mat != null and road_mat.albedo_texture != null, "road tile should use generated road texture")
			_assert_true(phone_down_backdrop_image != null, "phone-down view should expose the generated road-and-phone backdrop")
			if phone_down_backdrop_image != null:
				_assert_true(phone_down_backdrop_image.texture != null, "phone-down backdrop should be loaded as a texture")
				_assert_eq(str(phone_down_backdrop_image.get_meta("asset_path", "")), "res://assets/generated/world/phone_down_backdrop.png", "phone-down backdrop should use the generated reference-style road asset")
				_assert_true(phone_down_backdrop_image.visible, "phone-down view should show the generated backdrop artwork")
				_assert_eq(phone_down_backdrop_image.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_COVERED, "phone-down backdrop should fill the viewport")
			_assert_true(hand_phone_image != null, "phone-down view should expose generated hand and phone artwork")
			if hand_phone_image != null:
				_assert_true(hand_phone_image.texture != null, "hand and phone artwork should be loaded as a texture")
				_assert_eq(str(hand_phone_image.get_meta("asset_path", "")), "res://assets/generated/world/hand_phone_down.png", "foreground hand-phone layer should use the transparent generated hand asset")
				_assert_true(hand_phone_image.visible, "phone-down view should show the generated hand and phone artwork")
				_assert_eq(hand_phone_image.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "foreground hand-phone artwork should keep its generated proportions")
				if hand_phone_image.texture != null:
					_assert_eq(hand_phone_image.texture.get_width(), 1280, "hand-phone artwork should be generated at the full gameplay viewport width")
					_assert_eq(hand_phone_image.texture.get_height(), 720, "hand-phone artwork should be generated at the full gameplay viewport height")
			if phone_rig != null:
				_assert_true(not phone_rig.visible, "generated hand-phone art should replace the old low-view 3D phone rig")
		_assert_true(npc_plane != null, "scene should expose NPC plane")
		if npc_plane != null:
			var npc_mat := npc_plane.material_override as StandardMaterial3D
			_assert_true(npc_mat != null and npc_mat.albedo_texture != null, "NPC plane should use generated NPC texture")
		_assert_true(apple_hud == null, "old Apple HUD panel should be removed")
		_assert_true(international_hud != null, "scene should expose an International-style icon HUD rail")
		_assert_true(hud_title == null, "HUD should not show the BABEL PHONE title")
		_assert_true(hud_subtitle == null, "HUD should not show the Babel subtitle")
		_assert_true(hud_actions_label != null, "left HUD should expose an independent actions label")
		_assert_true(hud_day_value == null, "day value should not be permanently visible in the HUD rail")
		_assert_true(hud_heat_value == null, "heat value should not be in the global HUD rail")
		_assert_true(hud_pollution_value == null, "pollution value should only appear in the HUD tooltip")
		_assert_true(hud_clarity_value == null, "clarity value should not be in the global HUD rail")
		_assert_true(hud_floor_value == null, "tower floor should not be in the global HUD rail")
		_assert_true(hud_money_value == null, "money value should only appear in the HUD tooltip")
		_assert_true(hud_day_icon != null, "HUD rail should expose a day icon")
		_assert_true(hud_pollution_icon != null, "HUD rail should expose a pollution icon")
		_assert_true(hud_money_icon != null, "HUD rail should expose a money icon")
		_assert_true(hud_settings_icon != null, "HUD rail should expose a settings icon")
		_assert_true(hud_tooltip != null, "HUD rail should expose a hover/click tooltip")
		_assert_true(hud_tooltip_label != null, "HUD tooltip should expose a value label")
		_assert_true(settings_window != null, "settings icon should have a settings window")
		_assert_true(settings_close != null, "settings window should expose a close button")
		if settings_close != null:
			_assert_true(settings_close.custom_minimum_size.x >= 56.0 and settings_close.custom_minimum_size.y >= 56.0, "settings close button should be easy to tap")
		_assert_true(settings_volume != null, "settings window should expose a volume slider")
		_assert_true(settings_vhs_toggle != null, "settings window should expose a VHS toggle")
		_assert_true(settings_return_main != null, "settings window should expose a return to main menu button")
		_assert_true(vhs_overlay != null, "scene should expose a VHS overlay")
		_assert_true(vhs_tint != null, "VHS overlay should include a global tint layer")
		_assert_true(vhs_side_noise != null, "VHS overlay should include side signal noise")
		if vhs_overlay != null:
			_assert_true(vhs_overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "VHS overlay should never block UI clicks")
			_assert_true(_count_nodes_named_prefix(vhs_overlay, "VHSScanline") >= 34, "VHS overlay should include enough scanlines to read as analog video")
		_assert_true(view_toggle_button != null, "scene should expose a fixed take/put phone button")
		_assert_true(action_overlay != null, "scene should expose the action spend overlay")
		_assert_true(action_blackout == null, "action spend animation should not include a black fullscreen background")
		_assert_true(action_label != null, "action spend overlay should animate the actions text itself")
		if international_hud != null:
			_assert_true(international_hud.offset_left <= 32.0, "International HUD should sit on the left side")
			_assert_true((international_hud.offset_right - international_hud.offset_left) <= 190.0, "International HUD should stay narrow and icon-led")
		if settings_window != null and root.has_method("_toggle_settings_window"):
			_assert_true(not settings_window.visible, "settings window should start closed")
			if hud_settings_icon != null:
				_assert_true(hud_settings_icon.icon != null, "settings HUD icon should use generated icon art")
				hud_settings_icon.pressed.emit()
			else:
				root._toggle_settings_window()
			_assert_true(settings_window.visible, "settings icon should open the settings window")
			if settings_volume != null:
				settings_volume.value = 35
				settings_volume.value_changed.emit(settings_volume.value)
				_assert_eq(int(root._master_volume), 35, "settings volume slider should update the master volume value")
			if vhs_overlay != null and root.has_method("_on_vhs_toggled"):
				_assert_true(vhs_overlay.visible, "VHS overlay should start enabled")
				root._on_vhs_toggled(false)
				_assert_true(not vhs_overlay.visible, "turning off VHS should hide the overlay")
				root._on_vhs_toggled(true)
				_assert_true(vhs_overlay.visible, "turning on VHS should show the overlay")
			if settings_close != null:
				settings_close.pressed.emit()
				_assert_true(not settings_window.visible, "settings close should hide the settings window")
			if hud_settings_icon != null and settings_return_main != null:
				hud_settings_icon.pressed.emit()
				settings_return_main = _find_node_by_name(root, "SettingsReturnMainButton") as Button
				if settings_return_main != null:
					settings_return_main.pressed.emit()
					await process_frame
					var returned_menu := _find_node_by_name(root, "MainMenuLayer") as Control
					_assert_true(returned_menu != null and returned_menu.visible, "settings return button should go back to the main menu")
					_assert_true(_find_node_by_name(root, "InternationalHUDRail") == null, "returning to main menu should remove gameplay HUD")
					root.new_game()
					international_hud = _find_node_by_name(root, "InternationalHUDRail") as PanelContainer
					hud_settings_icon = _find_node_by_name(root, "HUDSettingsIcon") as Button
					view_toggle_button = _find_node_by_name(root, "PhoneViewToggleButton") as Button
					hud_actions_label = _find_node_by_name(root, "HUDActionsLabel") as Label
					action_overlay = root.get_node_or_null("CanvasLayer/UIRoot/ActionSpendOverlay") as Control
					action_label = root.get_node_or_null("CanvasLayer/UIRoot/ActionSpendOverlay/ActionSpendLabel") as Label
					phone_popup = _find_node_by_name(root, "PhonePopup") as PanelContainer
					phone_tab = _find_node_by_name(root, "PhoneTab") as Button
					phone_content = _find_node_by_name(root, "PhoneContent") as Control
					phone_app_babel = _find_node_by_name(root, "PhoneAppIconBabel") as Button
					phone_app_social = _find_node_by_name(root, "PhoneAppIconSocial") as Button
					phone_app_shop = _find_node_by_name(root, "PhoneAppIconShop") as Button
					phone_app_notebook = _find_node_by_name(root, "PhoneAppIconNotebook") as Button
					babel_app_window = _find_node_by_name(root, "BabelAppWindow") as PanelContainer
					social_app_window = _find_node_by_name(root, "SocialAppWindow") as PanelContainer
					shop_app_window = _find_node_by_name(root, "ShopAppWindow") as PanelContainer
					notebook_app_window = _find_node_by_name(root, "NotebookAppWindow") as PanelContainer
					phone_handle = _find_node_by_name(root, "PhoneWindowHandle") as Label
					babel_handle = _find_node_by_name(root, "BabelAppWindowHandle") as Label
					shop_handle = _find_node_by_name(root, "ShopAppWindowHandle") as Label
					notebook_handle = _find_node_by_name(root, "NotebookAppWindowHandle") as Label
					babel_close = _find_node_by_name(root, "BabelAppWindowCloseButton") as Button
					social_close = _find_node_by_name(root, "SocialAppWindowCloseButton") as Button
					shop_close = _find_node_by_name(root, "ShopAppWindowCloseButton") as Button
					notebook_close = _find_node_by_name(root, "NotebookAppWindowCloseButton") as Button
					social_phone_view = _find_node_by_name(root, "SocialPhoneView") as PanelContainer
					social_status_bar = _find_node_by_name(root, "SocialPhoneStatusBar") as HBoxContainer
					social_inline_close = _find_node_by_name(root, "SocialAppInlineCloseButton") as Button
					social_no_signal_icon = _find_node_by_name(root, "SocialNoSignalIcon") as TextureRect
					social_no_signal_label = _find_node_by_name(root, "SocialNoSignalLabel") as Label
					social_no_signal_group = social_no_signal_icon.get_parent() if social_no_signal_icon != null else null
					social_search_bar = _find_node_by_name(root, "SocialSearchBar") as PanelContainer
					social_refresh_button = _find_node_by_name(root, "SocialRefreshButton") as Button
					social_channel_tabs = _find_node_by_name(root, "SocialChannelTabs") as HBoxContainer
					social_channel_tab_discover = _find_node_by_name(root, "SocialChannelTab发现") as Button
					social_channel_tab_tower = _find_node_by_name(root, "SocialChannelTab塔下") as Button
					social_channel_tab_underline_discover = _find_node_by_name(root, "SocialChannelTabUnderline发现") as ColorRect
					social_home_page = _find_node_by_name(root, "SocialHomePage") as VBoxContainer
					social_feed_scroll = _find_node_by_name(root, "SocialFeedScroll") as ScrollContainer
					social_feed_masonry = _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
					social_masonry_column_0 = _find_node_by_name(root, "SocialMasonryColumn0") as VBoxContainer
					social_masonry_column_1 = _find_node_by_name(root, "SocialMasonryColumn1") as VBoxContainer
					social_publish_page = _find_node_by_name(root, "SocialPublishPage") as VBoxContainer
					social_publish_composer = _find_node_by_name(root, "SocialPublishComposer") as PanelContainer
					social_post_detail_page = _find_node_by_name(root, "SocialPostDetailPage") as VBoxContainer
					social_profile_page = _find_node_by_name(root, "SocialProfilePage") as VBoxContainer
					social_bottom_nav = _find_node_by_name(root, "SocialBottomNav") as HBoxContainer
					social_nav_home = _find_node_by_name(root, "SocialNavHome") as Button
					social_nav_create = _find_node_by_name(root, "SocialNavCreate") as Button
					social_nav_mine = _find_node_by_name(root, "SocialNavMine") as Button
					social_home_indicator = _find_node_by_name(root, "SocialHomeIndicator") as ColorRect
					social_post_card = _find_node_by_name(root, "SocialPostCard0") as PanelContainer
					social_post_card_1 = _find_node_by_name(root, "SocialPostCard1") as PanelContainer
					social_post_card_4 = _find_node_by_name(root, "SocialPostCard4") as PanelContainer
					social_post_poster = _find_node_by_name(root, "SocialPostPoster0") as PanelContainer
					social_post_caption = _find_node_by_name(root, "SocialPostCaption0") as Label
					social_post_caption_1 = _find_node_by_name(root, "SocialPostCaption1") as Label
					social_post_meta_likes = _find_node_by_name(root, "SocialPostMetaLikes0") as Label
					social_post_texture = _find_node_by_name(root, "SocialPostTexture0") as TextureRect
					social_post_open = _find_node_by_name(root, "SocialPostOpen0") as Button
					social_detail_window = _find_node_by_name(root, "SocialDetailWindow") as PanelContainer
					social_detail_close = _find_node_by_name(root, "SocialDetailWindowCloseButton") as Button
					social_scroll_hint = _find_node_by_name(root, "SocialScrollHint") as Label
					external_publish_panel = _find_node_by_name(root, "PublishPanel") as PanelContainer
					flashback_overlay = root.get_node_or_null("CanvasLayer/UIRoot/PollutionFlashbackOverlay") as Control
					npc_bubble = root.get_node_or_null("CanvasLayer/UIRoot/NPCChatBubble") as PanelContainer
					dim_overlay = root.get_node_or_null("CanvasLayer/UIRoot/RealityDimOverlay") as ColorRect
					npc_focus_image = root.get_node_or_null("CanvasLayer/UIRoot/NPCFocusImage") as TextureRect
					player_portrait = root.get_node_or_null("CanvasLayer/UIRoot/PlayerPortrait") as Control
					thought_layer = root.get_node_or_null("CanvasLayer/UIRoot/ThoughtWordLayer") as Control
					thought_flow = _find_node_by_name(root, "RealityThoughtFlow") as HFlowContainer
					puzzle_frame = root.get_node_or_null("CanvasLayer/UIRoot/LanguagePuzzleFrame") as PanelContainer
					confirm_reality_button = _find_node_by_text(root, "尽量正常地说出口") as Button
					meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as PanelContainer
					meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
					meme_bank_drag_handle = _find_node_by_name(root, "MemeBankDragHandle") as Label
					meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
		if view_toggle_button != null:
			_assert_true(view_toggle_button.visible, "take/put phone button should be visible during gameplay")
			_assert_true(str(view_toggle_button.text).contains("放下手机"), "phone-down view should expose a put-phone button")
			_assert_true(view_toggle_button.offset_right <= 620.0, "put-phone button should sit outside the main phone window instead of being covered by it")
		if hud_actions_label != null:
			_assert_true(str(hud_actions_label.text).contains("今日行动"), "HUD actions label should use the new action copy")
			_assert_true(str(hud_actions_label.text).contains("●●●●●"), "HUD actions label should start with five available action dots")
			_assert_eq(str(hud_actions_label.get_meta("action_animation_mode", "")), "inline_pulse", "action spend animation should be an inline pulse")
		if action_overlay != null:
			_assert_true(not action_overlay.visible, "action spend overlay should start hidden")
		if root.has_method("_play_action_spend_animation") and root.has_method("_finish_action_spend_animation") and action_overlay != null and action_label != null:
			root._play_action_spend_animation(5, 4)
			_assert_true(not action_overlay.visible, "playing action spend animation should not show a fullscreen overlay")
			_assert_true(str(hud_actions_label.text).contains("●●●●●"), "action spend pulse should begin with the before-spend dots")
			root._finish_action_spend_animation()
			_assert_true(not action_overlay.visible, "finishing action spend animation should hide the overlay")
			_assert_true(str(hud_actions_label.text).contains("●●●●○"), "finishing action spend animation should leave HUD with the after-spend dots")
			phone_popup = _find_node_by_name(root, "PhonePopup") as PanelContainer
			phone_tab = _find_node_by_name(root, "PhoneTab") as Button
			phone_content = _find_node_by_name(root, "PhoneContent") as Control
			babel_app_window = _find_node_by_name(root, "BabelAppWindow") as PanelContainer
			social_app_window = _find_node_by_name(root, "SocialAppWindow") as PanelContainer
			shop_app_window = _find_node_by_name(root, "ShopAppWindow") as PanelContainer
			notebook_app_window = _find_node_by_name(root, "NotebookAppWindow") as PanelContainer
			phone_handle = _find_node_by_name(root, "PhoneWindowHandle") as Label
			babel_handle = _find_node_by_name(root, "BabelAppWindowHandle") as Label
			shop_handle = _find_node_by_name(root, "ShopAppWindowHandle") as Label
			notebook_handle = _find_node_by_name(root, "NotebookAppWindowHandle") as Label
			babel_close = _find_node_by_name(root, "BabelAppWindowCloseButton") as Button
			social_close = _find_node_by_name(root, "SocialAppWindowCloseButton") as Button
			shop_close = _find_node_by_name(root, "ShopAppWindowCloseButton") as Button
			notebook_close = _find_node_by_name(root, "NotebookAppWindowCloseButton") as Button
			social_phone_view = _find_node_by_name(root, "SocialPhoneView") as PanelContainer
			social_status_bar = _find_node_by_name(root, "SocialPhoneStatusBar") as HBoxContainer
			social_inline_close = _find_node_by_name(root, "SocialAppInlineCloseButton") as Button
			social_no_signal_icon = _find_node_by_name(root, "SocialNoSignalIcon") as TextureRect
			social_no_signal_label = _find_node_by_name(root, "SocialNoSignalLabel") as Label
			social_no_signal_group = social_no_signal_label.get_parent() as HBoxContainer if social_no_signal_label != null else null
			social_search_bar = _find_node_by_name(root, "SocialSearchBar") as PanelContainer
			social_refresh_button = _find_node_by_name(root, "SocialRefreshButton") as Button
			social_channel_tabs = _find_node_by_name(root, "SocialChannelTabs") as HBoxContainer
			social_channel_tab_discover = _find_node_by_name(root, "SocialChannelTab发现") as Button
			social_channel_tab_tower = _find_node_by_name(root, "SocialChannelTab塔下") as Button
			social_channel_tab_underline_discover = _find_node_by_name(root, "SocialChannelTabUnderline发现") as ColorRect
			social_home_page = _find_node_by_name(root, "SocialHomePage") as VBoxContainer
			social_feed_scroll = _find_node_by_name(root, "SocialFeedScroll") as ScrollContainer
			social_feed_masonry = _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
			social_masonry_column_0 = _find_node_by_name(root, "SocialMasonryColumn0") as VBoxContainer
			social_masonry_column_1 = _find_node_by_name(root, "SocialMasonryColumn1") as VBoxContainer
			social_publish_page = _find_node_by_name(root, "SocialPublishPage") as VBoxContainer
			social_publish_composer = _find_node_by_name(root, "SocialPublishComposer") as PanelContainer
			social_post_detail_page = _find_node_by_name(root, "SocialPostDetailPage") as VBoxContainer
			social_profile_page = _find_node_by_name(root, "SocialProfilePage") as VBoxContainer
			social_bottom_nav = _find_node_by_name(root, "SocialBottomNav") as HBoxContainer
			social_nav_home = _find_node_by_name(root, "SocialNavHome") as Button
			social_nav_create = _find_node_by_name(root, "SocialNavCreate") as Button
			social_nav_mine = _find_node_by_name(root, "SocialNavMine") as Button
			social_home_indicator = _find_node_by_name(root, "SocialHomeIndicator") as ColorRect
			social_post_card = _find_node_by_name(root, "SocialPostCard0") as PanelContainer
			social_post_card_1 = _find_node_by_name(root, "SocialPostCard1") as PanelContainer
			social_post_card_4 = _find_node_by_name(root, "SocialPostCard4") as PanelContainer
			social_post_poster = _find_node_by_name(root, "SocialPostPoster0") as PanelContainer
			social_post_caption = _find_node_by_name(root, "SocialPostCaption0") as Label
			social_post_caption_1 = _find_node_by_name(root, "SocialPostCaption1") as Label
			social_post_meta_likes = _find_node_by_name(root, "SocialPostMetaLikes0") as Label
			social_post_texture = _find_node_by_name(root, "SocialPostTexture0") as TextureRect
			social_post_open = _find_node_by_name(root, "SocialPostOpen0") as Button
			social_detail_window = _find_node_by_name(root, "SocialDetailWindow") as PanelContainer
			social_detail_close = _find_node_by_name(root, "SocialDetailWindowCloseButton") as Button
			social_scroll_hint = _find_node_by_name(root, "SocialScrollHint") as Label
			external_publish_panel = _find_node_by_name(root, "PublishPanel") as PanelContainer
			meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as PanelContainer
			meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
			meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
			view_toggle_button = _find_node_by_name(root, "PhoneViewToggleButton") as Button
		_assert_true(phone_popup != null, "scene should expose an integrated phone popup")
		_assert_true(phone_tab != null, "phone tab should live inside the integrated phone popup")
		_assert_true(phone_content != null, "phone popup should expose expandable phone content")
		_assert_true(babel_app_window != null, "scene should expose a separate Babel app window")
		_assert_true(social_app_window != null, "scene should expose a separate social app window")
		_assert_true(social_drag_bar == null, "social app should not waste vertical space on an extra outer drag bar")
		_assert_true(shop_app_window != null, "scene should expose a separate shop app window")
		_assert_true(notebook_app_window != null, "scene should expose a separate notebook app window")
		_assert_true(babel_close != null, "Babel app window should expose a close button")
		_assert_true(social_inline_close != null, "social app window should expose an in-phone close button")
		_assert_true(shop_close != null, "shop app window should expose a close button")
		_assert_true(notebook_close != null, "notebook app window should expose a close button")
		for handle in [phone_handle, babel_handle, shop_handle, notebook_handle, social_status_bar]:
			if handle != null:
				_assert_true(handle.has_meta("drag_handle"), "visible window title/status text should be directly draggable")
		for close_button in [babel_close, social_inline_close, shop_close, notebook_close]:
			if close_button != null:
				_assert_true(close_button.custom_minimum_size.x >= 56.0 and close_button.custom_minimum_size.y >= 56.0, "window close buttons should use comfortable 56px touch targets")
		_assert_true(social_phone_view != null, "social app should render as a phone app viewport")
		_assert_true(social_status_bar != null, "social app should include a phone-style status bar")
		if social_status_bar != null:
			_assert_true(social_status_bar.has_meta("drag_handle"), "social phone status bar should be the visible drag handle")
			_assert_true(social_status_bar.custom_minimum_size.y >= 60.0, "social phone status bar should leave enough draggable area beside the close button")
		_assert_true(social_inline_close != null, "social app should expose a visible in-phone close button")
		if social_inline_close != null:
			_assert_true(social_inline_close.custom_minimum_size.x >= 44.0 and social_inline_close.custom_minimum_size.y >= 44.0, "social in-phone close button should be easy to click")
		_assert_true(social_no_signal_icon != null, "social app status bar should show a no-signal icon")
		_assert_true(social_no_signal_label != null, "social app status bar should show no-signal text")
		if social_no_signal_label != null:
			_assert_true(str(social_no_signal_label.text).contains("无信号"), "social status should say no signal")
			if social_no_signal_label != null and social_no_signal_group != null:
				_assert_true(_is_descendant_of(social_no_signal_label, social_no_signal_group), "no-signal text and icon should be grouped together")
			_assert_true(not _has_text(root, "BABEL SIGNAL"), "social status should not show Babel signal copy")
			_assert_true(not _has_text(root, "5G"), "social status should not show 5G")
			_assert_true(not _has_text(root, "83%"), "social status should not show battery percentage")
			_assert_true(social_search_bar == null, "social app should not include the removed search bar")
			_assert_true(social_refresh_button == null, "social app should remove refresh and rely on downward browsing")
			_assert_true(social_channel_tabs != null, "social app should include mobile channel tabs")
			_assert_true(social_channel_tab_discover != null, "social app should expose a Discover channel tab")
			_assert_true(social_channel_tab_tower != null, "social app should expose a Tower channel tab")
			if social_channel_tab_discover != null:
				_assert_true(social_channel_tab_discover.custom_minimum_size.y >= 44.0, "Discover tab should meet minimum touch target height")
			if social_channel_tab_tower != null:
				_assert_true(social_channel_tab_tower.custom_minimum_size.y >= 44.0, "Tower tab should meet minimum touch target height")
			_assert_true(social_channel_tab_underline_discover != null and social_channel_tab_underline_discover.visible, "Discover tab should use a reference-like active underline")
			_assert_true(social_home_page != null, "social app should default to a home page")
			_assert_true(social_feed_scroll != null, "social app should include an internal feed scroll area")
			_assert_true(social_feed_masonry != null, "social app should render a Xiaohongshu/Pinterest-like masonry feed")
			_assert_true(social_masonry_column_0 != null and social_masonry_column_1 != null, "social masonry should be built from two staggered columns")
			_assert_true(social_publish_page == null, "social app should not show publish page on home")
			_assert_true(social_publish_composer == null, "social app should not put the publish composer on home")
			_assert_true(social_post_detail_page == null, "default social view should not show a detail page until Tower or a post is opened")
			_assert_true(social_profile_page == null, "social app should not show profile page on home")
			_assert_true(social_bottom_nav != null, "social app should include a bottom navigation bar")
			_assert_true(social_nav_home != null, "social bottom nav should expose a home button")
			_assert_true(social_nav_create != null, "social bottom nav should expose a create button")
			_assert_true(social_nav_mine != null, "social bottom nav should expose a profile button")
			_assert_true(social_home_indicator != null, "social app should include a phone home indicator")
			_assert_true(social_post_card != null, "social app should render post cards inside its feed grid")
			_assert_true(social_post_card_4 != null, "social masonry feed should render enough cards to imply downward scrolling")
			_assert_true(social_post_poster != null, "social post cards should expose a poster-like thumbnail area")
			_assert_true(social_post_texture != null, "social post cards should use generated poster textures")
			if social_post_texture != null:
				_assert_true(social_post_texture.texture != null, "social post texture should load generated poster art")
			_assert_true(social_post_caption != null, "social post cards should expose a short caption")
			_assert_true(social_post_meta_likes != null and str(social_post_meta_likes.text).contains("♡"), "social post cards should show reference-like engagement counts")
			_assert_true(social_post_open == null, "social post cards should not use a separate enter button")
			if social_channel_tab_tower != null and social_app_window != null:
				social_channel_tab_tower.pressed.emit()
				var tower_detail_page := _find_node_by_name(root, "SocialPostDetailPage") as VBoxContainer
				var tower_feed := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
				var tower_detail_window := _find_node_by_name(root, "SocialDetailWindow") as PanelContainer
				_assert_true(tower_detail_page != null, "pressing Tower should open the secondary detail page")
				_assert_true(tower_feed == null, "Tower secondary page should replace the feed inside the same phone")
				_assert_true(tower_detail_window == null, "pressing Tower should not create a second phone window")
				if tower_detail_page != null:
					_assert_true(_is_descendant_of(tower_detail_page, social_app_window), "Tower page should stay inside the main social phone")
				var discover_after_tower := _find_node_by_name(root, "SocialChannelTab发现") as Button
				if discover_after_tower != null:
					discover_after_tower.pressed.emit()
		if social_post_card != null:
			_assert_true(social_post_card.mouse_filter == Control.MOUSE_FILTER_STOP, "social post cards should be directly clickable")
			_assert_true(social_detail_window == null, "social post details should not create a second floating phone window")
			_assert_true(social_detail_close == null, "social detail should use the in-app back button instead of a second-window close button")
			if social_app_window != null:
				_assert_true(social_app_window.has_meta("phone_shell"), "social app window should use the thick phone-shell style")
				_assert_true(not social_app_window.has_meta("drag_handle"), "social app body should not be the drag handle because it steals phone interactions")
			if social_phone_view != null:
				_assert_true(social_phone_view.has_meta("phone_surface"), "social app content should use a phone-surface style")
				if social_post_card != null:
					_assert_true(social_post_card.has_meta("social_card"), "social feed cards should use image-first social card styling")
				if social_channel_tab_discover != null:
					_assert_true(social_channel_tab_discover.has_meta("flat_phone_button"), "channel tabs should be flat text buttons instead of boxed app buttons")
				if social_nav_home != null:
					_assert_true(social_nav_home.has_meta("flat_phone_button"), "bottom navigation should be flat text buttons instead of boxed app buttons")
			_assert_true(social_scroll_hint != null, "social feed should include a downward-browsing hint")
		_assert_true(external_publish_panel == null, "publish blank should no longer be a separate desktop panel")
		_assert_true(flashback_overlay != null, "scene should expose a full-screen pollution flashback overlay")
		_assert_true(npc_bubble != null, "scene should expose the NPC chat bubble")
		_assert_true(dim_overlay != null, "scene should expose the reality dim overlay")
		_assert_true(npc_focus_image != null, "player composing should expose a bright NPC focus layer above the dim overlay")
		_assert_true(player_portrait != null, "scene should expose the player portrait")
		_assert_true(thought_layer != null, "scene should expose the thought word layer")
		_assert_true(thought_flow != null, "thought words should use a wrapping flow container")
		_assert_true(puzzle_frame != null, "scene should expose the Florence-style language puzzle frame")
		_assert_true(meme_bank_popup != null, "scene should expose an integrated meme bank popup")
		_assert_true(meme_bank_tab != null, "meme bank tab should live inside the integrated popup")
		_assert_true(meme_bank_drag_handle != null, "meme bank popup should expose a separate drag handle instead of relying on the toggle button")
		_assert_true(meme_bank_content != null, "meme bank popup should expose collapsible content")
		if meme_bank_drag_handle != null:
			_assert_true(meme_bank_drag_handle.has_meta("drag_handle"), "meme bank drag handle should move the whole drawer")
		if phone_popup != null and phone_tab != null and phone_content != null:
			var phone_width := phone_popup.offset_right - phone_popup.offset_left
			var phone_height := phone_popup.offset_bottom - phone_popup.offset_top
			_assert_true(_is_descendant_of(phone_tab, phone_popup), "phone tab and phone content should be one popup object")
			_assert_true(_is_descendant_of(phone_content, phone_popup), "phone content should expand from the integrated phone popup")
			_assert_true(not phone_popup.visible, "phone launcher should stay hidden while the main social phone is already open")
			_assert_true(not phone_tab.visible, "collapsed phone tab should be hidden while the phone is open")
			_assert_true(not phone_content.visible, "phone launcher content should not overlap the main social phone")
			_assert_true(phone_width >= 280.0 and phone_height >= 500.0, "open phone should be large enough to read as a proportional phone")
			_assert_true(phone_width >= 420.0, "open phone launcher should not compress the app icon grid")
			_assert_true(phone_height / maxf(1.0, phone_width) >= 1.45, "open phone should keep a tall smartphone aspect ratio")
			_assert_true(phone_height / maxf(1.0, phone_width) <= 2.05, "open phone should not be stretched beyond phone proportions")
		if social_inline_close != null and social_app_window != null and phone_popup != null and phone_content != null:
			social_inline_close.pressed.emit()
			_assert_true(not social_app_window.visible, "closing social app should hide the social app window")
			_assert_true(phone_popup.visible, "closing the only open app should return to the phone home shell")
			_assert_true(phone_content.visible, "closing social app should reveal the phone app icon home screen")
			for icon_button in [phone_app_babel, phone_app_social, phone_app_shop, phone_app_notebook]:
				_assert_true(icon_button != null and icon_button.visible, "phone home should show every app icon after closing social")
				if icon_button != null:
					_assert_true(icon_button.custom_minimum_size.x >= 140.0 and icon_button.custom_minimum_size.y >= 90.0, "phone app icons should be large enough to tap without cramping")
			_assert_eq(str(root.game.active_app_window), "", "closing the final social app should clear the active app window")
			root._on_app_pressed("social")
		if social_app_window != null and babel_app_window != null and shop_app_window != null and notebook_app_window != null:
			_assert_true(social_app_window.visible, "default social app should open in its own window")
			root._on_app_pressed("babel")
			root._on_app_pressed("shop")
			_assert_true(social_app_window.visible, "previous app window should remain open when another app opens")
			_assert_true(babel_app_window.visible, "Babel app should open in its own window")
			_assert_true(shop_app_window.visible, "shop app should open in its own window")
			_assert_true(notebook_app_window != social_app_window, "notebook app should be an independent window node")
			if social_app_window != null and social_feed_masonry != null:
				var social_width := social_app_window.offset_right - social_app_window.offset_left
				var social_height := social_app_window.offset_bottom - social_app_window.offset_top
				var current_social_feed_masonry := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
				_assert_true(social_width >= 580.0, "social app window should be wide enough that the masonry content is not cramped")
				_assert_true(social_width <= 660.0, "social app window should stay close to the large reference-phone proportions")
				_assert_true(social_height >= 700.0, "social app window should be tall enough to read as a phone screen")
				_assert_true(social_height / maxf(1.0, social_width) >= 1.08, "social app window should keep a vertical mobile composition without squeezing content")
				_assert_true(1280.0 + social_app_window.offset_left >= 600.0, "main social phone should sit in the right half like the reference layout")
				_assert_true(current_social_feed_masonry != null and _is_descendant_of(current_social_feed_masonry, social_app_window), "social feed grid should live inside the social app window")
		if social_bottom_nav != null and social_feed_scroll != null:
			_assert_true(not _is_descendant_of(social_bottom_nav, social_feed_scroll), "bottom nav should not scroll away with the feed")
			_assert_true(int(social_feed_scroll.get_meta("slow_scroll_step", 0)) <= 4, "social feed wheel scroll should be slower for phone-style browsing")
			var wheel_event := InputEventMouseButton.new()
			wheel_event.button_index = MOUSE_BUTTON_WHEEL_DOWN
			wheel_event.pressed = true
			social_feed_scroll.scroll_vertical = 0
			root._on_social_feed_scroll_gui_input(wheel_event, social_feed_scroll)
			_assert_true(social_feed_scroll.scroll_vertical <= 4, "one wheel notch should move the masonry feed only a small amount")
			if social_feed_masonry != null:
				_assert_eq(social_feed_masonry.get_child_count(), 2, "mobile social feed should keep a two-column discovery layout")
		if social_post_card != null and social_post_card_1 != null:
			_assert_true(social_post_card.custom_minimum_size.y != social_post_card_1.custom_minimum_size.y, "masonry post cards should use staggered heights")
		if social_post_caption != null:
			_assert_true(str(social_post_caption.text).length() <= 24, "home feed captions should stay short")
		if social_post_caption != null and social_post_caption_1 != null:
			_assert_true(social_post_caption.text != social_post_caption_1.text, "home feed captions should not feel like repeated token excerpts")
		if root.has_method("_social_post_for_index"):
			_assert_true(str(root._social_post_for_index(0).get("text", "")) != str(root._social_post_for_index(1).get("text", "")), "social detail posts should vary per card instead of repeating the same two base posts")
			_assert_true(str(root._social_post_for_index(0).get("text", "")).length() <= 42, "social detail posts should stay short like image-led mobile notes")
			_assert_true(str(root._social_post_for_index(0).get("handle", "")) != str(root._social_post_for_index(1).get("handle", "")), "social post handles should vary across lifestyle-note styles")
			_assert_true(_unique_social_values(root, "text", 12) >= 10, "first twelve social detail posts should be varied")
			_assert_true(_unique_social_values(root, "handle", 12) >= 10, "first twelve social handles should be varied")
			_assert_true(str(root._social_post_for_index(0).get("text", "")).contains("："), "social detail posts should read like compact image-note captions")
		_assert_true(_generated_posters_are_varied(), "generated social poster images should not all be identical")
		if social_nav_home != null and social_nav_create != null and social_nav_mine != null:
			_assert_true(social_nav_home.custom_minimum_size.y >= 44.0, "home nav touch target should be at least 44px tall")
			_assert_true(social_nav_create.custom_minimum_size.y >= 44.0, "create nav touch target should be at least 44px tall")
			_assert_true(social_nav_mine.custom_minimum_size.y >= 44.0, "profile nav touch target should be at least 44px tall")
			var social_size_before_publish := social_app_window.size if social_app_window != null else Vector2.ZERO
			social_nav_create.pressed.emit()
			var publish_page_after_nav := _find_node_by_name(root, "SocialPublishPage") as VBoxContainer
			var composer_after_nav := _find_node_by_name(root, "SocialPublishComposer") as PanelContainer
			var publish_scroll_after_nav := _find_node_by_name(root, "SocialPublishScroll") as ScrollContainer
			var publish_action_bar_after_nav := _find_node_by_name(root, "SocialPublishActionBar") as PanelContainer
			var publish_button_after_nav := _find_node_by_name(root, "SocialPublishButton") as Button
			var feed_after_nav := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
			var inline_close_after_publish := _find_node_by_name(root, "SocialAppInlineCloseButton") as Button
			var bottom_nav_after_publish := _find_node_by_name(root, "SocialBottomNav") as HBoxContainer
			_assert_true(publish_page_after_nav != null, "publish nav should open a dedicated publish page")
			_assert_true(composer_after_nav != null, "dedicated publish page should contain the publish composer")
			_assert_true(publish_scroll_after_nav != null, "publish page should put expandable content inside an internal scroll area")
			_assert_true(publish_action_bar_after_nav != null, "publish page should expose a fixed action bar for confirmation")
			if composer_after_nav != null and publish_scroll_after_nav != null:
				_assert_true(_is_descendant_of(composer_after_nav, publish_scroll_after_nav), "publish composer should scroll inside the phone instead of stretching the phone")
			if publish_button_after_nav != null and publish_action_bar_after_nav != null and publish_scroll_after_nav != null:
				_assert_true(_is_descendant_of(publish_button_after_nav, publish_action_bar_after_nav), "confirm publish button should stay in the fixed publish action bar")
				_assert_true(not _is_descendant_of(publish_button_after_nav, publish_scroll_after_nav), "confirm publish button should not scroll away with publish content")
				_assert_true(publish_button_after_nav.custom_minimum_size.y >= 56.0, "confirm publish button should use a comfortable touch target")
			_assert_true(feed_after_nav == null, "publish page should not also show the feed grid")
			if social_app_window != null:
				_assert_eq(social_app_window.size, social_size_before_publish, "opening publish should not stretch the phone window")
			_assert_true(inline_close_after_publish != null and inline_close_after_publish.visible, "publish page should keep the social app close button clickable")
			_assert_true(bottom_nav_after_publish != null and bottom_nav_after_publish.visible, "publish page should keep bottom navigation clickable")
			var home_nav_after_publish := _find_node_by_name(root, "SocialNavHome") as Button
			if home_nav_after_publish != null:
				home_nav_after_publish.pressed.emit()
			var home_after_nav := _find_node_by_name(root, "SocialHomePage") as VBoxContainer
			var composer_after_home := _find_node_by_name(root, "SocialPublishComposer") as PanelContainer
			_assert_true(home_after_nav != null, "home nav should return to the home page")
			_assert_true(composer_after_home == null, "home page should not keep the publish composer visible")
			var mine_nav_after_home := _find_node_by_name(root, "SocialNavMine") as Button
			if mine_nav_after_home != null:
				mine_nav_after_home.pressed.emit()
			var profile_page_after_nav := _find_node_by_name(root, "SocialProfilePage") as VBoxContainer
			_assert_true(profile_page_after_nav != null, "profile nav should open a dedicated profile page")
			var home_nav_after_profile := _find_node_by_name(root, "SocialNavHome") as Button
			if home_nav_after_profile != null:
				home_nav_after_profile.pressed.emit()
			if root.has_method("_open_social_post"):
				root._open_social_post(0)
				var detail_after_card := _find_node_by_name(root, "SocialPostDetailPage") as VBoxContainer
				var back_from_detail := _find_node_by_name(root, "SocialBackToHome") as Button
				var feed_on_detail := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
				var detail_floor := _find_node_by_name(root, "SocialDetailTowerFloor") as Label
				var detail_media_texture := _find_node_by_name(root, "SocialDetailPostTexture") as TextureRect
				var detail_window_after_card := _find_node_by_name(root, "SocialDetailWindow") as PanelContainer
				_assert_true(detail_window_after_card == null, "opening a post should not show a second phone window")
				_assert_true(detail_after_card != null, "opening a post should show a dedicated post detail page inside the main social phone")
				if detail_after_card != null and social_app_window != null:
					_assert_true(_is_descendant_of(detail_after_card, social_app_window), "post detail page should be contained by the main social app window")
				_assert_true(back_from_detail != null, "post detail page should expose a close/back button")
				if back_from_detail != null:
					_assert_true(back_from_detail.custom_minimum_size.y >= 56.0, "social secondary-page back button should be as easy to tap as close buttons")
				_assert_true(feed_on_detail == null, "opening a post should replace the feed instead of showing two phone pages")
				_assert_true(detail_floor != null, "tower floor should only appear inside a social app secondary page")
				if detail_floor != null:
					_assert_true(str(detail_floor.text).contains("塔层"), "social detail page should label tower floor")
				_assert_true(detail_media_texture != null and detail_media_texture.texture != null, "social detail should reuse generated post artwork")
				if back_from_detail != null:
					back_from_detail.pressed.emit()
					_assert_true(_find_node_by_name(root, "SocialHomePage") != null, "closing detail should keep the home page available")
			else:
				_assert_true(false, "scene should expose a post open fallback after returning from profile")
		if shop_app_window != null and shop_close != null:
			var actions_before_close: int = root.game.actions_remaining
			shop_close.pressed.emit()
			_assert_true(not shop_app_window.visible, "pressing an app close button should hide that app window")
			_assert_eq(root.game.actions_remaining, actions_before_close, "closing an app window should not spend an action")
		if root.has_method("_active_palette"):
			root.game.pollution = 59
			_assert_eq(root._active_palette().get("name", ""), "palette_1", "pollution below 60 should use Palette 1")
			root.game.pollution = 60
			_assert_eq(root._active_palette().get("name", ""), "pollution_palette_5", "pollution at 60 should use Pollution Palette 5")
		if flashback_overlay != null and root.has_method("_play_pollution_flashback") and root.has_method("_finish_pollution_flashback"):
			_assert_true(not flashback_overlay.visible, "flashback overlay should start hidden")
			root._play_pollution_flashback()
			_assert_true(flashback_overlay.visible, "playing flashback should show the overlay")
			root._finish_pollution_flashback()
			_assert_true(not flashback_overlay.visible, "finishing flashback should hide the overlay")
			root.game.pollution = 60
			root.game.check_pollution_flashback(59)
			root._play_pollution_flashback()
			root._finish_pollution_flashback()
			_assert_eq(root.game.day, 2, "finishing a pending flashback should advance to the next day")
			_assert_eq(root.game.actions_remaining, 5, "flashback settlement should restore next-day actions")
			_assert_true(not flashback_overlay.visible, "flashback overlay should hide after automatic settlement")
		root.game.notebook_tokens = [
			{"id": "n1", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 1},
			{"id": "n2", "text": "空位", "tags": ["空位"], "rarity": 1},
			{"id": "n3", "text": "塔下", "tags": ["巴别塔"], "rarity": 1},
			{"id": "n4", "text": "无信号", "tags": ["信号"], "rarity": 1},
			{"id": "n5", "text": "打错", "tags": ["错字"], "rarity": 1},
			{"id": "n6", "text": "沉默", "tags": ["沉默"], "rarity": 1},
		]
		root.game.owned_emotion_slots = ["anxiety", "please", "counter", "silence", "anger", "prayer"]
		root.game.emotion_slot_texts = {
			"anxiety": "我不是那个意思",
			"please": "你说得也有道理",
			"counter": "难道不是这样吗",
			"silence": "我先不说了",
			"anger": "别再这样问我",
			"prayer": "请让我把话说完",
		}
		root.game.completed_memes = [{"id": "m1", "title": "表达 #1", "text": "哈吉米，到底是什么意思？", "tags": ["哈吉米"], "rarity": 1}]
		root.game.set_active_app("social")
		root._render()
		meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as PanelContainer
		meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
		meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
		if meme_bank_popup != null and meme_bank_tab != null and meme_bank_content != null:
			_assert_true(meme_bank_popup.visible, "meme bank should still peek from the bottom during passive social browsing")
			_assert_true(str(meme_bank_tab.text).contains("◢"), "passive meme bank should only expose a corner")
			if social_app_window != null:
				_assert_true(not _controls_overlap(meme_bank_popup, social_app_window), "passive meme bank corner should not cover the social phone")
			if view_toggle_button != null:
				_assert_true(not _controls_overlap(meme_bank_popup, view_toggle_button), "passive meme bank corner should not cover the put-phone button")
			if international_hud != null:
				_assert_true(not _controls_overlap(meme_bank_popup, international_hud), "passive meme bank corner should not cover the HUD rail")
			if hud_actions_label != null:
				_assert_true(not _controls_overlap(meme_bank_popup, hud_actions_label), "passive meme bank corner should not cover today's actions")
			if international_hud != null:
				_assert_true(international_hud.z_index > meme_bank_popup.z_index, "HUD rail should render above the meme bank so today's actions never get covered")
			_assert_true(not meme_bank_content.visible, "passive meme bank peek should not reveal drawer content")
		root._toggle_meme_bank()
		_assert_true(not meme_bank_content.visible, "passive meme bank corner should not open outside publish or crafting contexts")
		var create_for_bank := _find_node_by_name(root, "SocialNavCreate") as Button
		if create_for_bank != null:
			create_for_bank.pressed.emit()
		meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as PanelContainer
		meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
		meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
		if meme_bank_popup != null:
			_assert_true(meme_bank_popup.visible, "meme bank should appear as a contextual drawer on the social publish page")
			if social_app_window != null:
				_assert_true(not _controls_overlap(meme_bank_popup, social_app_window), "collapsed publish meme bank should not cover the social phone")
			if view_toggle_button != null:
				_assert_true(not _controls_overlap(meme_bank_popup, view_toggle_button), "collapsed publish meme bank should not cover the put-phone button")
		root.game.set_active_app("notebook")
		var notebook_size_before_render := notebook_app_window.size if notebook_app_window != null else Vector2.ZERO
		root._render()
		var notebook_scroll := _find_node_by_name(root, "NotebookCraftScroll") as ScrollContainer
		var notebook_content := _find_node_by_name(root, "NotebookCraftContent") as VBoxContainer
		var notebook_action_bar := _find_node_by_name(root, "NotebookCraftActionBar") as PanelContainer
		var notebook_craft_button := _find_node_by_name(root, "NotebookCraftButton") as Button
		var notebook_token_flow := _find_node_by_name(root, "NotebookTokenFlow") as HFlowContainer
		if notebook_app_window != null:
			_assert_eq(notebook_app_window.size, notebook_size_before_render, "opening notebook crafting should not stretch the notebook app window")
		_assert_true(notebook_scroll != null, "notebook crafting should put expandable content inside an internal scroll area")
		_assert_true(notebook_content != null, "notebook crafting should expose a scroll content container")
		_assert_true(notebook_token_flow != null, "notebook tokens should wrap instead of forcing horizontal overflow")
		_assert_true(notebook_action_bar != null, "notebook crafting should expose a fixed action bar")
		if notebook_content != null and notebook_scroll != null:
			_assert_true(_is_descendant_of(notebook_content, notebook_scroll), "notebook dynamic content should scroll inside the notebook window")
		if notebook_craft_button != null and notebook_action_bar != null and notebook_scroll != null:
			_assert_true(_is_descendant_of(notebook_craft_button, notebook_action_bar), "confirm craft button should stay in the fixed notebook action bar")
			_assert_true(not _is_descendant_of(notebook_craft_button, notebook_scroll), "confirm craft button should not scroll away with notebook content")
			_assert_true(notebook_craft_button.custom_minimum_size.y >= 56.0, "confirm craft button should use a comfortable touch target")
		if meme_bank_tab != null and meme_bank_popup != null and meme_bank_content != null:
			_assert_true(_is_descendant_of(meme_bank_tab, meme_bank_popup), "meme bank tab and drawer should be one popup object")
			_assert_true(meme_bank_popup.visible, "notebook view should show the integrated meme bank popup")
			if social_app_window != null:
				_assert_true(not _controls_overlap(meme_bank_popup, social_app_window), "collapsed notebook meme bank should not cover the social phone")
			if notebook_app_window != null:
				_assert_true(not _controls_overlap(meme_bank_popup, notebook_app_window), "collapsed notebook meme bank should not cover the notebook phone")
			if view_toggle_button != null:
				_assert_true(not _controls_overlap(meme_bank_popup, view_toggle_button), "collapsed notebook meme bank should not cover the put-phone button")
			_assert_true(not meme_bank_content.visible, "meme bank content should start collapsed")
			root._toggle_meme_bank()
			_assert_true(meme_bank_content.visible, "toggling meme bank should open the drawer content")
			if social_app_window != null:
				_assert_true(not _controls_overlap(meme_bank_popup, social_app_window), "opened meme bank drawer should not cover the social phone")
			if notebook_app_window != null:
				_assert_true(not _controls_overlap(meme_bank_popup, notebook_app_window), "opened meme bank drawer should not cover the notebook phone")
			if view_toggle_button != null:
				_assert_true(not _controls_overlap(meme_bank_popup, view_toggle_button), "opened meme bank drawer should not cover the put-phone button")
			if hud_actions_label != null:
				_assert_true(not _controls_overlap(meme_bank_popup, hud_actions_label), "opened meme bank drawer should not cover today's actions")
			root._toggle_meme_bank()
			_assert_true(not meme_bank_content.visible, "toggling meme bank again should collapse the drawer content")
		if social_app_window != null and root.has_method("_move_window_for_test"):
			var before_pos := social_app_window.position
			root._move_window_for_test("app:social", Vector2(36, 28))
			root._render()
			var moved_pos := social_app_window.position
			_assert_true(moved_pos != before_pos, "dragged app window should move from its initial position")
			if view_toggle_button != null:
				_assert_true(view_toggle_button.z_index > social_app_window.z_index, "fixed take/put phone button should stay above dragged app windows")
			root._render()
			_assert_eq(social_app_window.position, moved_pos, "dragged app window position should survive render")
			_assert_eq(root.game.actions_remaining, 5, "moving a window should not spend an action")
			var draggable_ids := ["phone", "app:babel", "app:social", "app:shop", "app:notebook", "bank", "reality", "settings"]
			for window_id in draggable_ids:
				_assert_true(root._move_window_for_test(window_id, Vector2(0, 0)), "window should remain registered as draggable: %s" % window_id)
			var drag_index := 0
			for window_id in draggable_ids:
				var window_pos_before: Vector2 = root._window_position_for_test(window_id)
				_assert_true(root._move_window_for_test(window_id, Vector2(9 + drag_index, 6)), "registered window should accept movement: %s" % window_id)
				var window_pos_after: Vector2 = root._window_position_for_test(window_id)
				_assert_true(window_pos_after != window_pos_before, "registered window should change position when moved: %s" % window_id)
				root._render()
				_assert_eq(root._window_position_for_test(window_id), window_pos_after, "registered window should keep its dragged position after render: %s" % window_id)
				drag_index += 1
			if meme_bank_popup != null:
				root._move_window_for_test("app:social", Vector2(-190, 0))
				root._render()
				_assert_true(not _controls_overlap(meme_bank_popup, social_app_window), "meme bank corner should avoid a dragged social phone")
		_assert_true(_has_node_with_method(root, "set_drag_payload"), "notebook and bank items should expose drag payloads")
		_assert_true(_has_node_with_method(root, "configure_drop_target"), "slots and dialogue blank should expose drop targets")
		root._on_slot_token_dropped({"kind": "token", "id": "n1"}, "object")
		_assert_eq(root.game.draft_slots.get("object", ""), "n1", "dropping token should place it in a craft slot")
		_assert_eq(root.game.actions_remaining, 5, "dropping token should not spend an action")
		root._on_dialogue_meme_dropped({"kind": "meme", "id": "m1"}, "blank_1")
		_assert_eq(root.game.dialogue_blanks.get("blank_1", ""), "m1", "dropping meme should place it in dialogue blank")
		_assert_eq(root.game.actions_remaining, 5, "dropping meme should not spend an action")
		root.set_view_state("npc_up")
		_assert_eq(root.game.view_state, "npc_up", "scene should switch to NPC view")
		_assert_true(root.game.active_app_window.is_empty(), "NPC view should hide active app window")
		if hand_phone_image != null:
			_assert_true(hand_phone_image.visible, "hand-phone artwork should remain visible during the raise-head transition")
			if phone_down_backdrop_image != null:
				_assert_true(phone_down_backdrop_image.visible, "phone-down backdrop should remain visible during the raise-head transition")
			if root.has_method("_animate_world"):
				root._animate_world(1.0)
				if camera != null:
					_assert_true(camera.rotation_degrees.x > -20.0, "NPC view should lift the 3D camera toward a level conversation angle")
			_assert_true(not hand_phone_image.visible or hand_phone_image.modulate.a < 0.05, "hand-phone artwork should fade out after the raise-head transition")
			if phone_down_backdrop_image != null:
				_assert_true(not phone_down_backdrop_image.visible or phone_down_backdrop_image.modulate.a < 0.05, "phone-down backdrop should fade out after the raise-head transition")
		view_toggle_button = _find_node_by_name(root, "PhoneViewToggleButton") as Button
		if view_toggle_button != null:
			_assert_true(str(view_toggle_button.text).contains("拿起手机"), "NPC view should expose a take-phone button")
		if phone_popup != null and phone_tab != null and phone_content != null:
			_assert_true(phone_popup.visible, "phone popup should remain as a side tab after putting the phone away")
			_assert_true(phone_tab.visible, "phone tab should be visible after putting the phone away")
			_assert_true(not phone_content.visible, "phone content should collapse after putting the phone away")
		meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as PanelContainer
		meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
		meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
		if meme_bank_popup != null and meme_bank_tab != null and meme_bank_content != null:
			_assert_true(meme_bank_popup.visible, "meme bank should still peek from the bottom during NPC speaking")
			_assert_true(str(meme_bank_tab.text).contains("◢"), "NPC speaking meme bank should only expose a corner")
			_assert_true(not meme_bank_content.visible, "NPC speaking meme bank peek should not reveal drawer content")
		if hand_phone_image != null and camera != null and root.has_method("_animate_world"):
			var alpha_before_take := hand_phone_image.modulate.a
			var backdrop_alpha_before_take := phone_down_backdrop_image.modulate.a if phone_down_backdrop_image != null else 0.0
			var camera_before_take := camera.rotation_degrees.x
			root.set_view_state("phone_down")
			root._animate_world(0.05)
			view_toggle_button = _find_node_by_name(root, "PhoneViewToggleButton") as Button
			if view_toggle_button != null:
				_assert_true(str(view_toggle_button.text).contains("放下手机"), "taking the phone should restore the put-phone button copy")
			_assert_true(hand_phone_image.visible and hand_phone_image.modulate.a > alpha_before_take, "taking the phone should fade the hand-phone artwork back in")
			if phone_down_backdrop_image != null:
				_assert_true(phone_down_backdrop_image.visible and phone_down_backdrop_image.modulate.a > backdrop_alpha_before_take, "taking the phone should fade the phone-down backdrop back in")
			_assert_true(hand_phone_image.modulate.a < 1.0, "taking the phone should fade in rather than snapping instantly")
			_assert_true(camera.rotation_degrees.x < camera_before_take, "taking the phone should start tilting the camera downward")
			_assert_true(camera.rotation_degrees.x > -54.0, "taking the phone should animate toward the low view before reaching the final angle")
			root._animate_world(0.4)
			_assert_true(camera.rotation_degrees.x < -35.0, "taking the phone should return the 3D camera to the downward phone view")
			root.set_view_state("npc_up")
			root._animate_world(1.0)
		if social_app_window != null and babel_app_window != null and shop_app_window != null:
			_assert_true(not social_app_window.visible, "NPC view should hide social app window")
			_assert_true(not babel_app_window.visible, "NPC view should hide Babel app window")
			_assert_true(not shop_app_window.visible, "NPC view should hide shop app window")
		if npc_bubble != null and dim_overlay != null and player_portrait != null and thought_layer != null and puzzle_frame != null:
			_assert_true(npc_bubble.visible, "NPC view should first show the right-side NPC chat bubble")
			_assert_true(not dim_overlay.visible, "NPC speaking phase should not dim the background yet")
			_assert_true(not player_portrait.visible, "NPC speaking phase should hide player portrait")
			_assert_true(not thought_layer.visible, "NPC speaking phase should hide thought words")
			_assert_true(not puzzle_frame.visible, "NPC speaking phase should hide the language puzzle frame")
		root.game.legacy_rules = [
			{
				"id": "legacy-1",
				"floor": 1,
				"source_meme_id": "m1",
				"required_text": "哈吉米，必须补票",
				"tags": ["哈吉米"],
				"created_day": 2,
				"strength": 1,
			},
		]
		root._render()
		if root.has_method("begin_reality_player_turn") and dim_overlay != null and player_portrait != null and thought_layer != null and puzzle_frame != null:
			root.begin_reality_player_turn()
			view_toggle_button = _find_node_by_name(root, "PhoneViewToggleButton") as Button
			_assert_true(dim_overlay.visible, "player composing phase should dim the background")
			_assert_true(dim_overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "reality dim overlay should not block foreground controls")
			var remaining_brightness := 1.0 - dim_overlay.color.a
			_assert_true(remaining_brightness >= 0.70 and remaining_brightness <= 0.80, "player composing dim overlay should keep background brightness around 70-80 percent")
			_assert_true(absf(float(dim_overlay.get_meta("target_background_brightness", 0.0)) - remaining_brightness) < 0.001, "dim overlay should document its intended background brightness")
			if npc_focus_image != null:
				_assert_true(npc_focus_image.visible, "player composing phase should keep NPC visible above the dimmed background")
				_assert_true(npc_focus_image.texture != null, "NPC focus layer should use generated NPC art")
				_assert_true(npc_focus_image.z_index > dim_overlay.z_index, "NPC focus layer should render above the dim overlay")
			_assert_true(player_portrait.visible, "player composing phase should show the player portrait")
			_assert_true(player_portrait.z_index > dim_overlay.z_index, "player portrait should remain bright above the dim overlay")
			if international_hud != null:
				_assert_true(player_portrait.offset_left >= international_hud.offset_right + 48.0, "player portrait should keep a clear safety gap from the HUD rail and today's actions")
			_assert_true(thought_layer.visible, "player composing phase should show thought words")
			_assert_true(thought_layer.z_index > dim_overlay.z_index, "thought words should remain bright above the dim overlay")
			_assert_true(puzzle_frame.visible, "player composing phase should show the language puzzle frame")
			_assert_true(puzzle_frame.z_index > dim_overlay.z_index, "language puzzle frame should remain bright above the dim overlay")
			confirm_reality_button = _find_node_by_text(root, "尽量正常地说出口") as Button
			_assert_true(confirm_reality_button != null, "player composing phase should expose a confirm speech button")
			if confirm_reality_button != null:
				_assert_true(confirm_reality_button.custom_minimum_size.y >= 56.0, "confirm speech button should use a comfortable touch target")
			if view_toggle_button != null:
				_assert_true(not view_toggle_button.visible, "player composing phase should hide the fixed take-phone button so it does not cover the language puzzle")
			meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as PanelContainer
			if meme_bank_popup != null:
				_assert_true(not meme_bank_popup.visible, "player composing phase should hide the meme bank corner so it does not cover the language puzzle")
			_assert_true(npc_bubble.visible, "NPC bubble should remain visible above the dimmed background")
			_assert_true(npc_bubble.z_index > dim_overlay.z_index, "NPC bubble should remain bright above the dim overlay")
			if phone_popup != null:
				_assert_true(phone_popup.visible, "player composing phase should keep the side phone affordance visible")
				_assert_true(phone_popup.z_index > dim_overlay.z_index, "side phone affordance should remain bright above the dim overlay")
			_assert_true(_has_text(root, "语言组成框"), "player composing phase should show the language puzzle label")
			_assert_true(_has_text(root, "哈吉米，必须补票"), "language puzzle should show required legacy tile")
			var actions_before_puzzle := int(root.game.actions_remaining)
			var first_tile: Dictionary = root.game.get_reality_tile_options()[0]
			root._on_reality_tile_pressed(str(first_tile.get("id", "")))
			root._on_reality_slot_pressed("slot_0")
			var first_reality_slot := _find_node_by_text(root, "1\n%s" % str(first_tile.get("text", ""))) as Button
			_assert_true(first_reality_slot != null, "click fallback should place the selected reality word into the language puzzle slot")
			_assert_eq(root.game.actions_remaining, actions_before_puzzle, "placing reality puzzle words should not spend an action")
	root.queue_free()


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s. Expected %s, got %s" % [message, str(expected), str(actual)])


func _count_nodes_named_prefix(node: Node, prefix: String) -> int:
	var count := 1 if str(node.name).begins_with(prefix) else 0
	for child in node.get_children():
		count += _count_nodes_named_prefix(child, prefix)
	return count


func _unique_social_values(root: Node, key: String, count: int) -> int:
	var values := {}
	for index in count:
		var post: Dictionary = root._social_post_for_index(index)
		values[str(post.get(key, ""))] = true
	return values.size()


func _generated_posters_are_varied() -> bool:
	var sizes := {}
	var byte_prefixes := {}
	for index in 12:
		var path := "res://assets/generated/social/poster_%02d.png" % index
		if not FileAccess.file_exists(path):
			return false
		var bytes := FileAccess.get_file_as_bytes(path)
		sizes[str(bytes.size())] = true
		byte_prefixes[bytes.slice(0, mini(64, bytes.size())).hex_encode()] = true
	return sizes.size() > 1 or byte_prefixes.size() > 1


func _has_node_with_method(node: Node, method_name: String) -> bool:
	if node.has_method(method_name):
		return true
	for child in node.get_children():
		if _has_node_with_method(child, method_name):
			return true
	return false


func _is_descendant_of(node: Node, ancestor: Node) -> bool:
	var current := node.get_parent()
	while current != null:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false


func _controls_overlap(a: Control, b: Control) -> bool:
	if a == null or b == null:
		return false
	return a.get_global_rect().intersects(b.get_global_rect())


func _find_node_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child in node.get_children():
		var found := _find_node_by_name(child, node_name)
		if found != null:
			return found
	return null


func _find_node_by_text(node: Node, text: String) -> Node:
	if node is Label and str((node as Label).text) == text:
		return node
	if node is Button and str((node as Button).text) == text:
		return node
	if node is LineEdit and str((node as LineEdit).text) == text:
		return node
	for child in node.get_children():
		var found := _find_node_by_text(child, text)
		if found != null:
			return found
	return null


func _has_text(node: Node, text: String) -> bool:
	if node is Label and str((node as Label).text).contains(text):
		return true
	if node is Button and str((node as Button).text).contains(text):
		return true
	if node is LineEdit and str((node as LineEdit).text).contains(text):
		return true
	for child in node.get_children():
		if _has_text(child, text):
			return true
	return false
