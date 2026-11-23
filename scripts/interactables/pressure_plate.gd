class_name PressurePlate
extends Area2D

signal active_changed(active: bool)

const INACTIVE_COLOUR := Color("ff9f43")
const ACTIVE_COLOUR := Color("62f6a8")

@onready var pad: Polygon2D = $Pad

var _pressing_bodies: Array[Node2D] = []
var _active := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_apply_visual_state()


func is_active() -> bool:
	return _active


func _on_body_entered(body: Node2D) -> void:
	if not _can_press(body) or body in _pressing_bodies:
		return
	_pressing_bodies.append(body)
	_refresh_active_state()


func _on_body_exited(body: Node2D) -> void:
	if body not in _pressing_bodies:
		return
	_pressing_bodies.erase(body)
	_refresh_active_state()


func _can_press(body: Node2D) -> bool:
	return body is RigidBody2D or body.get("is_player_actor") == true


func _refresh_active_state() -> void:
	var next_active := not _pressing_bodies.is_empty()
	if next_active == _active:
		return
	_active = next_active
	get_node("/root/Sound").play("switch")
	_apply_visual_state()
	active_changed.emit(_active)


func _apply_visual_state() -> void:
	pad.color = ACTIVE_COLOUR if _active else INACTIVE_COLOUR
	pad.position.y = 4.0 if _active else 0.0
