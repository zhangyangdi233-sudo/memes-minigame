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
		if main_menu_start != null:
			_assert_true(_signal_connection_is_deferred(main_menu_start, "pressed"), "starting a game should defer scene teardown until the button signal finishes")
	if root.has_method("new_game"):
		root.new_game()
		var prologue := _find_node_by_name(root, "PrologueOverlay") as Control
		var prologue_line := _find_node_by_name(root, "PrologueLine") as Label
		var prologue_continue := _find_node_by_name(root, "PrologueContinueButton") as Button
		_assert_true(prologue != null and prologue.visible, "a new run should begin with the original no-signal prologue")
		_assert_true(prologue_line != null and not prologue_line.text.is_empty(), "prologue should expose authored narrative copy")
		_assert_true(prologue_continue != null, "prologue should expose a continue control")
		if prologue != null and root.has_method("_advance_prologue"):
			for _line_index in 7:
				root._advance_prologue()
			_assert_true(not prologue.visible, "advancing every prologue transmission should reveal gameplay")
		_assert_true(root.get_node_or_null("Camera3D") is Camera3D, "main scene should contain a Camera3D")
		_assert_true(root.get_node_or_null("CanvasLayer") is CanvasLayer, "main scene should contain a CanvasLayer")
		_assert_true(root.get_node_or_null("Road") is Node3D, "main scene should contain scrolling road node")
		_assert_true(root.get_node_or_null("PhoneRig") is Node3D, "main scene should contain phone rig")
		_assert_true(root.get_node_or_null("NPC") is Node3D, "main scene should contain NPC node")
		_assert_true(root.has_method("_active_palette"), "main scene should expose active palette lookup")
		_assert_true(root.has_method("_theme_color"), "main scene should expose semantic theme colors")
		_assert_true(root.has_method("_play_pollution_flashback"), "main scene should expose pollution flashback playback")
		_assert_true(root.has_method("_finish_pollution_flashback"), "main scene should expose pollution flashback completion")
		_assert_true(root.has_method("_on_reality_choice_selected"), "main scene should expose cursor-driven reality choices")
		_assert_true(root.has_method("_advance_typed_reality_character"), "main scene should expose per-key reality typing")
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
			"res://assets/generated/ASSET_PROVENANCE.md",
			"res://assets/generated/world/phone_down_backdrop.png",
			"res://assets/generated/world/npc_signal_portrait.png",
			"res://assets/generated/ui/player_portrait.png",
			"res://assets/generated/characters/protagonist_operator.png",
			"res://assets/generated/characters/merchant_frame_vendor.png",
			"res://assets/generated/characters/npc_late_arrival.png",
			"res://assets/generated/characters/npc_echo_tenant.png",
			"res://assets/generated/characters/npc_archive_witness.png",
			"res://assets/generated/ui/no_signal_icon.png",
			"res://assets/generated/ui/hud_day_icon.png",
			"res://assets/generated/ui/hud_pollution_icon.png",
			"res://assets/generated/ui/hud_money_icon.png",
			"res://assets/generated/ui/hud_settings_icon.png",
			"res://assets/generated/social/poster_sheet.png",
			"res://assets/generated/audio/phone_road_loop.wav",
			"res://assets/generated/audio/reality_room_loop.wav",
			"res://assets/generated/audio/babel_phone_signal.wav",
			"res://assets/generated/audio/babel_reality_liminal.wav",
			"res://assets/generated/audio/babel_pollution_rot.wav",
			"res://assets/generated/audio/babel_liminal_score.json",
			"res://assets/generated/audio/pollution_flashback.wav",
			"res://assets/generated/audio/action_tick.wav",
		]:
			_assert_true(FileAccess.file_exists(asset_path), "generated asset should exist: %s" % asset_path)
		for retired_asset_path in [
			"res://assets/generated/world/road_loop_green.png",
			"res://assets/generated/world/hand_phone_down.png",
			"res://assets/generated/world/npc_front.png",
			"res://assets/generated/social/poster_00.png",
		]:
			_assert_true(not FileAccess.file_exists(retired_asset_path), "retired generated asset should stay deleted: %s" % retired_asset_path)
		var camera := root.get_node_or_null("Camera3D") as Camera3D
		var road_tile := root.get_node_or_null("Road/RoadTile0") as MeshInstance3D
		var phone_rig := root.get_node_or_null("PhoneRig") as Node3D
		var npc_plane := root.get_node_or_null("NPC/NPCPlane") as MeshInstance3D
		var phone_ambience := root.get_node_or_null("PhoneRoadAmbience") as AudioStreamPlayer
		var reality_ambience := root.get_node_or_null("RealityRoomAmbience") as AudioStreamPlayer
		var flashback_audio := root.get_node_or_null("PollutionFlashbackAudio") as AudioStreamPlayer
		var action_tick_audio := root.get_node_or_null("ActionTickAudio") as AudioStreamPlayer
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
		var vhs_back_buffer := _find_node_by_name(root, "VHSBackBufferCopy") as BackBufferCopy
		var vhs_dynamic_filter := _find_node_by_name(root, "VHSDynamicFilter") as ColorRect
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
		var social_drag_grip := _find_node_by_name(root, "SocialStatusDragGrip") as ColorRect
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
		var social_channel_tab_discover := _find_node_by_name(root, "SocialChannelTabdiscover") as Button
		var social_channel_tab_tower := _find_node_by_name(root, "SocialChannelTabtower_base") as Button
		var social_channel_tab_follow := _find_node_by_name(root, "SocialChannelTabfollowing") as Button
		var social_channel_tab_nearby := _find_node_by_name(root, "SocialChannelTabnearby") as Button
		var social_channel_tab_underline_discover := _find_node_by_name(root, "SocialChannelTabUnderlinediscover") as ColorRect
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
		var social_post_meta_likes := _find_node_by_name(root, "SocialPostLikeButton0") as Button
		var social_post_texture := _find_node_by_name(root, "SocialPostTexture0") as TextureRect
		var social_post_texture_1 := _find_node_by_name(root, "SocialPostTexture1") as TextureRect
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
		var puzzle_frame := root.get_node_or_null("CanvasLayer/UIRoot/LanguagePuzzleFrame") as PanelContainer
		var reality_subtitle := _find_node_by_name(root, "RealitySubtitlePanel") as PanelContainer
		var reality_subtitle_label := _find_node_by_name(root, "RealitySubtitleLabel") as RichTextLabel
		var reality_choices := _find_node_by_name(root, "RealityResponseChoices") as HBoxContainer
		var reality_intent_preview := _find_node_by_name(root, "RealityIntentPreview") as RichTextLabel
		var reality_typing_line := _find_node_by_name(root, "RealityTypingLine") as RichTextLabel
		var reality_typing_progress := _find_node_by_name(root, "RealityTypingProgress") as Label
		var reality_continue := _find_node_by_name(root, "RealityConversationContinue") as Button
		var reality_aid_status := _find_node_by_name(root, "RealityAidStatus") as Label
		var reality_merchant_offer := _find_node_by_name(root, "RealityMerchantOffer") as PanelContainer
		var reality_merchant_buy := _find_node_by_name(root, "RealityMerchantBuyButton") as Button
		var meme_bank_popup := _find_node_by_name(root, "MemeBankPopup") as Control
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
			_assert_true(road_mat != null and road_mat.albedo_texture == null, "3D road should stay procedural behind the generated low-view backdrop")
			_assert_true(phone_down_backdrop_image != null, "phone-down view should expose the generated road-and-phone backdrop")
			if phone_down_backdrop_image != null:
				_assert_true(phone_down_backdrop_image.texture != null, "phone-down backdrop should be loaded as a texture")
				_assert_eq(str(phone_down_backdrop_image.get_meta("asset_path", "")), "res://assets/generated/world/phone_down_backdrop.png", "phone-down backdrop should use the generated reference-style road asset")
				_assert_true(phone_down_backdrop_image.visible, "phone-down view should show the generated backdrop artwork")
				_assert_eq(phone_down_backdrop_image.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_COVERED, "phone-down backdrop should fill the viewport")
				if phone_down_backdrop_image.texture != null:
					_assert_eq(phone_down_backdrop_image.texture.get_width(), 1672, "combined low-view artwork should preserve its generated width")
					_assert_eq(phone_down_backdrop_image.texture.get_height(), 941, "combined low-view artwork should preserve its generated height")
			_assert_true(hand_phone_image == null, "combined low-view artwork should not be duplicated by a second hand-phone layer")
			if phone_rig != null:
				_assert_true(not phone_rig.visible, "generated hand-phone art should replace the old low-view 3D phone rig")
		_assert_true(npc_plane != null, "scene should expose NPC plane")
		if npc_plane != null:
			var npc_mat := npc_plane.material_override as StandardMaterial3D
			_assert_true(npc_mat != null and npc_mat.albedo_texture == null, "NPC plane should use the procedural world material after removed assets stay deleted")
		_assert_true(phone_ambience != null and phone_ambience.stream is AudioStreamWAV, "phone view should expose generated road ambience")
		_assert_true(reality_ambience != null and reality_ambience.stream is AudioStreamWAV, "reality view should expose generated room ambience")
		_assert_true(flashback_audio != null and flashback_audio.stream is AudioStreamWAV, "pollution flashback should expose generated signal audio")
		_assert_true(action_tick_audio != null and action_tick_audio.stream is AudioStreamWAV, "action pulse should expose generated tick audio")
		if phone_ambience != null and reality_ambience != null:
			var phone_stream := phone_ambience.stream as AudioStreamWAV
			var reality_stream := reality_ambience.stream as AudioStreamWAV
			_assert_eq(phone_stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, "phone ambience should loop continuously")
			_assert_eq(reality_stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, "reality ambience should loop continuously")
			root.game.view_state = "phone_down"
			root._sync_audio_state(true)
			_assert_true(phone_ambience.volume_db > reality_ambience.volume_db, "phone view should foreground road ambience")
			root.game.view_state = "npc_up"
			root._reality_interaction_active = false
			root._sync_audio_state(true)
			_assert_true(reality_ambience.volume_db > phone_ambience.volume_db, "NPC view should foreground room ambience")
			var npc_reality_volume := reality_ambience.volume_db
			root._reality_interaction_active = true
			root.game.conversation_phase = "typing"
			root._sync_audio_state(true)
			_assert_true(reality_ambience.volume_db > npc_reality_volume, "per-key speaking should bring the room tone closer")
			root._duck_ambience_for_flashback()
			_assert_true(bool(phone_ambience.get_meta("flashback_ducked", false)), "flashback should mark phone ambience as ducked")
			_assert_true(bool(reality_ambience.get_meta("flashback_ducked", false)), "flashback should mark reality ambience as ducked")
			root.game.view_state = "phone_down"
			root._reality_interaction_active = false
			root.game.conversation_phase = "idle"
			root._sync_audio_state(true)
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
		_assert_true(vhs_back_buffer != null, "VHS overlay should copy the rendered viewport for post-processing")
		_assert_true(vhs_dynamic_filter != null, "VHS overlay should expose one dynamic full-screen filter")
		if vhs_dynamic_filter != null:
			var vhs_material := vhs_dynamic_filter.material as ShaderMaterial
			_assert_true(vhs_material != null and vhs_material.shader != null, "dynamic VHS filter should use a shader material")
			if vhs_material != null and vhs_material.shader != null:
				var shader_code := vhs_material.shader.code
				_assert_true(shader_code.contains("hint_screen_texture"), "VHS shader should sample the rendered screen")
				_assert_true(shader_code.contains("TIME") and shader_code.contains("29.97"), "VHS shader should animate around an old television field rate")
		if vhs_overlay != null:
			_assert_true(vhs_overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "VHS overlay should never block UI clicks")
			_assert_eq(_count_nodes_named_prefix(vhs_overlay, "VHSScanline"), 0, "dynamic VHS shader should replace static scanline nodes")
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
					social_channel_tab_discover = _find_node_by_name(root, "SocialChannelTabdiscover") as Button
					social_channel_tab_tower = _find_node_by_name(root, "SocialChannelTabtower_base") as Button
					social_channel_tab_follow = _find_node_by_name(root, "SocialChannelTabfollowing") as Button
					social_channel_tab_nearby = _find_node_by_name(root, "SocialChannelTabnearby") as Button
					social_channel_tab_underline_discover = _find_node_by_name(root, "SocialChannelTabUnderlinediscover") as ColorRect
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
					social_post_meta_likes = _find_node_by_name(root, "SocialPostLikeButton0") as Button
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
					puzzle_frame = root.get_node_or_null("CanvasLayer/UIRoot/LanguagePuzzleFrame") as PanelContainer
					reality_subtitle = _find_node_by_name(root, "RealitySubtitlePanel") as PanelContainer
					reality_subtitle_label = _find_node_by_name(root, "RealitySubtitleLabel") as RichTextLabel
					reality_choices = _find_node_by_name(root, "RealityResponseChoices") as HBoxContainer
					reality_intent_preview = _find_node_by_name(root, "RealityIntentPreview") as RichTextLabel
					reality_typing_line = _find_node_by_name(root, "RealityTypingLine") as RichTextLabel
					reality_typing_progress = _find_node_by_name(root, "RealityTypingProgress") as Label
					reality_continue = _find_node_by_name(root, "RealityConversationContinue") as Button
					reality_aid_status = _find_node_by_name(root, "RealityAidStatus") as Label
					reality_merchant_offer = _find_node_by_name(root, "RealityMerchantOffer") as PanelContainer
					reality_merchant_buy = _find_node_by_name(root, "RealityMerchantBuyButton") as Button
					meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as Control
					meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
					meme_bank_drag_handle = _find_node_by_name(root, "MemeBankDragHandle") as Label
					meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
		if view_toggle_button != null:
			_assert_true(view_toggle_button.visible, "take/put phone button should be visible during gameplay")
			_assert_true(str(view_toggle_button.text).contains("放下手机"), "phone-down view should expose a put-phone button")
			_assert_true(view_toggle_button.offset_right <= 620.0, "put-phone button should sit outside the main phone window instead of being covered by it")
		if hud_actions_label != null:
			_assert_true(str(hud_actions_label.text).contains("今日行动"), "HUD actions label should use the new action copy")
			_assert_true(str(hud_actions_label.text).contains("● ● ● ● ●"), "HUD actions label should start with five spaced action dots")
			_assert_eq(str(hud_actions_label.get_meta("action_animation_mode", "")), "inline_pulse", "action spend animation should be an inline pulse")
		if action_overlay != null:
			_assert_true(not action_overlay.visible, "action spend overlay should start hidden")
		if root.has_method("_play_action_spend_animation") and root.has_method("_finish_action_spend_animation") and action_overlay != null and action_label != null:
			root._play_action_spend_animation(5, 4)
			_assert_true(not action_overlay.visible, "playing action spend animation should not show a fullscreen overlay")
			_assert_true(str(hud_actions_label.text).contains("● ● ● ● ●"), "action spend pulse should begin with the before-spend dots")
			root._finish_action_spend_animation()
			_assert_true(not action_overlay.visible, "finishing action spend animation should hide the overlay")
			_assert_true(str(hud_actions_label.text).contains("● ● ● ● ○"), "finishing action spend animation should leave HUD with the after-spend dots")
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
			social_drag_grip = _find_node_by_name(root, "SocialStatusDragGrip") as ColorRect
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
			social_channel_tab_discover = _find_node_by_name(root, "SocialChannelTabdiscover") as Button
			social_channel_tab_tower = _find_node_by_name(root, "SocialChannelTabtower_base") as Button
			social_channel_tab_follow = _find_node_by_name(root, "SocialChannelTabfollowing") as Button
			social_channel_tab_nearby = _find_node_by_name(root, "SocialChannelTabnearby") as Button
			social_channel_tab_underline_discover = _find_node_by_name(root, "SocialChannelTabUnderlinediscover") as ColorRect
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
			social_post_meta_likes = _find_node_by_name(root, "SocialPostLikeButton0") as Button
			social_post_texture = _find_node_by_name(root, "SocialPostTexture0") as TextureRect
			social_post_open = _find_node_by_name(root, "SocialPostOpen0") as Button
			social_detail_window = _find_node_by_name(root, "SocialDetailWindow") as PanelContainer
			social_detail_close = _find_node_by_name(root, "SocialDetailWindowCloseButton") as Button
			social_scroll_hint = _find_node_by_name(root, "SocialScrollHint") as Label
			external_publish_panel = _find_node_by_name(root, "PublishPanel") as PanelContainer
			meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as Control
			meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
			meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
			view_toggle_button = _find_node_by_name(root, "PhoneViewToggleButton") as Button
		_assert_true(phone_popup != null, "scene should expose an integrated phone popup")
		_assert_true(phone_tab == null, "the duplicate PHONE tab should stay removed")
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
				_assert_true(close_button.custom_minimum_size.x >= 44.0 and close_button.custom_minimum_size.y >= 44.0, "window close buttons should meet mobile touch-target guidance")
		_assert_true(social_phone_view != null, "social app should render as a phone app viewport")
		_assert_true(social_status_bar != null, "social app should include a phone-style status bar")
		if social_status_bar != null:
			_assert_true(social_status_bar.has_meta("drag_handle"), "social phone status bar should be the visible drag handle")
			_assert_true(social_status_bar.custom_minimum_size.y >= 48.0, "social phone status bar should leave enough draggable area beside the close button")
		_assert_true(social_drag_grip != null, "social phone status bar should include a visible drag grip")
		if social_drag_grip != null:
			_assert_true(social_drag_grip.mouse_filter == Control.MOUSE_FILTER_IGNORE, "social drag grip should not steal phone status-bar dragging")
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
			_assert_true(social_channel_tab_follow != null, "social app should restore the reference Follow channel")
			_assert_true(social_channel_tab_nearby != null, "social app should restore the reference Nearby channel")
			if social_channel_tab_discover != null:
				_assert_true(social_channel_tab_discover.custom_minimum_size.y >= 44.0, "Discover tab should meet minimum touch target height")
			if social_channel_tab_tower != null:
				_assert_true(social_channel_tab_tower.custom_minimum_size.y >= 44.0, "Tower tab should meet minimum touch target height")
			if social_channel_tab_follow != null and social_channel_tab_nearby != null:
				_assert_true(social_channel_tab_follow.custom_minimum_size.y >= 44.0 and social_channel_tab_nearby.custom_minimum_size.y >= 44.0, "all four phone channels should keep comfortable touch targets")
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
				_assert_true(social_post_texture.texture is AtlasTexture, "social post texture should crop one cell from the generated poster sheet")
				_assert_eq(str(social_post_texture.get_meta("poster_sheet_path", "")), "res://assets/generated/social/poster_sheet.png", "social cards should use the retained poster sheet")
			if social_post_texture != null and social_post_texture_1 != null and social_post_texture.texture is AtlasTexture and social_post_texture_1.texture is AtlasTexture:
				_assert_true((social_post_texture.texture as AtlasTexture).region != (social_post_texture_1.texture as AtlasTexture).region, "adjacent social cards should use different poster-sheet cells")
			_assert_true(social_post_caption != null, "social post cards should expose a short caption")
			_assert_true(social_post_meta_likes != null and str(social_post_meta_likes.text).contains("♡"), "social post cards should show reference-like engagement counts")
			_assert_true(social_post_open == null, "social post cards should not use a separate enter button")
			if social_channel_tab_tower != null and social_app_window != null:
				social_channel_tab_tower.pressed.emit()
				var tower_detail_page := _find_node_by_name(root, "SocialPostDetailPage") as VBoxContainer
				var tower_feed := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
				var tower_detail_window := _find_node_by_name(root, "SocialDetailWindow") as PanelContainer
				_assert_true(tower_detail_page != null, "pressing Tower should open the secondary detail page")
				_assert_true(tower_feed != null, "opening the Tower companion should preserve the phone feed underneath")
				_assert_true(tower_detail_window != null and tower_detail_window.visible, "pressing Tower should open the reference-style companion window")
				if tower_detail_page != null and tower_detail_window != null:
					_assert_true(_is_descendant_of(tower_detail_page, tower_detail_window), "Tower page should live inside its independent companion window")
				var discover_after_tower := _find_node_by_name(root, "SocialChannelTabdiscover") as Button
				if discover_after_tower != null:
					discover_after_tower.pressed.emit()
			if social_post_card != null:
				_assert_true(social_post_card.mouse_filter == Control.MOUSE_FILTER_STOP, "social post cards should be directly clickable")
				_assert_true(social_detail_window != null and not social_detail_window.visible, "social detail companion should exist but start closed")
				_assert_true(social_detail_close != null, "social detail companion should expose its own close button")
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
		_assert_true(npc_bubble == null and dim_overlay == null and npc_focus_image == null, "retired chat bubble, dim overlay, and duplicate focus portrait should stay removed")
		_assert_true(player_portrait == null and thought_layer == null and puzzle_frame == null, "retired Florence word puzzle controls should stay removed")
		_assert_true(reality_subtitle != null and reality_subtitle_label != null, "reality dialogue should use a bottom-center movie subtitle")
		_assert_true(reality_choices != null, "reality dialogue should expose a three-choice cursor surface")
		_assert_true(reality_intent_preview != null, "reality dialogue should expose a separate full-intent hover preview")
		_assert_true(reality_typing_line != null and reality_typing_progress != null, "reality dialogue should expose gray-to-white per-key typing")
		_assert_true(reality_continue != null, "understood dialogue should expose a compact exit control")
		_assert_true(reality_aid_status != null, "reality dialogue should expose remaining communication-item charges")
		_assert_true(reality_merchant_offer != null and reality_merchant_buy != null, "merchant dialogue should expose its limited-use item offer")
		if reality_merchant_buy != null:
			_assert_true(reality_merchant_buy.custom_minimum_size.y >= 56.0, "merchant item purchase should use a comfortable target")
		if reality_subtitle != null:
			var cinematic_bar := _find_node_by_name(root, "CinematicBottomBar") as ColorRect
			_assert_true(cinematic_bar == null or reality_subtitle.z_index > cinematic_bar.z_index, "movie subtitles should render over the cinematic bar")
		_assert_true(meme_bank_popup != null, "scene should expose an integrated meme bank popup")
		_assert_true(meme_bank_tab != null, "meme bank tab should live inside the integrated popup")
		_assert_true(meme_bank_drag_handle != null, "meme bank popup should expose a separate drag handle instead of relying on the toggle button")
		_assert_true(meme_bank_content != null, "meme bank popup should expose collapsible content")
		if meme_bank_drag_handle != null:
			_assert_true(meme_bank_drag_handle.has_meta("drag_handle"), "meme bank drag handle should move the whole drawer")
		if phone_popup != null and phone_content != null:
			_assert_true(_is_descendant_of(phone_content, phone_popup), "phone content should expand from the integrated phone popup")
			_assert_true(not phone_popup.visible, "the phone launcher should hide while an app window is open")
			_assert_true(not phone_content.visible, "phone launcher content should not overlap the main social phone")
			root._open_phone_launcher()
			var phone_width := phone_popup.offset_right - phone_popup.offset_left
			var phone_height := phone_popup.offset_bottom - phone_popup.offset_top
			var launcher_wallpaper := _find_node_by_name(root, "PhoneLauncherWallpaper") as TextureRect
			_assert_true(phone_content.visible, "clicking the attached phone dock should expand the phone home")
			_assert_true(launcher_wallpaper != null and launcher_wallpaper.texture != null, "phone home should use a real illustrated wallpaper behind the app grid")
			_assert_true(social_app_window == null or not social_app_window.visible, "opening the phone launcher should temporarily clear app windows from behind the device")
			_assert_true(phone_handle != null and phone_handle.get_theme_color("font_color").get_luminance() > root._theme_color("ink").get_luminance() + 0.25, "phone launcher title should remain legible on its dark device header")
			if launcher_wallpaper != null:
				_assert_true(str(launcher_wallpaper.get_meta("asset_path", "")).contains("assets/generated/1/"), "phone wallpaper should use the owner's supplied mood imagery")
			_assert_true(phone_width >= 420.0 and phone_height >= 700.0, "expanded phone home should be large enough for the app grid")
			_assert_true(phone_height / maxf(1.0, phone_width) >= 1.68, "expanded phone home should keep a modern tall-phone aspect ratio")
			_assert_true(phone_height / maxf(1.0, phone_width) <= 1.78, "expanded phone home should keep the selected 1.72 ratio")
			root._on_app_pressed("social")
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
			var daily_meme_frame := _find_node_by_name(root, "DailyMemeFramePanel") as PanelContainer
			var daily_meme_frame_buy := _find_node_by_name(root, "DailyMemeFrameBuyButton") as Button
			_assert_true(_find_node_by_name(root, "ArcanaShopSection") == null, "shop should no longer sell arcana")
			_assert_true(_find_node_by_name(root, "EmotionShopSection") == null, "shop should no longer sell emotion slots")
			_assert_true(daily_meme_frame != null, "shop should sell the sparse daily meme frame offer")
			_assert_true(daily_meme_frame_buy != null and daily_meme_frame_buy.custom_minimum_size.y >= 52.0, "meme frame purchase should use a comfortable touch target")
			_assert_true(notebook_app_window != social_app_window, "notebook app should be an independent window node")
			if social_app_window != null and social_feed_masonry != null:
				var social_width := social_app_window.offset_right - social_app_window.offset_left
				var social_height := social_app_window.offset_bottom - social_app_window.offset_top
				var current_social_feed_masonry := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
				_assert_true(social_width >= 410.0, "social app window should leave two readable masonry columns")
				_assert_true(social_width <= 445.0, "social app window should match the wider reference phone width without crowding")
				_assert_true(social_height >= 840.0, "social app window should use the available vertical phone space")
				_assert_true(social_height / maxf(1.0, social_width) >= 2.0, "social app window should use a true tall-phone composition")
				_assert_true(social_height / maxf(1.0, social_width) <= 2.1, "social app window should not become an excessively narrow strip")
				var viewport_width := float(ProjectSettings.get_setting("display/window/size/viewport_width", 1600))
				var social_left := viewport_width + social_app_window.offset_left
				_assert_true(social_left >= viewport_width * 0.46 and social_left <= viewport_width * 0.54, "main social phone should occupy the central-right reference position")
				_assert_true(current_social_feed_masonry != null and _is_descendant_of(current_social_feed_masonry, social_app_window), "social feed grid should live inside the social app window")
		if social_bottom_nav != null and social_feed_scroll != null:
			_assert_true(not _is_descendant_of(social_bottom_nav, social_feed_scroll), "bottom nav should not scroll away with the feed")
			_assert_true(int(social_feed_scroll.get_meta("slow_scroll_step", 0)) <= 2, "social feed wheel scroll should be deliberately slow for phone-style browsing")
			var wheel_event := InputEventMouseButton.new()
			wheel_event.button_index = MOUSE_BUTTON_WHEEL_DOWN
			wheel_event.pressed = true
			social_feed_scroll.scroll_vertical = 0
			root._on_social_feed_scroll_gui_input(wheel_event, social_feed_scroll)
			_assert_true(social_feed_scroll.scroll_vertical <= 2, "one wheel notch should move the masonry feed only a small amount")
			var pan_event := InputEventPanGesture.new()
			pan_event.delta = Vector2(0, 1)
			var actions_before_pan: int = root.game.actions_remaining
			social_feed_scroll.scroll_vertical = 0
			root._on_social_feed_scroll_gui_input(pan_event, social_feed_scroll)
			_assert_true(social_feed_scroll.scroll_vertical <= 2, "one pan gesture unit should use the same slow phone-feed step")
			_assert_eq(root.game.actions_remaining, actions_before_pan, "touchpad-style social feed browsing should not spend an action")
			if social_feed_masonry != null:
				_assert_eq(social_feed_masonry.get_child_count(), 2, "mobile social feed should keep a two-column discovery layout")
		if social_post_card != null and social_post_card_1 != null:
			_assert_true(social_post_card.custom_minimum_size.y != social_post_card_1.custom_minimum_size.y, "masonry post cards should use staggered heights")
		if social_post_caption != null:
			var caption_length := str(social_post_caption.text).length()
			_assert_true(caption_length >= 8 and caption_length <= 14, "home feed captions should stay within the researched 8-14 character mobile range")
		if social_post_caption != null and social_post_caption_1 != null:
			_assert_true(social_post_caption.text != social_post_caption_1.text, "home feed captions should not feel like repeated token excerpts")
		if root.has_method("_social_post_for_index"):
			_assert_true(str(root._social_post_for_index(0).get("text", "")) != str(root._social_post_for_index(1).get("text", "")), "social detail posts should vary per card instead of repeating the same two base posts")
			_assert_true(str(root._social_post_for_index(0).get("text", "")).length() <= 42, "social detail posts should stay short like image-led mobile notes")
			_assert_true(str(root._social_post_for_index(0).get("handle", "")) != str(root._social_post_for_index(1).get("handle", "")), "social post handles should vary across lifestyle-note styles")
			_assert_true(_unique_social_values(root, "text", 12) >= 10, "first twelve social detail posts should be varied")
			_assert_true(_unique_social_values(root, "handle", 12) >= 10, "first twelve social handles should be varied")
			_assert_true(_unique_social_values(root, "text", 12) == 12, "all twelve generated poster cells should map to distinct detail posts")
			_assert_true(_unique_social_values(root, "handle", 12) == 12, "all twelve generated poster cells should map to distinct note personas")
			_assert_true(_unique_social_captions(root, 12) == 12, "all twelve generated poster cells should expose distinct short captions")
			_assert_true(_social_captions_fit_length(root, 12, 8, 14), "all twelve social captions should fit the researched 8-14 character mobile range")
			_assert_true(_social_pickups_follow_daily_limits(root, 12), "daily social pickups should be sparse, single-character, and coherent")
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
			var publish_score_after_nav := _find_node_by_name(root, "SocialPublishScoreBreakdown") as PanelContainer
			var publish_score_text_after_nav := _find_node_by_name(root, "SocialPublishScoreText") as Label
			var publish_contract_after_nav := _find_node_by_name(root, "SocialPublishContractPanel") as PanelContainer
			var publish_contract_title_after_nav := _find_node_by_name(root, "SocialPublishContractTitle") as Label
			var publish_contract_text_after_nav := _find_node_by_name(root, "SocialPublishContractText") as Label
			var feed_after_nav := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
			var inline_close_after_publish := _find_node_by_name(root, "SocialAppInlineCloseButton") as Button
			var bottom_nav_after_publish := _find_node_by_name(root, "SocialBottomNav") as HBoxContainer
			_assert_true(publish_page_after_nav != null, "publish nav should open a dedicated publish page")
			_assert_true(composer_after_nav != null, "dedicated publish page should contain the publish composer")
			_assert_true(publish_scroll_after_nav != null, "publish page should put expandable content inside an internal scroll area")
			_assert_true(publish_action_bar_after_nav != null, "publish page should expose a fixed action bar for confirmation")
			_assert_true(publish_score_after_nav != null, "publish page should expose a Balatro-like base-times-multiplier breakdown")
			_assert_true(publish_contract_after_nav != null, "publish page should expose today's signal hand as a distinct scoring contract")
			_assert_true(_find_node_by_name(root, "SocialPublishArcanaPanel") == null, "publish page should not expose the removed arcana hand")
			if publish_contract_title_after_nav != null and publish_contract_text_after_nav != null:
				_assert_true(not publish_contract_title_after_nav.text.is_empty(), "daily signal hand should have a visible name")
				_assert_true(str(publish_contract_text_after_nav.text).contains("奖励") and str(publish_contract_text_after_nav.text).contains("污染"), "daily signal hand should reveal both reward and pollution risk before publishing")
			if publish_score_text_after_nav != null:
				_assert_true(str(publish_score_text_after_nav.text).contains("传播基础") and str(publish_score_text_after_nav.text).contains("整数倍率") and str(publish_score_text_after_nav.text).contains("倍率来源"), "publish score breakdown should collapse every bonus into one readable integer multiplier")
				_assert_true(not str(publish_score_text_after_nav.text).contains("共鸣倍率") and not str(publish_score_text_after_nav.text).contains("遗物倍率"), "publish score breakdown should remove separate decimal multiplier rows")
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
			if profile_page_after_nav != null:
				_assert_true(_has_text(profile_page_after_nav, "污染："), "profile page should keep pollution visible as the core language-health stat")
				_assert_true(not _has_text(profile_page_after_nav, "清晰"), "profile page should not restore the removed clarity stat")
				var identity_portrait := _find_node_by_name(profile_page_after_nav, "SocialPlayerIdentityPortrait") as TextureRect
				_assert_true(identity_portrait != null and identity_portrait.texture != null, "profile page should use the project owner's protagonist as its identity image")
			var home_nav_after_profile := _find_node_by_name(root, "SocialNavHome") as Button
			if home_nav_after_profile != null:
				home_nav_after_profile.pressed.emit()
			if root.has_method("_open_social_post"):
				root._open_social_post(0)
				var detail_after_card := _find_node_by_name(root, "SocialPostDetailPage") as VBoxContainer
				var back_from_detail := _find_node_by_name(root, "SocialBackToHome") as Button
				var feed_on_detail := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
				var detail_floor := _find_node_by_name(root, "SocialDetailWindowHandle") as Label
				var detail_media_texture := _find_node_by_name(root, "SocialDetailPostTexture") as TextureRect
				var detail_signal_profile := _find_node_by_name(root, "SocialCardSignalProfile") as Label
				var detail_like_button := _find_node_by_name(root, "SocialDetailLikeButton") as Button
				var detail_follow_button := _find_node_by_name(root, "SocialDetailFollowButton") as Button
				var detail_window_after_card := _find_node_by_name(root, "SocialDetailWindow") as PanelContainer
				_assert_true(detail_window_after_card != null and detail_window_after_card.visible, "opening a post should show the independent companion window")
				_assert_true(detail_after_card != null, "opening a post should populate the companion detail page")
				if detail_after_card != null and detail_window_after_card != null:
					_assert_true(_is_descendant_of(detail_after_card, detail_window_after_card), "post detail page should be contained by the companion window")
				_assert_true(back_from_detail == null, "companion detail should use its window close button instead of an in-phone back button")
				_assert_true(feed_on_detail != null, "opening a post should preserve the two-column feed inside the phone")
				_assert_true(detail_floor != null, "tower floor should only appear inside a social app secondary page")
				if detail_floor != null:
					_assert_true(str(detail_floor.text).contains("塔层"), "social detail page should label tower floor")
				_assert_true(detail_media_texture != null and detail_media_texture.texture != null, "social detail should reuse generated post artwork")
				_assert_true(detail_signal_profile != null and str(detail_signal_profile.text).contains("信号偏向"), "social detail should expose the card's build-facing signal profile")
				_assert_true(detail_like_button != null and detail_like_button.custom_minimum_size.y >= 44.0, "post detail should expose a touch-sized like control")
				_assert_true(detail_follow_button != null and detail_follow_button.custom_minimum_size.y >= 44.0, "post detail should expose a touch-sized follow control")
				if social_detail_close != null:
					_assert_true(social_detail_close.get_theme_color("font_color").get_luminance() > root._theme_color("ink").get_luminance() + 0.25, "detail close glyph should remain visible on the dark companion window")
					var detail_position_before: Vector2 = root._window_position_for_test("social-detail")
					_assert_true(root._move_window_for_test("social-detail", Vector2(-24, 12)), "detail companion should be draggable as its own window")
					_assert_true(root._window_position_for_test("social-detail") != detail_position_before, "dragging detail companion should preserve its independent position")
					social_detail_close.pressed.emit()
					_assert_true(not detail_window_after_card.visible, "closing detail should hide only the companion window")
					_assert_true(_find_node_by_name(root, "SocialHomePage") != null, "closing detail should keep the home page available")
			else:
				_assert_true(false, "scene should expose a post open fallback after returning from profile")
		if root.has_method("_social_post_for_index"):
			var social_actions_before: int = root.game.actions_remaining
			var follow_tab_initial := _find_node_by_name(root, "SocialChannelTabfollowing") as Button
			if follow_tab_initial != null:
				follow_tab_initial.pressed.emit()
			var following_empty := _find_node_by_name(root, "SocialFollowingEmptyState") as PanelContainer
			var following_feed_empty := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
			_assert_true(following_empty != null, "Follow should begin with an explicit empty state")
			_assert_true(following_feed_empty == null, "Follow should not show discovery posts before the player follows anyone")
			var discover_for_engagement := _find_node_by_name(root, "SocialChannelTabdiscover") as Button
			if discover_for_engagement != null:
				discover_for_engagement.pressed.emit()
			var post_zero: Dictionary = root._social_post_for_index(0)
			var post_zero_id := str(post_zero.get("id", ""))
			var post_zero_author_id := str(post_zero.get("id", ""))
			var like_button := _find_node_by_name(root, "SocialPostLikeButton0") as Button
			var follow_button := _find_node_by_name(root, "SocialPostFollowButton0") as Button
			_assert_true(like_button != null and like_button.custom_minimum_size.y >= 44.0, "feed cards should expose touch-sized like buttons")
			_assert_true(follow_button != null and follow_button.custom_minimum_size.y >= 44.0, "feed cards should expose touch-sized follow buttons")
			if like_button != null:
				like_button.pressed.emit()
			var liked_button := _find_node_by_name(root, "SocialPostLikeButton0") as Button
			_assert_true(root.game.is_social_post_liked(post_zero_id), "liking a feed card should persist in run state")
			_assert_true(liked_button != null and str(liked_button.text).contains("♥"), "liked feed cards should switch to a filled heart")
			follow_button = _find_node_by_name(root, "SocialPostFollowButton0") as Button
			if follow_button != null:
				follow_button.pressed.emit()
			_assert_true(root.game.is_social_following(post_zero_author_id), "following from Discover should persist the stable author ID")
			var follow_tab_after_follow := _find_node_by_name(root, "SocialChannelTabfollowing") as Button
			if follow_tab_after_follow != null:
				follow_tab_after_follow.pressed.emit()
			var following_feed := _find_node_by_name(root, "SocialFeedMasonry") as HBoxContainer
			_assert_true(_find_node_by_name(root, "SocialFollowingEmptyState") == null, "Follow empty state should disappear after following an account")
			_assert_true(following_feed != null, "Follow should render a masonry feed after an account is followed")
			_assert_eq(_count_nodes_named_prefix(root, "SocialPostCard"), 1, "Follow should contain only posts from followed accounts")
			var nearby_tab := _find_node_by_name(root, "SocialChannelTabnearby") as Button
			if nearby_tab != null:
				nearby_tab.pressed.emit()
			var nearby_unavailable := _find_node_by_name(root, "SocialNearbyUnavailable") as PanelContainer
			var nearby_message := _find_node_by_name(root, "SocialNearbyUnavailableMessage") as Label
			_assert_true(nearby_unavailable != null, "Nearby should show an unavailable-location state")
			_assert_true(nearby_message != null and str(nearby_message.text).contains("无法"), "Nearby unavailable state should explain that location cannot be obtained")
			_assert_true(_find_node_by_name(root, "SocialFeedMasonry") == null, "Nearby should not leak discovery posts behind the location error")
			var discover_after_nearby := _find_node_by_name(root, "SocialChannelTabdiscover") as Button
			if discover_after_nearby != null:
				discover_after_nearby.pressed.emit()
			_assert_true(_find_node_by_name(root, "SocialFeedMasonry") != null, "Discover should restore the full masonry feed after leaving Nearby")
			_assert_eq(root.game.actions_remaining, social_actions_before, "following, liking, and switching social channels should not spend actions")
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
			{"id": "n1", "text": "哈", "tags": ["哈吉米"], "rarity": 1, "source_passive": {"id": "callback_resonance", "label": "回拨共鸣", "description": "命中风向时传播基础 +10", "effect": "trend_base", "value": 10}},
			{"id": "n2", "text": "空", "tags": ["空位"], "rarity": 1},
			{"id": "n3", "text": "塔", "tags": ["巴别塔"], "rarity": 1},
		]
		root.game.owned_meme_frames = 1
		root.game.completed_memes = [
			{"id": "m1", "title": "单字 #1", "text": "哈", "tags": ["哈吉米"], "rarity": 1},
			{"id": "m2", "title": "单字 #2", "text": "塔", "tags": ["巴别塔"], "rarity": 1},
		]
		root.game.set_active_app("social")
		root._render()
		meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as Control
		meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
		meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
		if meme_bank_popup != null and meme_bank_tab != null and meme_bank_content != null:
			_assert_true(not meme_bank_popup.visible, "meme bank should be completely hidden during passive social browsing")
			_assert_true(not root._should_show_meme_bank() and not root._should_peek_meme_bank(), "passive social browsing should expose neither drawer nor corner peek")
			_assert_true(not meme_bank_content.visible, "hidden passive meme bank should not reveal drawer content")
		root._toggle_meme_bank()
		_assert_true(not meme_bank_popup.visible and not meme_bank_content.visible, "meme bank should not open outside the social publish page")
		var create_for_bank := _find_node_by_name(root, "SocialNavCreate") as Button
		if create_for_bank != null:
			create_for_bank.pressed.emit()
		meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as Control
		meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
		meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
		if meme_bank_popup != null:
			_assert_true(meme_bank_popup.visible, "meme bank should appear as a contextual drawer on the social publish page")
			if meme_bank_tab != null:
				_assert_true(not bool(meme_bank_tab.get_meta("meme_bank_peek", true)), "publish meme bank tab should leave peek mode")
				_assert_true(meme_bank_popup.size.x >= meme_bank_tab.custom_minimum_size.x, "collapsed publish meme bank should be wide enough for its tab text")
			if social_app_window != null:
				_assert_true(not _controls_overlap(meme_bank_popup, social_app_window), "collapsed publish meme bank should not cover the social phone")
			if social_bottom_nav != null:
				_assert_true(not _controls_overlap(meme_bank_popup, social_bottom_nav), "collapsed publish meme bank should not cover the social bottom navigation")
			if social_home_indicator != null:
				_assert_true(not _controls_overlap(meme_bank_popup, social_home_indicator), "collapsed publish meme bank should not cover the social home indicator")
			if view_toggle_button != null:
				_assert_true(not _controls_overlap(meme_bank_popup, view_toggle_button), "collapsed publish meme bank should not cover the put-phone button")
		root.game.set_active_app("notebook")
		root._open_app_windows["social"] = false
		var notebook_size_before_render := notebook_app_window.size if notebook_app_window != null else Vector2.ZERO
		root._render()
		var notebook_scroll := _find_node_by_name(root, "NotebookCraftScroll") as ScrollContainer
		var notebook_content := _find_node_by_name(root, "NotebookCraftContent") as VBoxContainer
		var notebook_action_bar := _find_node_by_name(root, "NotebookCraftActionBar") as PanelContainer
		var notebook_craft_button := _find_node_by_name(root, "NotebookCraftButton") as Button
		var notebook_token_flow := _find_node_by_name(root, "NotebookTokenFlow") as HFlowContainer
		var sourced_notebook_token := _find_node_by_name(root, "NotebookToken_n1") as Button
		var frame_tab := _find_node_by_name(root, "NotebookCraftTabFrame") as Button
		var fusion_tab := _find_node_by_name(root, "NotebookCraftTabFusion") as Button
		var meme_ring := _find_node_by_name(root, "MemeBankRadialRing") as Control
		if notebook_app_window != null:
			_assert_eq(notebook_app_window.size, notebook_size_before_render, "opening notebook crafting should not stretch the notebook app window")
			_assert_true(notebook_app_window.global_position.x <= 320.0, "notebook should open as the square work window at the upper left")
		_assert_true(notebook_scroll != null, "notebook crafting should put expandable content inside an internal scroll area")
		_assert_true(notebook_content != null, "notebook crafting should expose a scroll content container")
		_assert_true(notebook_token_flow != null, "notebook tokens should wrap instead of forcing horizontal overflow")
		_assert_true(sourced_notebook_token != null and str(sourced_notebook_token.text).contains("回拨共鸣"), "notebook token should retain and display its source card passive")
		_assert_true(notebook_action_bar != null, "notebook crafting should expose a fixed action bar")
		_assert_true(frame_tab != null and fusion_tab != null, "notebook should expose two browser-style crafting tabs")
		_assert_true(bool(frame_tab.get_meta("active_tab", false)), "frame crafting should be the initial notebook tab")
		_assert_true(not _has_text(root, "情绪构筑"), "notebook should remove the old emotion loadout")
		_assert_true(_find_node_by_name(root, "NotebookFusionSlots") == null, "the frame tab should not mix in fusion controls")
		if notebook_content != null and notebook_scroll != null:
			_assert_true(_is_descendant_of(notebook_content, notebook_scroll), "notebook dynamic content should scroll inside the notebook window")
		if notebook_craft_button != null and notebook_action_bar != null and notebook_scroll != null:
			_assert_true(_is_descendant_of(notebook_craft_button, notebook_action_bar), "confirm craft button should stay in the fixed notebook action bar")
			_assert_true(not _is_descendant_of(notebook_craft_button, notebook_scroll), "confirm craft button should not scroll away with notebook content")
			_assert_true(notebook_craft_button.custom_minimum_size.y >= 56.0, "confirm craft button should use a comfortable touch target")
		if meme_bank_tab != null and meme_bank_popup != null and meme_bank_content != null:
			_assert_true(_is_descendant_of(meme_bank_tab, meme_bank_popup), "meme bank tab and drawer should be one popup object")
			_assert_true(meme_bank_popup.visible and meme_bank_content.visible, "notebook crafting should open the attached radial meme bank")
			_assert_true(meme_ring != null and meme_ring.has_method("handle_navigation_event"), "meme bank should expose wheel and trackpad ring navigation")
			if notebook_app_window != null:
				_assert_true(meme_bank_popup.anchor_left >= 0.99 and notebook_app_window.anchor_left <= 0.01, "the radial bank should anchor right while the notebook anchors upper left")
		if fusion_tab != null:
			fusion_tab.pressed.emit()
			var fusion_slots := _find_node_by_name(root, "NotebookFusionSlots") as HBoxContainer
			var fusion_left := _find_node_by_name(root, "FusionSlotLeft") as Button
			var fusion_right := _find_node_by_name(root, "FusionSlotRight") as Button
			var fusion_button := _find_node_by_name(root, "NotebookFusionButton") as Button
			_assert_true(fusion_slots != null and fusion_left != null and fusion_right != null, "fusion tab should expose two meme drop slots")
			_assert_true(fusion_button != null and fusion_button.custom_minimum_size.y >= 52.0, "fusion tab should expose a touchable confirmation")
			_assert_true(_find_node_by_name(root, "NotebookTokenFlow") == null, "fusion tab should not mix in picked-glyph controls")
			meme_ring = _find_node_by_name(root, "MemeBankRadialRing") as Control
			if meme_ring != null:
				var actions_before_ring: int = int(root.game.actions_remaining)
				var selected_before_ring: String = str(root.selected_meme_id)
				var wheel_event := InputEventMouseButton.new()
				wheel_event.button_index = MOUSE_BUTTON_WHEEL_DOWN
				wheel_event.pressed = true
				_assert_true(bool(meme_ring.call("handle_navigation_event", wheel_event)), "mouse wheel should rotate the meme ring")
				_assert_true(root.selected_meme_id != selected_before_ring, "ring rotation should select the next completed meme")
				_assert_eq(root.game.actions_remaining, actions_before_ring, "browsing the meme ring should not spend an action")
		root.game._queue_ascent_reward(1)
		root.game.set_active_app("babel")
		root._render()
		var reward_choice_0 := _find_node_by_name(root, "AscentRewardChoice0") as Button
		var reward_choice_1 := _find_node_by_name(root, "AscentRewardChoice1") as Button
		var reward_choice_2 := _find_node_by_name(root, "AscentRewardChoice2") as Button
		_assert_true(reward_choice_0 != null and reward_choice_1 != null and reward_choice_2 != null, "Babel app should expose three ascent reward choices")
		if reward_choice_0 != null:
			_assert_true(reward_choice_0.custom_minimum_size.y >= 72.0, "ascent reward choices should be large enough to scan and tap")
			var actions_before_reward: int = root.game.actions_remaining
			reward_choice_0.pressed.emit()
			_assert_eq(root.game.actions_remaining, actions_before_reward, "choosing an ascent reward should not spend an action")
			_assert_eq(root.game.permanent_modifiers.size(), 1, "chosen ascent reward should persist in the run")
		root.game.set_active_app("notebook")
		root._render()
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
			var draggable_ids := ["phone", "app:babel", "app:social", "app:shop", "app:notebook", "bank", "settings"]
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
				_assert_true(bool(meme_bank_popup.get_meta("radial_meme_bank", false)), "meme bank should retain the right-edge radial layout after other windows move")
		if social_app_window != null and social_status_bar != null and root.has_method("_on_window_handle_gui_input"):
			_assert_true(not root._input_locked, "window dragging should begin with gameplay input unlocked")
			_assert_true(prologue == null or not prologue.visible, "completed prologue should not intercept later window dragging")
			var pointer_start := social_status_bar.global_position + Vector2(36, 24)
			var pointer_end := pointer_start + Vector2(52, 34)
			var direct_drag_start := social_app_window.position
			var drag_press := InputEventMouseButton.new()
			drag_press.button_index = MOUSE_BUTTON_LEFT
			drag_press.pressed = true
			drag_press.global_position = pointer_start
			root._on_window_handle_gui_input(drag_press, "app:social", social_app_window, social_status_bar)
			var drag_motion := InputEventMouseMotion.new()
			drag_motion.global_position = pointer_end
			root._on_window_handle_gui_input(drag_motion, "app:social", social_app_window, social_status_bar)
			var drag_release := InputEventMouseButton.new()
			drag_release.button_index = MOUSE_BUTTON_LEFT
			drag_release.pressed = false
			drag_release.global_position = pointer_end
			root._on_window_handle_gui_input(drag_release, "app:social", social_app_window, social_status_bar)
			_assert_true(social_app_window.position != direct_drag_start, "real mouse-event dragging should move the social phone window")
			var direct_drag_end := social_app_window.position
			root._render()
			_assert_eq(social_app_window.position, direct_drag_end, "real mouse-event dragged social phone position should survive render")
		_assert_true(_has_node_with_method(root, "set_drag_payload"), "notebook and bank items should expose drag payloads")
		_assert_true(_has_node_with_method(root, "configure_drop_target"), "slots and dialogue blank should expose drop targets")
		var frame_tab_again := _find_node_by_name(root, "NotebookCraftTabFrame") as Button
		if frame_tab_again != null:
			frame_tab_again.pressed.emit()
		root._on_slot_token_dropped({"kind": "token", "id": "n1"}, "glyph")
		_assert_eq(root.game.draft_slots.get("glyph", ""), "n1", "dropping one character should place it in the only craft slot")
		_assert_eq(root.game.actions_remaining, 5, "dropping token should not spend an action")
		var notebook_source_passive_strip := _find_node_by_name(root, "NotebookSourcePassiveStrip") as Label
		_assert_true(notebook_source_passive_strip != null and str(notebook_source_passive_strip.text).contains("回拨共鸣"), "notebook draft should preview active source card passives before crafting")
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
		if phone_popup != null and phone_content != null:
			_assert_true(not phone_popup.visible, "phone launcher should hide after putting the phone away")
			_assert_true(not phone_content.visible, "phone content should collapse after putting the phone away")
		meme_bank_popup = _find_node_by_name(root, "MemeBankPopup") as Control
		meme_bank_tab = _find_node_by_name(root, "MemeBankTab") as Button
		meme_bank_content = _find_node_by_name(root, "MemeBankContent") as Control
		if meme_bank_popup != null and meme_bank_tab != null and meme_bank_content != null:
			_assert_true(not meme_bank_popup.visible, "reality walking and NPC dialogue should hide the meme bank completely")
			_assert_true(not meme_bank_content.visible, "hidden reality meme bank should not reveal drawer content")
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
				if phone_down_backdrop_image != null:
					var walking_position_before := phone_down_backdrop_image.position
					root._animate_world(0.18)
					_assert_true(phone_down_backdrop_image.position != walking_position_before, "low-view generated backdrop should carry a subtle walking bob")
					_assert_true(phone_down_backdrop_image.scale.x > 1.0, "walking bob should keep the generated backdrop overscanned without exposing edges")
				_assert_true(camera.rotation_degrees.x < -35.0, "taking the phone should return the 3D camera to the downward phone view")
				root.set_view_state("npc_up")
				root._animate_world(1.0)
		if social_app_window != null and babel_app_window != null and shop_app_window != null:
			_assert_true(not social_app_window.visible, "NPC view should hide social app window")
			_assert_true(not babel_app_window.visible, "NPC view should hide Babel app window")
			_assert_true(not shop_app_window.visible, "NPC view should hide shop app window")
		if reality_subtitle != null and reality_choices != null and reality_typing_line != null:
			_assert_true(not reality_subtitle.visible, "free-walking NPC view should not show subtitles before an F interaction")
			_assert_true(not reality_choices.visible, "free-walking NPC view should keep response choices hidden")
			_assert_true(not reality_typing_line.visible, "free-walking NPC view should keep the typing line hidden")
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
		root.game.pollution = 100
		var reality_player := _find_node_by_name(root, "RealityPlayer") as CharacterBody3D
		var reality_merchant := _find_node_by_name(root, "Merchant") as Area3D
		if reality_player != null and reality_merchant != null and root.has_method("_try_reality_interaction"):
			reality_player.position = reality_merchant.position + Vector3(0.0, 0.0, 1.4)
			root._refresh_nearby_reality_actor()
			_assert_true(root._try_reality_interaction(), "approaching a billboard actor and pressing F should enter reality dialogue")
			for frame in 5:
				await process_frame
			reality_subtitle = _find_node_by_name(root, "RealitySubtitlePanel") as PanelContainer
			reality_choices = _find_node_by_name(root, "RealityResponseChoices") as HBoxContainer
			reality_intent_preview = _find_node_by_name(root, "RealityIntentPreview") as RichTextLabel
			reality_typing_line = _find_node_by_name(root, "RealityTypingLine") as RichTextLabel
			reality_typing_progress = _find_node_by_name(root, "RealityTypingProgress") as Label
			_assert_true(reality_subtitle != null and reality_subtitle.visible, "F interaction should reveal the movie subtitle")
			_assert_true(reality_subtitle_label != null and str(reality_subtitle_label.get("bbcode")).contains("我卖的是能装住一个字的空框"), "merchant copy should follow the current floor's unique language")
			_assert_true(reality_subtitle_label != null and not str(reality_subtitle_label.get("bbcode")).contains("听懂") and not str(reality_subtitle_label.get("bbcode")).contains("理解"), "reality dialogue should never tell the player whether an NPC understood")
			_assert_true(reality_subtitle_label != null and str(reality_subtitle_label.get("bbcode")).contains("[curspull"), "all NPC dialogue text should use the cursor-pull text effect")
			_assert_true(_rich_text_has_effect(reality_subtitle_label, "curspull"), "the plugin should install the curspull effect at runtime; got %s" % str(_rich_text_effect_names(reality_subtitle_label)))
			_assert_true(reality_choices != null and reality_choices.visible and reality_choices.get_child_count() == 3, "F interaction should reveal exactly three response choices")
			var choices: Array = root.game.get_typed_reality_choices()
			var first_choice_id := str(choices[0].get("id", ""))
			root._on_reality_choice_hovered(first_choice_id)
			_assert_true(reality_intent_preview != null and reality_intent_preview.visible, "hovering a short choice should reveal the complete intended sentence")
			_assert_true(reality_intent_preview != null and str(reality_intent_preview.get("bbcode")).contains("哈吉米，必须补票"), "hover preview should include inherited language automatically")
			_assert_true(reality_intent_preview != null and str(reality_intent_preview.get("bbcode")).contains("[curspull"), "hovered intent text should use the cursor-pull text effect")
			if reality_intent_preview != null and reality_subtitle != null:
				_assert_true(not _controls_overlap(reality_intent_preview, reality_subtitle), "full-intent hover preview should not obscure the previous NPC subtitle")
			root._on_reality_choice_selected(first_choice_id)
			_assert_eq(root.game.conversation_phase, "typing", "clicking a response should enter per-key typing")
			_assert_true(reality_choices != null and not reality_choices.visible, "typing should replace the three choice buttons")
			_assert_true(reality_typing_line != null and reality_typing_line.visible, "typing should reveal a fixed gray sentence below the NPC")
			var actions_before_typing := int(root.game.actions_remaining)
			_assert_true(root._advance_typed_reality_character(), "one arbitrary key path should reveal one character")
			root._render()
			for frame in 5:
				await process_frame
			_assert_eq(root.game.conversation_reveal_index, 1, "one arbitrary key should move the reveal cursor once")
			_assert_eq(root.game.actions_remaining, actions_before_typing, "partial per-key typing should not spend an action")
			var typed_bbcode := str(reality_typing_line.get("bbcode")).to_lower()
			_assert_true(typed_bbcode.contains("ff3b30"), "polluted revealed characters should render in signal red")
			_assert_true(typed_bbcode.contains("[curspull") and typed_bbcode.contains("[cuss]"), "typed dialogue should pull toward the cursor and apply cuss only to polluted glyphs")
			_assert_true(_rich_text_has_effect(reality_typing_line, "curspull") and _rich_text_has_effect(reality_typing_line, "cuss"), "the plugin should install both requested typing effects at runtime; got %s" % str(_rich_text_effect_names(reality_typing_line)))
			while root.game.conversation_phase == "typing":
				root._advance_typed_reality_character()
			if root._input_locked:
				root._finish_action_spend_animation()
			_assert_eq(root.game.actions_remaining, actions_before_typing - 1, "finishing the sentence should spend exactly one action")
			_assert_eq(root.game.conversation_understanding_rolls.size(), 3, "merchant listener should roll three pollution understanding checks")
			view_toggle_button = _find_node_by_name(root, "PhoneViewToggleButton") as Button
			if root._reality_interaction_active and view_toggle_button != null:
				_assert_true(not view_toggle_button.visible, "active cursor dialogue should hide the phone toggle from the response surface")
		root._reality_interaction_active = true
		root._active_reality_actor = reality_merchant
		root.game.conversation_actor_type = "merchant"
		root.game.conversation_actor_label = "信号商人"
		root.game.conversation_selected_choice_id = "trade"
		root.game.conversation_phase = "result"
		root.game.daily_communication_item_bought = false
		root._render()
		reality_merchant_offer = _find_node_by_name(root, "RealityMerchantOffer") as PanelContainer
		reality_merchant_buy = _find_node_by_name(root, "RealityMerchantBuyButton") as Button
		_assert_true(reality_merchant_offer != null and reality_merchant_offer.visible, "the authored trade response should reveal the merchant's limited-use item")
		_assert_true(reality_merchant_buy != null and not reality_merchant_buy.disabled, "affordable merchant item should be purchasable")
		var actions_before_item := int(root.game.actions_remaining)
		root._on_buy_communication_item()
		if root._input_locked:
			root._finish_action_spend_animation()
			_assert_eq(root.game.actions_remaining, actions_before_item - 1, "buying the merchant communication item should spend one action")
			_assert_true(not root.game.get_active_communication_item().is_empty(), "purchased communication item should expose remaining charges")
			reality_aid_status = _find_node_by_name(root, "RealityAidStatus") as Label
			_assert_true(reality_aid_status != null and reality_aid_status.visible, "active limited-use item should show its remaining charges during dialogue")
		root.game.ending_unlocked = true
		root._render()
		var ending_screen := _find_node_by_name(root, "EndingScreen") as Control
		var ending_title := _find_node_by_name(root, "EndingTitle") as Label
		var ending_body := _find_node_by_name(root, "EndingBody") as Label
		var ending_choices := _find_node_by_name(root, "EndingLanguageChoices") as HBoxContainer
		var ending_block_choice := _find_node_by_name(root, "EndingLanguageChoice_blocks") as Button
		_assert_true(ending_screen != null and bool(ending_screen.get_meta("empty_tower", false)), "tower ending should replace gameplay with a dedicated empty-tower screen")
		_assert_true(ending_title != null and ending_title.text == "塔顶没有人", "tower ending should state that nobody is waiting at the top")
		_assert_true(ending_body != null and str(ending_body.text).contains("没有智者"), "tower ending should make the sage's absence explicit")
		_assert_true(ending_body != null and str(ending_body.text).contains("没有接线的发射机"), "tower ending should resolve the no-signal city with original radio imagery")
		_assert_true(ending_choices != null and ending_choices.get_child_count() == 4, "tower ending should offer only blank, blocks, Hajimi, or silence")
		_assert_true(ending_block_choice != null, "block residue should be one of the four final language choices")
		if ending_block_choice != null:
			ending_block_choice.pressed.emit()
			await process_frame
			var ending_result := _find_node_by_name(root, "EndingLanguageResult") as Label
			_assert_true(ending_result != null and str(ending_result.text).contains("■ ■ ■ ■"), "committed final language should replace the four choices with its irreversible output")
			_assert_true(_find_node_by_name(root, "EndingLanguageChoices") == null, "final language choices should disappear after one is committed")
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


