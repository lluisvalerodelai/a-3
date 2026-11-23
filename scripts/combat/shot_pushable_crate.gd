class_name ShotPushableCrate
extends RigidBody2D

@export var projectile_force_multiplier := 1.0


func hit_by_projectile(direction: Vector2, force: float) -> void:
	var impact_direction := direction.normalized()
	if impact_direction == Vector2.ZERO:
		return
	linear_velocity += impact_direction * force * projectile_force_multiplier / mass
	sleeping = false
