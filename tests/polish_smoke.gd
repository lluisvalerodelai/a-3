extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main = load("res://scenes/chambers/prototype_main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	main.hud._unhandled_key_input(escape)
	_check(paused, "Escape pauses the simulation")
	var before: Vector2 = main.player.position
	await process_frame
	await process_frame
	_check(main.player.position == before, "player stays still while paused")
	_check(main.hud.modal.visible, "pause screen is visible")
	main.hud._activate()
	_check(not paused, "resume button unpauses the simulation")
	main._on_exit_reached(main.player)
	await process_frame
	_check(main.cleared and main.hud.modal.visible, "exit shows completion screen")
	_check(main.runtime.process_mode == Node.PROCESS_MODE_DISABLED, "completion freezes hazards and echoes")
	main.hud._activate()
	await process_frame
	_check(main.current_level_index == 1 and not main.cleared, "continue starts the next chamber")
	_check(not main.hud.modal.visible, "continuing dismisses completion screen")
	_check(main.hud.chamber_menu.get_popup().item_count == 20, "all chambers can be selected directly")
	main.hud.chamber_menu.get_popup().about_to_popup.emit()
	_check(paused, "opening the chamber picker pauses recordings")
	var elapsed_before: float = main.hud.elapsed
	await process_frame
	_check(main.hud.elapsed == elapsed_before, "the timer pauses with the chamber picker")
	main.hud.chamber_menu.get_popup().popup_hide.emit()
	_check(not paused, "closing the picker resumes the current attempt")
	main.hud.chamber_menu.get_popup().id_pressed.emit(10)
	await process_frame
	_check(main.current_level_index == 10 and not paused, "chamber picker starts the selected puzzle")
	main.current_level_index = main.LEVEL_SCENES.size() - 1
	main._reset_runtime()
	main._on_exit_reached(main.player)
	await process_frame
	_check(main.hud.action.text.contains("PLAY AGAIN"), "final chamber offers replay")
	main.hud._activate()
	await process_frame
	_check(main.current_level_index == 0, "replay returns to first chamber")
	_check(main.memory_bank.get_active_slot_index() == 0, "replay begins a fresh recording")
	main._on_echo_died(null)
	main._on_exit_reached(main.player)
	_check(not main.cleared, "a lost echo still prevents completion")
	main.queue_free()
	await process_frame
	if failures == 0:
		print("Polish smoke test passed.")
	quit(0 if failures == 0 else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
