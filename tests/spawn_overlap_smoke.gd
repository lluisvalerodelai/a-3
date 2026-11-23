extends SceneTree

var failures := 0


func _initialize() -> void:
	var main := (load("res://scenes/chambers/prototype_main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	main._commit_current_attempt()
	await process_frame
	var echo := _find_echo(main.runtime)
	_check(echo != null, "committing creates an echo")
	if echo:
		var echo_body := echo.get_player()
		_check(main.player.get_collision_exceptions().has(echo_body), "spawned actors ignore each other while overlapping")
		echo_body.global_position += Vector2(50.0, 0.0)
		await physics_frame
		await process_frame
		_check(not main.player.get_collision_exceptions().has(echo_body), "actors collide again after separating")
	if failures == 0:
		print("Spawn overlap smoke test passed.")
		quit(0)
	else:
		push_error("Spawn overlap smoke test failed with %d failure(s)." % failures)
		quit(1)


func _find_echo(root_node: Node) -> EchoActor:
	for node in root_node.get_children():
		if node is EchoActor:
			return node
		var nested := _find_echo(node)
		if nested:
			return nested
	return null


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)
