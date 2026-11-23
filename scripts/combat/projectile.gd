class_name EchoProjectile
extends Area2D

@export var speed := 900.0
@export var impact_force := 260.0
@export var lifetime := 3.0

var direction := Vector2.RIGHT
var _age := 0.0
var _spent := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func setup(origin: Vector2, shot_direction: Vector2) -> void:
	global_position = origin
	direction = shot_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	if _spent:
		return
	var next_position := global_position + direction * speed * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next_position, collision_mask)
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit.position
		_apply_impact(hit.collider)
		return
	global_position = next_position
	_age += delta
	if _age >= lifetime:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	_apply_impact(body)


func _apply_impact(target: Node) -> void:
	if _spent:
		return
	_spent = true
	get_node("/root/Sound").play("impact")
	var burst := Node2D.new()
	burst.set_script(preload("res://scripts/presentation/burst.gd"))
	burst.position = position
	burst.tint = Color("ffc785")
	burst.strength = 0.55
	get_parent().add_child(burst)
	if target.has_method("hit_by_projectile"):
		target.hit_by_projectile(direction, impact_force)
	elif target.has_method("die"):
		target.die()
	queue_free()
