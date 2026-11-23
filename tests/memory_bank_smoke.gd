extends SceneTree

const MemoryBankScript := preload("res://scripts/memory/memory_bank.gd")
const EchoInputFrameScript := preload("res://scripts/memory/echo_input_frame.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	_run_tests()
	if _failures.is_empty():
		print("Memory bank smoke test passed.")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)


func _run_tests() -> void:
	var bank = MemoryBankScript.new(3)
	_expect(bank.get_slot_count() == 3, "Memory bank should create three slots.")
	_expect(not bank.slot_has_recording(0), "A new slot should be empty.")

	_expect(bank.begin_attempt(0), "An empty slot should begin recording.")
	var original = EchoInputFrameScript.new(0.75, true, false, true, false, true, Vector2.UP)
	_expect(bank.append_frame(original), "A recording should accept an input frame.")
	original.move_axis = -1.0
	original.aim_direction = Vector2.DOWN
	_expect(bank.commit_attempt(), "A recording should commit.")
	_expect(bank.slot_has_recording(0), "A committed slot should report a recording.")

	var committed = bank.get_committed_frames(0)
	_expect(committed.size() == 1, "The committed recording should contain one frame.")
	_expect(is_equal_approx(committed[0].move_axis, 0.75), "Appending should copy the source frame.")
	_expect(committed[0].aim_direction == Vector2.UP, "The copied frame should retain its aim direction.")
	committed[0].move_axis = -0.5
	_expect(
		is_equal_approx(bank.get_committed_frames(0)[0].move_axis, 0.75),
		"Reading committed frames should return copies."
	)

	_expect(bank.begin_attempt(1), "A second slot should record independently.")
	_expect(bank.append_frame(EchoInputFrameScript.new(-0.25)), "The second slot should accept a frame.")
	_expect(bank.commit_attempt(), "The second slot should commit.")
	_expect(not bank.begin_attempt(0), "A committed slot should require overwrite confirmation.")
	_expect(bank.begin_attempt(0, true), "Confirmed overwrite should begin recording.")
	_expect(
		bank.get_committed_frames(0).size() == 1,
		"The old recording should remain available until overwrite commits."
	)
	_expect(bank.append_frame(EchoInputFrameScript.new(-1.0)), "An overwrite should accept frames.")
	_expect(bank.append_frame(EchoInputFrameScript.new(1.0)), "An overwrite should accept multiple frames.")
	_expect(bank.commit_attempt(), "A confirmed overwrite should commit.")
	_expect(bank.get_committed_frames(0).size() == 2, "Overwrite should replace only its slot.")
	_expect(bank.get_committed_frames(1).size() == 1, "Overwrite should preserve unrelated slots.")

	_expect(bank.clear_slot(0), "A committed slot should clear.")
	_expect(not bank.slot_has_recording(0), "A cleared slot should become empty.")
	_expect(bank.slot_has_recording(1), "Clearing should preserve unrelated slots.")

	_expect(bank.begin_attempt(2), "The third slot should begin an empty recording.")
	_expect(bank.commit_attempt(), "An empty recording should still commit.")
	_expect(bank.slot_has_recording(2), "An empty committed recording should be retained.")
	_expect(bank.get_committed_frames(2).is_empty(), "An empty recording should contain no frames.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
