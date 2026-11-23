class_name PlayerController
extends CharacterBody2D

const PROJECTILE_SCENE := preload("res://scenes/combat/projectile.tscn")

signal died(actor: PlayerController)
signal input_frame_applied(frame: PlayerInputFrame)

enum ControlMode {
	LIVE,
	EXTERNAL,
}

@export var control_mode := ControlMode.LIVE
@export var move_speed := 240.0
@export var jump_velocity := -520.0
@export var gravity_scale := 1.0
@export var coyote_time := 0.12
@export var actor_color := Color("57e6ff")
@export var carry_distance := 38.0
@export var throw_force := 520.0

var is_player_actor := true
var can_clear_chamber := true

@onready var body_visual: Polygon2D = $BodyVisual
@onready var interaction_area: Area2D = $InteractionArea

var _pending_input_frame := PlayerInputFrame.new()
var _is_dead := false
var _aim_direction := Vector2.RIGHT
var _ground_grace_remaining := 0.0
var _jump_buffer_remaining := 0.0
var _held_body: RigidBody2D
var _held_collision_layer := 1
var _held_collision_mask := 1


func _ready() -> void:
	body_visual.color = actor_color
	body_visual.hide()
	var art := Node2D.new()
	art.set_script(load("res://scripts/presentation/actor_art.gd"))
	add_child(art)


func _physics_process(delta: float) -> void:
	var frame := _consume_input_frame()
	if control_mode == ControlMode.LIVE:
		frame.aim_direction = (get_global_mouse_position() - global_position).normalized()
		if frame.aim_direction == Vector2.ZERO:
			frame.aim_direction = _aim_direction
	_aim_direction = frame.aim_direction.normalized()
	if _aim_direction == Vector2.ZERO:
		_aim_direction = Vector2.RIGHT
	_simulate_frame(frame, delta)
	_update_held_body()
	_apply_actions(frame)
	_update_held_body()
	input_frame_applied.emit(frame.duplicate_frame())


func apply_input_frame(frame: PlayerInputFrame) -> void:
	_pending_input_frame = frame.duplicate_frame()


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	_release_held_body(false)
	set_physics_process(false)
	died.emit(self)


func is_dead() -> bool:
	return _is_dead


func _consume_input_frame() -> PlayerInputFrame:
	if control_mode == ControlMode.LIVE:
		return PlayerInputFrame.from_live_input()
	var frame := _pending_input_frame
	_pending_input_frame = PlayerInputFrame.new()
	return frame


func _simulate_frame(frame: PlayerInputFrame, delta: float) -> void:
	if is_on_floor():
		_ground_grace_remaining = coyote_time
	else:
		_ground_grace_remaining = maxf(0.0, _ground_grace_remaining - delta)
		velocity.y += _gravity() * delta
	if frame.jump_pressed:
		_jump_buffer_remaining = 0.1
	else:
		_jump_buffer_remaining = maxf(0.0, _jump_buffer_remaining - delta)
	if _jump_buffer_remaining > 0.0 and _ground_grace_remaining > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_remaining = 0.0
		if control_mode == ControlMode.LIVE:
			get_node("/root/Sound").play("jump")
		_ground_grace_remaining = 0.0
	velocity.x = frame.move_axis * move_speed
	move_and_slide()


func _apply_actions(frame: PlayerInputFrame) -> void:
	if frame.interact_pressed:
		if is_instance_valid(_held_body):
			_release_held_body(false)
		else:
			_pick_up_nearest_body()
	if frame.throw_pressed and is_instance_valid(_held_body):
		_release_held_body(true)
	if frame.shoot_pressed:
		_shoot()


func _pick_up_nearest_body() -> void:
	var nearest: RigidBody2D
	var nearest_distance := INF
	for body in interaction_area.get_overlapping_bodies():
		if not body is RigidBody2D or body.has_meta("echo_escape_holder"):
			continue
		var distance := global_position.distance_squared_to(body.global_position)
		if distance >= nearest_distance:
			continue
		nearest = body
		nearest_distance = distance
	if nearest == null:
		return
	_held_body = nearest
	_held_collision_layer = _held_body.collision_layer
	_held_collision_mask = _held_body.collision_mask
	_held_body.set_meta("echo_escape_holder", self)
	_held_body.freeze = true
	_held_body.collision_layer = 0
	_held_body.collision_mask = 0
	_update_held_body()


func _update_held_body() -> void:
	if not is_instance_valid(_held_body):
		_held_body = null
		return
	_held_body.global_position = global_position + _aim_direction * carry_distance
	_held_body.rotation = 0.0


func _release_held_body(should_throw: bool) -> void:
	if not is_instance_valid(_held_body):
		_held_body = null
		return
	var released_body := _held_body
	_held_body = null
	released_body.remove_meta("echo_escape_holder")
	released_body.collision_layer = _held_collision_layer
	released_body.collision_mask = _held_collision_mask
	released_body.freeze = false
	released_body.sleeping = false
	released_body.linear_velocity = velocity
	if should_throw:
		released_body.apply_central_impulse(_aim_direction * throw_force)


func _shoot() -> void:
	if control_mode == ControlMode.LIVE:
		get_node("/root/Sound").play("shoot")
	var projectile: EchoProjectile = PROJECTILE_SCENE.instantiate()
	var world_parent := _find_world_parent()
	world_parent.add_child(projectile)
	projectile.setup(global_position + _aim_direction * 24.0, _aim_direction)


func _find_world_parent() -> Node:
	var candidate := get_parent()
	while candidate.get_parent() != null and candidate.name != "ChamberRuntime":
		candidate = candidate.get_parent()
	return candidate


func _gravity() -> float:
	return float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)) * gravity_scale
