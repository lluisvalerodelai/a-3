class_name EchoInputFrame
extends RefCounted

var move_axis: float = 0.0
var aim_direction: Vector2 = Vector2.RIGHT
var jump_pressed: bool = false
var jump_held: bool = false
var interact_pressed: bool = false
var shoot_pressed: bool = false
var throw_pressed: bool = false


func _init(
	new_move_axis: float = 0.0,
	new_jump_pressed: bool = false,
	new_jump_held: bool = false,
	new_interact_pressed: bool = false,
	new_shoot_pressed: bool = false,
	new_throw_pressed: bool = false,
	new_aim_direction: Vector2 = Vector2.RIGHT
) -> void:
	move_axis = clampf(new_move_axis, -1.0, 1.0)
	aim_direction = new_aim_direction.normalized()
	if aim_direction == Vector2.ZERO:
		aim_direction = Vector2.RIGHT
	jump_pressed = new_jump_pressed
	jump_held = new_jump_held
	interact_pressed = new_interact_pressed
	shoot_pressed = new_shoot_pressed
	throw_pressed = new_throw_pressed


func copy() -> EchoInputFrame:
	return EchoInputFrame.new(
		move_axis,
		jump_pressed,
		jump_held,
		interact_pressed,
		shoot_pressed,
		throw_pressed,
		aim_direction
	)
