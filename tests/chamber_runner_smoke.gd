extends SceneTree

var failures := 0


func _initialize() -> void:
	var main_scene := load("res://scenes/chambers/prototype_main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame
	_check(main.runtime != null, "runner creates a chamber runtime")
	_check(main.player != null, "runner creates the current player")
	_check(main.memory_bank.get_active_slot_index() == 0, "runner starts recording slot one")

	main._commit_current_attempt()
	await process_frame
	_check(main.memory_bank.slot_has_recording(0), "committing stores the current recording")
	_check(_count_echoes(main.runtime) == 1, "committed recording spawns one echo")

	_check(main.LEVEL_SCENES.size() == 20, "campaign includes ten teaching chambers and ten new puzzles")
	for expected_level in range(1, main.LEVEL_SCENES.size()):
		main._advance_chamber()
		await process_frame
		_check(main.current_level_index == expected_level, "runner advances chamber %d" % (expected_level + 1))
		_check(main.player != null, "chamber %d has a current player" % (expected_level + 1))
		_check(not main.get_chamber_title(expected_level).is_empty(), "each chamber has a title")
		_check(not main.get_chamber_hint().is_empty(), "each chamber has a hint")

	if failures == 0:
		print("Chamber runner smoke test passed.")
		quit(0)
	else:
		push_error("Chamber runner smoke test failed with %d failure(s)." % failures)
		quit(1)


func _count_echoes(root_node: Node) -> int:
	var count := 0
	for node in root_node.get_children():
		if node is EchoActor:
			count += 1
		count += _count_echoes(node)
	return count


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)
