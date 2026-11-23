extends SceneTree

var failures := 0


func _initialize() -> void:
	var chamber := (load("res://scenes/chambers/levels/chamber_01_movement.tscn") as PackedScene).instantiate()
	root.add_child(chamber)
	var player := (load("res://scenes/actors/player.tscn") as PackedScene).instantiate() as PlayerController
	player.control_mode = PlayerController.ControlMode.EXTERNAL
	player.position = Vector2(120.0, 624.0)
	chamber.add_child(player)
	await process_frame
	for frame_index in 4:
		player.apply_input_frame(PlayerInputFrame.new())
		await physics_frame
		await process_frame
	var minimum_y := player.global_position.y
	for frame_index in 30:
		var frame := PlayerInputFrame.new()
		frame.jump_pressed = frame_index < 3
		player.apply_input_frame(frame)
		await physics_frame
		await process_frame
		minimum_y = minf(minimum_y, player.global_position.y)
	_check(minimum_y < 540.0, "player reaches the opening platform height")
	if failures == 0:
		print("Opening jump smoke test passed.")
		quit(0)
	else:
		push_error("Opening jump smoke test failed with %d failure(s)." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)