func _unique_social_captions(root: Node, count: int) -> int:
	var values := {}
	for index in count:
		var post: Dictionary = root._social_post_for_index(index)
		values[str(root._social_caption(post, index))] = true
	return values.size()


func _social_captions_fit_length(root: Node, count: int, minimum: int, maximum: int) -> bool:
	for index in count:
		var post: Dictionary = root._social_post_for_index(index)
		var length := str(root._social_caption(post, index)).length()
		if length < minimum or length > maximum:
			return false
	return true


func _social_pickups_follow_daily_limits(root: Node, count: int) -> bool:
	var original_day: int = root.game.day
	for day_number in range(1, 7):
		root.game.day = day_number
		var available_posts := 0
		var poster_cells := {}
		for index in count:
			var post: Dictionary = root._social_post_for_index(index)
			var tokens: Array = post.get("tokens", [])
			var post_tags: Array = post.get("tags", [])
			var passive: Dictionary = post.get("passive", {})
			if post_tags.is_empty() or passive.is_empty() or tokens.size() > 3:
				root.game.day = original_day
				return false
			poster_cells[int(post.get("poster_cell", -1))] = true
			if tokens.is_empty():
				continue
			available_posts += 1
			if tokens.size() < 2:
				root.game.day = original_day
				return false
			var has_tag_match := false
			for token in tokens:
				var token_passive: Dictionary = token.get("source_passive", {})
				if str(token_passive.get("id", "")) != str(passive.get("id", "")) or str(token.get("text", "")).length() != 1:
					root.game.day = original_day
					return false
				for tag in token.get("tags", []):
					if tag in post_tags:
						has_tag_match = true
			if not has_tag_match:
				root.game.day = original_day
				return false
		if available_posts < 2 or available_posts > 5 or poster_cells.size() != count:
			root.game.day = original_day
			return false
	root.game.day = original_day
	return true


