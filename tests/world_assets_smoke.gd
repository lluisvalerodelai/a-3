extends SceneTree

var failures := 0


func _initialize() -> void:
	var host := Node2D.new()
	root.add_child(host)

	var door := (load("res://scenes/interactables/door.tscn") as PackedScene).instantiate() as ChamberDoor
	host.add_child(door)
	await process_frame
	door.set_open(true)
	await process_frame
	_check(door.is_open(), "door opens through its public API")
	_check(door.collision_shape.disabled, "open door disables collision")

	var target := (load("res://scenes/combat/fragile_target.tscn") as PackedScene).instantiate() as FragileTarget
	host.add_child(target)
	await process_frame
	target.hit_by_projectile(Vector2.RIGHT, 10.0)
	_check(target.is_broken(), "fragile target reacts to a projectile")

	var crate := (load("res://scenes/combat/shot_pushable_crate.tscn") as PackedScene).instantiate() as ShotPushableCrate
	host.add_child(crate)
	await process_frame
	crate.hit_by_projectile(Vector2.RIGHT, 100.0)
	await physics_frame
	await process_frame
	_check(crate.linear_velocity.x > 0.0, "projectile impact pushes a crate")

	var turret := (load("res://scenes/enemies/turret.tscn") as PackedScene).instantiate() as TurretEnemy
	turret.projectile_scene = load("res://scenes/combat/projectile.tscn")
	host.add_child(turret)
	await process_frame
	_check(turret.fire_once() != null, "turret creates a configured projectile")

	if failures == 0:
		print("World asset smoke test passed.")
		quit(0)
	else:
		push_error("World asset smoke test failed with %d failure(s)." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)
