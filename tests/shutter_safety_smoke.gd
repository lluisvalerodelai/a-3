extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for shutter_open in [false, true]:
		var world: Node2D = load("res://scenes/chambers/levels/18_door_must_close.tscn").instantiate()
		world.name = "ChamberRuntime"
		root.add_child(world)
		var echo := load("res://scenes/echoes/echo_actor.tscn").instantiate() as EchoActor
		echo.position = Vector2(930, 324)
		world.add_child(echo)
		if shutter_open:
			var holder := load("res://scenes/actors/player.tscn").instantiate() as PlayerController
			holder.control_mode = PlayerController.ControlMode.EXTERNAL
			holder.position = Vector2(240, 624)
			world.add_child(holder)
		for frame in 360:
			await physics_frame
			await process_frame
		_check(echo.get_player().is_dead() == shutter_open, "open shutter exposes Q; closed shutter protects it")
		world.queue_free()
		await process_frame
	if failures == 0:
		print("Shutter safety smoke test passed.")
	quit(0 if failures == 0 else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
