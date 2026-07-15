extends Container
class_name RadialMemeRing

signal selection_changed(index: int)

const PAN_STEP_THRESHOLD := 1.35
const ITEM_ANGLE_STEP := 0.46

var selected_index := 0
var _pan_accumulator := 0.0
var _ring_color := Color("E7F1DC")
var _inner_color := Color("AAB8A7")
var _focus_color := Color("365B2D")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = false
	gui_input.connect(_on_ring_gui_input)
	resized.connect(_queue_ring_layout)
	queue_redraw()


func set_palette(ring_color: Color, inner_color: Color, focus_color: Color) -> void:
	_ring_color = ring_color
	_inner_color = inner_color
	_focus_color = focus_color
	queue_redraw()


func set_selected_index(value: int, emit_change: bool = false) -> void:
	var count := get_child_count()
	var next_index := 0 if count <= 0 else posmod(value, count)
	if selected_index == next_index:
		_queue_ring_layout()
		return
	selected_index = next_index
	_queue_ring_layout()
	if emit_change:
		selection_changed.emit(selected_index)


func step_selection(direction: int) -> bool:
	if direction == 0 or get_child_count() <= 0:
		return false
	set_selected_index(selected_index + direction, true)
	return true


func handle_navigation_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			return step_selection(-1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			return step_selection(1)
	if event is InputEventPanGesture:
		var pan := event as InputEventPanGesture
		var dominant_delta := pan.delta.y if absf(pan.delta.y) >= absf(pan.delta.x) else pan.delta.x
		_pan_accumulator += dominant_delta
		if absf(_pan_accumulator) >= PAN_STEP_THRESHOLD:
			var direction := 1 if _pan_accumulator > 0.0 else -1
			_pan_accumulator = 0.0
			return step_selection(direction)
	return false


func _on_ring_gui_input(event: InputEvent) -> void:
	if handle_navigation_event(event):
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_layout_ring_items()


func _draw() -> void:
	_draw_ring()


func _queue_ring_layout() -> void:
	queue_sort()
	queue_redraw()


func _layout_ring_items() -> void:
	var count := get_child_count()
	if count <= 0:
		return
	selected_index = posmod(selected_index, count)
	var center := Vector2(size.x * 0.63, size.y * 0.52)
	var radius := minf(size.x, size.y) * 0.365
	for index in count:
		var child := get_child(index) as Control
		if child == null:
			continue
		var cyclic_delta := _cyclic_delta(index, selected_index, count)
		var angle := PI + float(cyclic_delta) * ITEM_ANGLE_STEP
		var is_selected := cyclic_delta == 0
		var item_size := Vector2(178.0, 70.0) if is_selected else Vector2(134.0, 54.0)
		var item_center := center + Vector2(cos(angle), sin(angle)) * radius
		fit_child_in_rect(child, Rect2(item_center - item_size * 0.5, item_size))
		child.z_index = 8 if is_selected else maxi(1, 6 - absi(cyclic_delta))
		child.modulate = Color(1.0, 1.0, 1.0, 1.0 if is_selected else clampf(0.92 - float(absi(cyclic_delta)) * 0.12, 0.28, 0.82))


func _draw_ring() -> void:
	var center := Vector2(size.x * 0.63, size.y * 0.52)
	var radius := minf(size.x, size.y) * 0.365
	draw_arc(center, radius + 42.0, 0.0, TAU, 192, _ring_color, 54.0, true)
	draw_arc(center, radius, 0.0, TAU, 192, _inner_color, 5.0, true)
	draw_arc(center, radius - 58.0, 0.0, TAU, 192, _ring_color.darkened(0.12), 3.0, true)
	var focus := center + Vector2.LEFT * radius
	draw_line(focus + Vector2(-34.0, -44.0), focus + Vector2(-34.0, 44.0), _focus_color, 5.0, true)
	draw_circle(center, 5.0, _focus_color)


func _cyclic_delta(index: int, selected: int, count: int) -> int:
	var delta := index - selected
	var half := float(count) * 0.5
	if float(delta) > half:
		delta -= count
	elif float(delta) < -half:
		delta += count
	return delta
