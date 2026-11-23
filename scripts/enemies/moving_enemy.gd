class_name MovingEnemy
extends CharacterBody2D

signal defeated(enemy: MovingEnemy)

@export var patrol_offset := Vector2(240.0, 0.0)
@export var move_speed := 100.0
@export var starts_toward_end := true

var _start_position: Vector2
var _end_position: Vector2
var _target_position: Vector2
var _defeated := false


func _ready() -> void:
	_start_position = global_position
	_end_position = _start_position + patrol_offset
	_target_position = _end_position if starts_toward_end else _start_position
	$DamageArea.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _defeated:
		return
	var distance := global_position.distance_to(_target_position)
	if distance <= 1.0:
		_target_position = _start_position if _target_position == _end_position else _end_position
		return
	velocity = global_position.direction_to(_target_position) * minf(move_speed, distance / delta)
	move_and_slide()


func hit_by_projectile(_direction: Vector2 = Vector2.ZERO, _force: float = 0.0) -> void:
	if _defeated:
		return
	_defeated = true
	velocity = Vector2.ZERO
	defeated.emit(self)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