func _generated_posters_are_varied() -> bool:
	var path := "res://assets/generated/social/poster_sheet.png"
	if not FileAccess.file_exists(path):
		return false
	var image := Image.new()
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK or image.is_empty():
		return false
	var cell_width := image.get_width() / 4
	var cell_height := image.get_height() / 3
	if cell_width <= 0 or cell_height <= 0:
		return false
	var fingerprints := {}
	for index in 12:
		var column := index % 4
		var row := floori(float(index) / 4.0)
		var samples: Array[String] = []
		for sample_y in range(1, 4):
			for sample_x in range(1, 4):
				var x := column * cell_width + int(cell_width * sample_x / 4.0)
				var y := row * cell_height + int(cell_height * sample_y / 4.0)
				samples.append(image.get_pixel(x, y).to_html())
		fingerprints["|".join(samples)] = true
	return fingerprints.size() >= 8


func _has_node_with_method(node: Node, method_name: String) -> bool:
	if node.has_method(method_name):
		return true
	for child in node.get_children():
		if _has_node_with_method(child, method_name):
			return true
	return false


func _signal_connection_is_deferred(node: Object, signal_name: StringName) -> bool:
	for connection in node.get_signal_connection_list(signal_name):
		if int(connection.get("flags", 0)) & CONNECT_DEFERRED:
			return true
	return false


func _is_descendant_of(node: Node, ancestor: Node) -> bool:
	var current := node.get_parent()
	while current != null:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false


func _rich_text_has_effect(label: RichTextLabel, effect_name: String) -> bool:
	if label == null:
		return false
	for effect in label.custom_effects:
		if str(effect.resource_name) == effect_name:
			return true
	return false


func _rich_text_effect_names(label: RichTextLabel) -> Array[String]:
	var names: Array[String] = []
	if label == null:
		return names
	for effect in label.custom_effects:
		names.append(str(effect.resource_name))
	return names


func _controls_overlap(a: Control, b: Control) -> bool:
	if a == null or b == null:
		return false
	if not a.is_visible_in_tree() or not b.is_visible_in_tree():
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
