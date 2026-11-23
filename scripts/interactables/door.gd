class_name ChamberDoor
extends StaticBody2D

signal open_changed(open: bool)

const CLOSED_COLOUR := Color("ff5d73")
const OPEN_COLOUR := Color(1.0, 0.36, 0.45, 0.22)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var door_visual: Polygon2D = $DoorVisual
@onready var core_visual: Polygon2D = $Core

var _open := false


func _ready() -> void:
	_apply_state()


func set_open(open: bool) -> void:
	if _open == open:
		return
	_open = open
	if is_node_ready():
		_apply_state()
	open_changed.emit(_open)


func is_open() -> bool:
	return _open


func _apply_state() -> void:
	collision_shape.set_deferred("disabled", _open)
	door_visual.color = OPEN_COLOUR if _open else CLOSED_COLOUR
	core_visual.modulate.a = 0.18 if _open else 1.0
