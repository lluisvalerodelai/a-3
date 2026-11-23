class_name MemoryOverlay
extends CanvasLayer

const Sketch := preload("res://scripts/presentation/sketch.gd")

const EMPTY := 0
const RECORDING := 1
const COMMITTED := 2

@onready var _slot_panels: Array[PanelContainer] = [
	$MarginContainer/Slots/Slot1,
	$MarginContainer/Slots/Slot2,
	$MarginContainer/Slots/Slot3,
]

var _states: Array = [EMPTY, EMPTY, EMPTY]
var _selected_index := 0
var _recording_index := -1


func _ready() -> void:
	for panel in _slot_panels:
		panel.get_child(0).mouse_filter = Control.MOUSE_FILTER_IGNORE
	$MarginContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$MarginContainer/Slots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh()


func set_slot_states(states: Array, selected_index: int, recording_index: int) -> void:
	_states = states.duplicate()
	_selected_index = selected_index
	_recording_index = recording_index
	if is_node_ready():
		_refresh()


func _refresh() -> void:
	for index in _slot_panels.size():
		var state := EMPTY
		if index < _states.size():
			state = int(_states[index])
		_update_slot(_slot_panels[index], index, state)


func _update_slot(panel: PanelContainer, index: int, state: int) -> void:
	var label: Label = panel.get_child(0)
	var is_selected := index == _selected_index
	var is_recording := index == _recording_index or state == RECORDING
	var ink: Color = Sketch.ECHOES[index]
	var state_name := "empty"
	if state == COMMITTED:
		state_name = "kept"
	if is_recording:
		state_name = "recording"
	label.text = "%d  %s\n%s" % [index + 1, "●" if is_recording else ("✓" if state == COMMITTED else "·"), state_name]
	label.add_theme_font_override("font", Sketch.HAND)
	label.add_theme_color_override("font_color", ink if state != EMPTY or is_selected else Sketch.PENCIL)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_constant_override("line_spacing", -6)
	panel.paper = Sketch.LIGHT.lerp(ink, 0.12 if is_selected or is_recording else 0.03)
	panel.ink = ink if is_selected or state != EMPTY else Sketch.FAINT
	panel.selected = is_selected
	panel.queue_redraw()
