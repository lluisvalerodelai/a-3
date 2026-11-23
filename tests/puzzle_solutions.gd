extends SceneTree

var main: Node2D
var aim := Vector2.RIGHT
var frame_number := 0
var active_level := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	main = load("res://scenes/chambers/prototype_main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var requested := OS.get_cmdline_user_args()
	var levels := range(1, 21)
	if not requested.is_empty():
		levels = [int(requested[0])]
	for level in levels:
		active_level = level
		main.start_chamber(level - 1)
		await _prepare_player()
		print("SOLVING ", level, " ", main.get_chamber_title(level - 1))
		await call("_solve_%d" % level)
		_check(main.cleared, "live player reaches the exit")
		_check(not main.committed_echo_died, "all committed echoes survive")
		if level >= 11:
			for actor in main.runtime.get_children():
				if actor is EchoActor:
					_check(actor.is_finished(), "new chamber echoes finish their recordings before the clear")
		print("SOLVED ", level, " in ", frame_number, " simulated input frames")
	main.queue_free()
	await process_frame
	print("Puzzle solutions passed.")
	quit(0)


func _prepare_player() -> void:
	await process_frame
	main.player.control_mode = PlayerController.ControlMode.EXTERNAL
	aim = Vector2.RIGHT
	frame_number = 0
	await _wait(4)


func _frame(axis := 0.0, jump := false, interact := false, shoot := false, toss := false) -> void:
	var actor: PlayerController = main.player
	var frame := PlayerInputFrame.new()
	frame.move_axis = axis
	frame.jump_pressed = jump
	frame.interact_pressed = interact
	frame.shoot_pressed = shoot
	frame.throw_pressed = toss
	frame.aim_direction = aim
	actor.apply_input_frame(frame)
	await physics_frame
	await process_frame
	frame_number += 1
	_check(main.player == actor, "current attempt does not die or restart")
	_check(not main.committed_echo_died, "recorded actors stay alive")


func _wait(count: int) -> void:
	for index in count:
		await _frame()


func _walk_to(x: float, limit := 500) -> void:
	for index in limit:
		var distance: float = x - main.player.position.x
		if absf(distance) <= 2.1 or main.cleared:
			await _frame()
			return
		await _frame(signf(distance))
	_check(false, "walk reaches x=%s from %s" % [x, main.player.position])


func _jump_to(x: float) -> void:
	for index in 150:
		var distance: float = x - main.player.position.x
		var axis := signf(distance) if absf(distance) > 2.1 else 0.0
		await _frame(axis, index == 0)
		if main.cleared:
			return
		if index > 4 and main.player.is_on_floor():
			return
	_check(false, "jump lands at x=%s" % x)


func _interact() -> void:
	await _frame(0, false, true)
	await _wait(8)


func _commit() -> void:
	main._commit_current_attempt()
	await _prepare_player()


func _begin(slot: int) -> void:
	main._start_recording_in_slot(slot - 1, main.memory_bank.slot_has_recording(slot - 1))
	await _prepare_player()


func _retry() -> void:
	main._restart_current_attempt()
	await _prepare_player()


func _plate(letter: String) -> PressurePlate:
	return main.runtime.get_node("Plate" + letter) as PressurePlate


func _wait_plate(letter: String, limit := 900) -> void:
	for index in limit:
		if _plate(letter).is_active():
			await _wait(4)
			return
		await _frame()
	_check(false, "plate %s becomes active" % letter)


func _wait_broken(node_name: String, limit := 1800) -> void:
	for index in limit:
		if main.runtime.get_node_or_null(node_name) == null:
			return
		await _frame()
	_check(false, "%s is broken by the recorded shot" % node_name)


func _height(y: float) -> void:
	_check(absf(main.player.position.y - y) < 3, "standing height %s, actual %s" % [y, main.player.position])


func _check(condition: bool, message: String) -> void:
	if not condition:
		push_error("Chamber %d, frame %d: %s" % [active_level, frame_number, message])
		quit(1)


func _solve_11() -> void:
	await _walk_to(190)
	await _jump_to(300)
	_height(524)
	await _jump_to(450)
	_height(424)
	await _jump_to(565)
	_height(384)
	await _walk_to(970)
	await _wait(90)
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _walk_to(150)
		await _wait_plate("B")
		await _wait(180)
		await _walk_to(190)
		await _jump_to(370)
		await _walk_to(1190)


func _solve_1() -> void:
	await _walk_to(220)
	await _jump_to(340)
	_height(538)
	await _walk_to(510)
	await _jump_to(680)
	_height(448)
	await _walk_to(890)
	await _jump_to(1040)
	_height(358)
	await _walk_to(1160)


func _solve_2() -> void:
	await _walk_to(1130)


func _solve_3() -> void:
	await _walk_to(300)
	await _commit()
	await _wait(90)
	await _walk_to(230)
	await _jump_to(410)
	await _walk_to(1130)


func _solve_4() -> void:
	await _walk_to(230)
	await _interact()
	await _walk_to(360)
	aim = Vector2(0.7, -0.714).normalized()
	await _frame(0, true, false, false, true)
	await _wait(240)
	_check(main.runtime.get_node("Mechanics/ThrowPlate").is_active(), "thrown crate settles on the raised plate")
	await _walk_to(1160)


func _solve_5() -> void:
	await _walk_to(280)
	await _commit()
	await _begin(2)
	await _wait(90)
	await _walk_to(210)
	await _jump_to(400)
	await _jump_to(520)
	_height(508)
	await _commit()
	await _wait(300)
	await _walk_to(210)
	await _jump_to(400)
	await _walk_to(1160)


func _solve_6() -> void:
	aim = (main.runtime.get_node("MovingEnemy").position - main.player.position).normalized()
	await _frame(0, false, false, true)
	await _wait_broken("MovingEnemy")
	await _walk_to(500)
	await _jump_to(700)
	_height(490)
	await _walk_to(880)
	await _jump_to(1080)
	await _walk_to(1150)


func _solve_7() -> void:
	await _walk_to(560)
	aim = (Vector2(620, 600) - main.player.position).normalized()
	await _frame(0, false, false, true)
	await _wait_broken("LowTarget")
	aim = Vector2.RIGHT
	await _frame(0, false, false, true)
	await _wait_broken("Barrier")
	await _walk_to(1150)


func _solve_8() -> void:
	await _walk_to(330)
	await _jump_to(390)
	_height(504)
	await _walk_to(480)
	await _wait(60)
	await _walk_to(650)
	await _jump_to(720)
	_height(504)
	aim = (main.runtime.get_node("Turret").position - main.player.position).normalized()
	await _frame(0, false, false, true)
	await _wait_broken("Turret")
	await _jump_to(850)
	_height(454)
	await _jump_to(1040)
	await _walk_to(1120)


func _solve_9() -> void:
	await _walk_to(340)
	await _commit()
	await _begin(2)
	await _wait(120)
	await _walk_to(260)
	await _jump_to(450)
	await _walk_to(550)
	await _jump_to(620)
	_height(514)
	await _jump_to(760)
	_height(480)
	await _walk_to(820)
	await _commit()
	await _wait(500)
	await _walk_to(260)
	await _jump_to(450)
	await _walk_to(550)
	await _jump_to(620)
	await _jump_to(760)
	await _jump_to(940)
	await _jump_to(1120)
	await _walk_to(1150)


func _solve_10() -> void:
	await _walk_to(270)
	await _commit()
	await _wait(90)
	await _walk_to(200)
	await _jump_to(370)
	await _walk_to(450)
	await _interact()
	_check(is_instance_valid(main.player._held_body), "live player picks up the combined chamber crate")
	aim = (main.runtime.get_node("MovingEnemy").position - main.player.position).normalized()
	await _frame(0, false, false, true)
	await _wait_broken("MovingEnemy")
	aim = Vector2.RIGHT
	await _walk_to(722)
	await _interact()
	await _walk_to(380)
	await _jump_to(460)
	await _jump_to(650)
	_height(495)
	await _walk_to(750)
	aim = (main.runtime.get_node("Turret").position - main.player.position).normalized()
	await _frame(0, false, false, true)
	await _wait_broken("Turret")
	await _walk_to(740)
	await _jump_to(830)
	_height(424)
	await _jump_to(1020)
	await _walk_to(1170)


func _solve_12() -> void:
	await _walk_to(160)
	await _interact()
	_check(is_instance_valid(main.player._held_body), "recording picks up its crate")
	await _walk_to(242)
	await _interact()
	await _jump_to(340)
	await _jump_to(450)
	_height(524)
	await _walk_to(570)
	await _jump_to(700)
	_height(424)
	await _walk_to(820)
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _wait_plate("B")
		await _walk_to(242)
		await _interact()
		_check(is_instance_valid(main.player._held_body), "live player reclaims the crate")
		await _walk_to(922)
		await _interact()
		await _wait_plate("F")
		await _wait(180)
		await _jump_to(1030)
		await _walk_to(1220)


func _solve_14() -> void:
	await _walk_to(130)
	await _jump_to(220)
	_height(534)
	await _jump_to(370)
	_height(484)
	await _jump_to(500)
	_height(440)
	await _jump_to(650)
	_height(324)
	await _walk_to(800)
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _wait_plate("A")
		await _walk_to(360)
		aim = (Vector2(500, 510) - main.player.position).normalized()
		await _frame(0, false, false, true)
		await _wait_plate("B")
		await _wait(180)
		await _walk_to(420)
		await _jump_to(600)
		await _walk_to(1200)


func _solve_13() -> void:
	await _walk_to(300)
	await _wait(90)
	_height(624)
	await _wait(420)
	aim = (Vector2(850, 500) - main.player.position).normalized()
	await _frame(0, false, false, true)
	await _wait(60)
	_check(is_instance_valid(main.runtime.get_node_or_null("Support")), "the first shot is stopped by the shutter")
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _walk_to(160)
		await _jump_to(330)
		_height(284)
		await _walk_to(520)
		await _jump_to(680)
		_height(264)
		await _walk_to(720)
		await _wait_plate("B", 1200)
		await _wait(180)
		await _walk_to(1190)


func _solve_15() -> void:
	await _walk_to(1130)
	await _wait(600)
	await _walk_to(700)
	await _jump_to(630)
	_height(424)
	await _wait(180)
	await _walk_to(330)
	await _commit()
	await _begin(2)
	await _wait_plate("A")
	await _walk_to(158)
	aim = Vector2.LEFT
	await _interact()
	_check(is_instance_valid(main.player._held_body), "courier picks up the stored crate")
	aim = Vector2.RIGHT
	await _walk_to(400)
	while frame_number < 780:
		await _frame()
	await _walk_to(912)
	await _interact()
	await _jump_to(1040)
	await _wait_plate("B")
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _walk_to(1200)
		await _wait(90)
		_height(624)
		await _wait_plate("C", 1800)
		await _wait_plate("B")
		await _wait(180)
		await _walk_to(700)


func _solve_17() -> void:
	await _walk_to(320)
	await _jump_to(450)
	_height(304)
	await _jump_to(720)
	_height(404)
	await _walk_to(780)
	while frame_number < 600:
		await _frame()
	aim = Vector2.RIGHT
	await _interact()
	_check(not is_instance_valid(main.player._held_body), "receiver records an empty pickup")
	await _walk_to(850)
	await _jump_to(950)
	await _walk_to(1002)
	await _interact()
	await _walk_to(1070)
	await _jump_to(1170)
	_height(284)
	await _commit()
	await _begin(2)
	await _walk_to(450)
	await _wait(90)
	_height(624)
	await _walk_to(462)
	await _interact()
	_check(is_instance_valid(main.player._held_body), "sender collects the parcel")
	await _walk_to(520)
	aim = Vector2(0.45, -0.893).normalized()
	await _frame(0, true, false, false, true)
	await _wait(90)
	await _walk_to(520)
	await _wait_plate("C", 1200)
	await _wait_plate("B")
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _wait_plate("B", 1800)
		await _walk_to(320)
		await _jump_to(450)
		await _jump_to(720)
		await _walk_to(850)
		await _jump_to(950)
		await _walk_to(970)
		await _jump_to(1100)
		await _walk_to(1240)
		await _wait(90)
		_height(624)
		await _wait(180)
		await _walk_to(820)


func _solve_18() -> void:
	await _walk_to(240)
	await _wait(240)
	await _walk_to(310)
	await _jump_to(400)
	_height(524)
	await _jump_to(540)
	_height(424)
	await _walk_to(660)
	await _jump_to(850)
	_height(324)
	await _walk_to(930)
	await _wait(180)
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _wait(45)
		await _walk_to(180)
		await _jump_to(310)
		await _walk_to(650)
		await _wait_plate("Q")
		await _wait(300)
		await _walk_to(1220)


func _solve_20() -> void:
	await _walk_to(340)
	await _jump_to(420)
	_height(580)
	await _jump_to(540)
	_height(464)
	await _wait(90)
	await _commit()
	await _begin(2)
	await _wait(300)
	await _walk_to(382)
	await _interact()
	await _walk_to(722)
	await _interact()
	await _walk_to(160)
	await _commit()
	await _begin(3)
	await _wait_plate("Q", 1800)
	await _jump_to(300)
	await _walk_to(730)
	await _jump_to(850)
	await _walk_to(940)
	await _wait(90)
	_height(624)
	aim = (Vector2(540, 490) - main.player.position).normalized()
	await _frame(0, false, false, true)
	await _wait_broken("Support")
	await _wait_plate("B")
	await _wait(60)
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _wait_broken("Support")
		await _wait_plate("B", 1800)
		await _walk_to(100)
		await _jump_to(260)
		await _walk_to(470)
		await _jump_to(630)
		await _walk_to(700)
		await _interact()
		_check(is_instance_valid(main.player._held_body), "live player reuses the admission crate")
		aim = Vector2.RIGHT
		await _walk_to(620)
		await _jump_to(690)
		_height(554)
		await _jump_to(780)
		_height(424)
		await _jump_to(900)
		_height(404)
		await _walk_to(1062)
		await _interact()
		await _wait_plate("F")
		await _wait(180)
		await _jump_to(1170)
		await _walk_to(1240)


func _solve_16() -> void:
	await _walk_to(240)
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _wait_plate("B", 1800)
		await _wait(300)
		await _walk_to(180)
		await _jump_to(340)
		await _walk_to(1210)


func _solve_19() -> void:
	await _walk_to(150)
	await _jump_to(310)
	await _walk_to(500)
	await _commit()
	await _begin(2)
	await _wait(300)
	await _walk_to(150)
	await _jump_to(310)
	await _walk_to(400)
	await _jump_to(500)
	_height(592)
	await _wait(30)
	await _jump_to(650)
	_height(464)
	await _walk_to(800)
	await _commit()
	main.selected_slot = 0
	main._clear_selected_slot()
	await _prepare_player()
	await _begin(3)
	await _walk_to(170)
	await _interact()
	await _walk_to(462)
	await _interact()
	await _walk_to(300)
	await _wait_plate("B")
	await _commit()
	await _begin(1)
	await _wait_plate("B")
	await _walk_to(240)
	await _jump_to(400)
	await _walk_to(430)
	await _jump_to(600)
	await _walk_to(800)
	await _commit()
	for replay in 2:
		if replay:
			await _retry()
		await _wait_plate("C", 1800)
		await _wait(180)
		await _walk_to(240)
		await _jump_to(400)
		await _walk_to(430)
		await _jump_to(600)
		await _walk_to(730)
		await _jump_to(910)
		await _walk_to(1220)
