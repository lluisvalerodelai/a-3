class_name PlayerInputFrame
extends RefCounted

var move_axis := 0.0
var aim_direction := Vector2.RIGHT
var jump_pressed := false
var interact_pressed := false
var shoot_pressed := false
var throw_pressed := false
var restart_pressed := false


static func from_live_input() -> PlayerInputFrame:
	var frame := PlayerInputFrame.new()
	frame.move_axis = Input.get_axis("move_left", "move_right")
	frame.jump_pressed = Input.is_action_just_pressed("jump")
	frame.interact_pressed = Input.is_action_just_pressed("interact")
	frame.shoot_pressed = Input.is_action_just_pressed("shoot")
	frame.throw_pressed = Input.is_action_just_pressed("throw")
	frame.restart_pressed = Input.is_action_just_pressed("restart")
	return frame


func duplicate_frame() -> PlayerInputFrame:
	var copy := PlayerInputFrame.new()
	copy.move_axis = move_axis
	copy.aim_direction = aim_direction
	copy.jump_pressed = jump_pressed
	copy.interact_pressed = interact_pressed
	copy.shoot_pressed = shoot_pressed
	copy.throw_pressed = throw_pressed
	copy.restart_pressed = restart_pressed
	return copy
