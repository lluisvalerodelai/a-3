extends SceneTree

const PROJECTILE := preload("res://scenes/combat/projectile.tscn")
const TARGET := preload("res://scenes/combat/fragile_target.tscn")
const CRATE := preload("res://scenes/combat/shot_pushable_crate.tscn")
const PLATE := preload("res://scenes/interactables/pressure_plate.tscn")
const PLAYER := preload("res://scenes/actors/player.tscn")
const TURRET := preload("res://scenes/enemies/turret.tscn")

var failures := 0
var world: Node2D


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	world = Node2D.new()
	world.name = "ChamberRuntime"
	root.add_child(world)
	_wall(Vector2(650, 660), Vector2(1200, 40))
	var target := TARGET.instantiate() as FragileTarget
	target.position = Vector2(650, 500)
	world.add_child(target)
	var crate := CRATE.instantiate() as ShotPushableCrate
	crate.position = Vector2(650, 459)
	world.add_child(crate)
	var plate := PLATE.instantiate() as PressurePlate
	plate.position = Vector2(650, 632)
	world.add_child(plate)
	await _ticks(150)
	_check(absf(crate.position.y - 459) < 2, "crate rests on its fragile support")
	_fire(Vector2(550, 500), Vector2.RIGHT)
	await _ticks(100)
	_check(not is_instance_valid(target), "a travelling projectile breaks a static target")
	_check(crate.position.y > 610 and plate.is_active(), "a settled crate falls onto a plate when its support breaks")

	var barrier := _wall(Vector2(400, 300), Vector2(2, 100))
	var protected_target := TARGET.instantiate() as FragileTarget
	protected_target.position = Vector2(500, 300)
	world.add_child(protected_target)
	await _ticks(3)
	_fire(Vector2(350, 300), Vector2.RIGHT, 6000)
	await _ticks(10)
	_check(is_instance_valid(protected_target), "a fast shot cannot tunnel through a thin wall")
	barrier.queue_free()
	await _ticks(3)
	_fire(Vector2(350, 300), Vector2.RIGHT, 6000)
	await _ticks(10)
	_check(not is_instance_valid(protected_target), "the same shot hits after the wall is removed")

	var actor := PLAYER.instantiate() as PlayerController
	actor.control_mode = PlayerController.ControlMode.EXTERNAL
	actor.position = Vector2(900, 624)
	world.add_child(actor)
	var actor_plate := PLATE.instantiate() as PressurePlate
	actor_plate.position = Vector2(900, 632)
	world.add_child(actor_plate)
	await _ticks(10)
	_fire(Vector2(800, 624), Vector2.RIGHT)
	await _ticks(20)
	_check(actor.is_dead(), "friendly fire hits an actor even when a plate detector surrounds it")

	var thrower := PLAYER.instantiate() as PlayerController
	thrower.control_mode = PlayerController.ControlMode.EXTERNAL
	thrower.position = Vector2(100, 624)
	world.add_child(thrower)
	var parcel := CRATE.instantiate() as ShotPushableCrate
	parcel.position = Vector2(130, 618)
	world.add_child(parcel)
	await _ticks(8)
	var pickup := PlayerInputFrame.new()
	pickup.interact_pressed = true
	thrower.apply_input_frame(pickup)
	await _ticks(1)
	_check(thrower._held_body == parcel, "thrower picks up the nearby crate")
	var toss := PlayerInputFrame.new()
	toss.aim_direction = Vector2.UP
	toss.jump_pressed = true
	toss.throw_pressed = true
	thrower.apply_input_frame(toss)
	await _ticks(1)
	_check(absf(parcel.position.x - thrower.position.x) < 2 and parcel.position.y < thrower.position.y - 25, "throw starts at the current aim and actor position")

	var turret := TURRET.instantiate() as TurretEnemy
	turret.position = Vector2(1100, 250)
	turret.active = false
	turret.projectile_scene = PROJECTILE
	world.add_child(turret)
	turret.active = true
	var shot := turret.fire_once()
	_check(shot.get_parent() == world, "turret shots belong to the chamber that resets and freezes")
	world.queue_free()
	await process_frame
	_check(not is_instance_valid(shot), "resetting the chamber removes its turret shots")
	if failures == 0:
		print("Projectile physics smoke test passed.")
	quit(0 if failures == 0 else 1)


func _wall(point: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	body.position = point
	world.add_child(body)
	return body


func _fire(point: Vector2, direction: Vector2, speed := 900.0) -> void:
	var shot := PROJECTILE.instantiate() as EchoProjectile
	shot.speed = speed
	world.add_child(shot)
	shot.setup(point, direction)


func _ticks(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
