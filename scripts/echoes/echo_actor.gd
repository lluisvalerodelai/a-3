class_name EchoActor
extends Node2D

signal finished(echo: EchoActor)
signal died(echo: EchoActor)

@export var echo_color := Color(0.68, 0.42, 1.0, 0.55)

@onready var player: PlayerController = $Player

var _frames: Array[EchoInputFrame] = []
var _frame_index := 0
var _finished := false


func _ready() -> void:
	process_physics_priority = -100
	player.control_mode = PlayerController.ControlMode.EXTERNAL
	player.can_clear_chamber = false
	player.actor_color = echo_color
	player.body_visual.color = echo_color
	player.died.connect(_on_player_died)


func setup(frames: Array[EchoInputFrame], color: Color = Color(0.68, 0.42, 1.0, 0.55)) -> void:
	_frames = _copy_frames(frames)
	_frame_index = 0
	_finished = false
	echo_color = color
	if is_node_ready():
		player.actor_color = echo_color
		player.body_visual.color = echo_color


func get_player() -> PlayerController:
	return player


func is_finished() -> bool:
	return _finished


func _physics_process(_delta: float) -> void:
	if _frame_index < _frames.size():
		player.apply_input_frame(_to_player_frame(_frames[_frame_index]))
		_frame_index += 1
		return
	if not _finished:
		_finished = true
		finished.emit(self)


func _to_player_frame(frame: EchoInputFrame) -> PlayerInputFrame:
	var player_frame := PlayerInputFrame.new()
	player_frame.move_axis = frame.move_axis
	player_frame.aim_direction = frame.aim_direction
	player_frame.jump_pressed = frame.jump_pressed
	player_frame.interact_pressed = frame.interact_pressed
	player_frame.shoot_pressed = frame.shoot_pressed
	player_frame.throw_pressed = frame.throw_pressed
	return player_frame


func _copy_frames(source: Array[EchoInputFrame]) -> Array[EchoInputFrame]:
	var result: Array[EchoInputFrame] = []
	for frame in source:
		result.append(frame.copy())
	return result


func _on_player_died(_actor: PlayerController) -> void:
	died.emit(self)
