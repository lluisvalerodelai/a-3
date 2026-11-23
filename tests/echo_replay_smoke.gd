extends SceneTree

var failures := 0


func _initialize() -> void:
	var host := Node2D.new()
	root.add_child(host)
	var frames: Array[EchoInputFrame] = []
	for frame_index in 12:
		frames.append(EchoInputFrame.new(1.0, false, false, false, false, false, Vector2.RIGHT))
	var echo := (load("res://scenes/echoes/echo_actor.tscn") as PackedScene).instantiate() as EchoActor
	echo.position = Vector2(100.0, 100.0)
	echo.setup(frames)
	host.add_child(echo)
	for frame_index in 14:
		await physics_frame
	_check(echo.get_player().global_position.x > 100.0, "echo consumes recorded movement frames")
	_check(echo.is_finished(), "echo stops after the final recorded frame")
	if failures == 0:
		print("Echo replay smoke test passed.")
		quit(0)
	else:
		push_error("Echo replay smoke test failed with %d failure(s)." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)
