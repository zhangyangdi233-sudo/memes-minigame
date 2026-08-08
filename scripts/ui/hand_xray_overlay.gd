class_name HandXRayOverlay
extends Control

const THUMB_TIP_INDEX := 4
const INDEX_TIP_INDEX := 8
const LOST_HAND_TIMEOUT_MSEC := 420
const MIN_FRAME_SIZE := Vector2(0.07, 0.06)
const SMOOTHING_WEIGHT := 0.36

var _layer_texture: Texture2D
var _tracking_enabled := false
var _frame_active := false
var _smoothed_rect := Rect2()
var _last_hands_msec := 0
var _fingertips: Array[Vector2] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	set_meta("xray_mode", "two_hand_thumb_index_bbox")


func set_layer_texture(texture: Texture2D) -> void:
	_layer_texture = texture
	queue_redraw()


func set_tracking_enabled(value: bool) -> void:
	_tracking_enabled = value
	if not value:
		_frame_active = false
		_fingertips.clear()
	_set_runtime_metadata()
	queue_redraw()


func ingest_hands(hands: Array, timestamp_msec: int = -1) -> bool:
	_last_hands_msec = Time.get_ticks_msec() if timestamp_msec < 0 else timestamp_msec
	if not _tracking_enabled or hands.size() < 2:
		_frame_active = false
		_fingertips.clear()
		_set_runtime_metadata()
		queue_redraw()
		return false
	var next_tips: Array[Vector2] = []
	for hand_index in 2:
		var hand: Variant = hands[hand_index]
		if not hand is Dictionary:
			return _deactivate_frame()
		var landmarks: Variant = hand.get("landmarks", [])
		if not landmarks is Array or landmarks.size() <= INDEX_TIP_INDEX:
			return _deactivate_frame()
		for tip_index in [THUMB_TIP_INDEX, INDEX_TIP_INDEX]:
			var point: Variant = landmarks[tip_index]
			if not point is Dictionary:
				return _deactivate_frame()
			next_tips.append(Vector2(
				clampf(float(point.get("x", 0.0)), 0.0, 1.0),
				clampf(float(point.get("y", 0.0)), 0.0, 1.0)
			))
	var target := _bounds_for_points(next_tips)
	if target.size.x < MIN_FRAME_SIZE.x or target.size.y < MIN_FRAME_SIZE.y:
		return _deactivate_frame()
	_fingertips = next_tips
	if _frame_active:
		_smoothed_rect = Rect2(
			_smoothed_rect.position.lerp(target.position, SMOOTHING_WEIGHT),
			_smoothed_rect.size.lerp(target.size, SMOOTHING_WEIGHT)
		)
	else:
		_smoothed_rect = target
	_frame_active = true
	_set_runtime_metadata()
	queue_redraw()
	return true


func is_frame_active() -> bool:
	return _frame_active and _tracking_enabled and _layer_texture != null


func get_frame_rect_normalized() -> Rect2:
	return _smoothed_rect


func expire_tracking_for_test() -> void:
	_last_hands_msec = Time.get_ticks_msec() - LOST_HAND_TIMEOUT_MSEC - 1
	_process(0.0)


func _process(_delta: float) -> void:
	if _frame_active and Time.get_ticks_msec() - _last_hands_msec > LOST_HAND_TIMEOUT_MSEC:
		_deactivate_frame()


func _draw() -> void:
	if not is_frame_active():
		return
	var destination := Rect2(_smoothed_rect.position * size, _smoothed_rect.size * size)
	var texture_size := Vector2(_layer_texture.get_width(), _layer_texture.get_height())
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var source := Rect2(_smoothed_rect.position * texture_size, _smoothed_rect.size * texture_size)
	draw_rect(destination.grow(8.0), Color(0.02, 0.08, 0.02, 0.44), true)
	draw_texture_rect_region(_layer_texture, destination, source, Color(0.83, 1.0, 0.78, 0.97))
	draw_rect(destination, Color("dfff78"), false, 3.0, true)
	draw_rect(destination.grow(5.0), Color(0.40, 1.0, 0.35, 0.42), false, 2.0, true)
	_draw_frame_corners(destination)
	for fingertip in _fingertips:
		var point := fingertip * size
		draw_circle(point, 8.0, Color(0.05, 0.10, 0.03, 0.88))
		draw_circle(point, 4.5, Color("efff94"))


func _draw_frame_corners(rect: Rect2) -> void:
	var length := minf(28.0, minf(rect.size.x, rect.size.y) * 0.22)
	var color := Color("efff94")
	var top_left := rect.position
	var top_right := Vector2(rect.end.x, rect.position.y)
	var bottom_left := Vector2(rect.position.x, rect.end.y)
	var bottom_right := rect.end
	for segment in [
		[top_left, top_left + Vector2(length, 0.0)], [top_left, top_left + Vector2(0.0, length)],
		[top_right, top_right + Vector2(-length, 0.0)], [top_right, top_right + Vector2(0.0, length)],
		[bottom_left, bottom_left + Vector2(length, 0.0)], [bottom_left, bottom_left + Vector2(0.0, -length)],
		[bottom_right, bottom_right + Vector2(-length, 0.0)], [bottom_right, bottom_right + Vector2(0.0, -length)],
	]:
		draw_line(segment[0], segment[1], color, 6.0, true)


func _bounds_for_points(points: Array[Vector2]) -> Rect2:
	var minimum := Vector2(1.0, 1.0)
	var maximum := Vector2.ZERO
	for point in points:
		minimum.x = minf(minimum.x, point.x)
		minimum.y = minf(minimum.y, point.y)
		maximum.x = maxf(maximum.x, point.x)
		maximum.y = maxf(maximum.y, point.y)
	return Rect2(minimum, maximum - minimum)


func _deactivate_frame() -> bool:
	_frame_active = false
	_fingertips.clear()
	_set_runtime_metadata()
	queue_redraw()
	return false


func _set_runtime_metadata() -> void:
	set_meta("frame_active", _frame_active)
	set_meta("frame_rect_normalized", _smoothed_rect)
