extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var main = load("res://scenes/chambers/prototype_main.tscn").instantiate()
	root.add_child(main)
	for level in main.LEVEL_SCENES.size():
		main.start_chamber(level)
		await process_frame
		await process_frame
		_check(not main.status_label.is_visible_in_tree(), "chamber %d keeps the status text hidden" % [level + 1])
		for child in main.hud.get_children():
			if child is Label and child.position.y < 160:
				_check(not child.is_visible_in_tree(), "no header text remains")
	var menu_rect: Rect2 = main.hud.chamber_menu.get_global_rect()
	_check(menu_rect.position.x >= 640 and menu_rect.end.y < 100, "level selection sits in the top right")
	var overlay: MemoryOverlay = main.memory_overlay
	for state in [MemoryOverlay.EMPTY, MemoryOverlay.RECORDING, MemoryOverlay.COMMITTED]:
		overlay.set_slot_states([state, state, state], 1, 1 if state == MemoryOverlay.RECORDING else -1)
		await process_frame
		for panel in overlay._slot_panels:
			_check(panel.get_global_rect().end.x < 1280, "recording slip stays on screen")
			_check(panel.get_global_rect().end.y < 100, "recording slip stays in the top right")
			_check(not panel.get_global_rect().intersects(menu_rect), "recording slips do not overlap level selection")
			var label: Label = panel.get_child(0)
			for line in label.text.split("\n"):
				_check(_text_width(label, line) <= label.size.x, "recording state fits its slip")
	main.hud.paused = true
	paused = true
	main.hud._refresh_modal()
	await process_frame
	_check(main.hud.modal.get_global_rect().end.y < 664, "pause card fits above controls")
	main.hud._activate()
	_check(not main.status_label.is_visible_in_tree(), "resuming does not restore header text")
	main.start_chamber(19)
	await process_frame
	main._on_exit_reached(main.player)
	await process_frame
	await process_frame
	_check(main.hud.action.text.contains("PLAY AGAIN"), "final page offers replay")
	_check(main.hud.modal.get_global_rect().end.x < 1280, "final message fits on screen")
	main.queue_free()
	await process_frame
	if failures == 0:
		print("Presentation smoke test passed.")
	quit(0 if failures == 0 else 1)


func _text_width(label: Label, value: String) -> float:
	return label.get_theme_font("font").get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
