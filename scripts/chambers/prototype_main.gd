extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/player.tscn")
const ECHO_SCENE := preload("res://scenes/echoes/echo_actor.tscn")
const MEMORY_OVERLAY_SCENE := preload("res://scenes/ui/memory_overlay.tscn")
const PROJECTILE_SCENE := preload("res://scenes/combat/projectile.tscn")
const LEVEL_SCENES := [
	preload("res://scenes/chambers/levels/chamber_01_movement.tscn"),
	preload("res://scenes/chambers/levels/chamber_02_plate_door.tscn"),
	preload("res://scenes/chambers/levels/chamber_03_echo_switch.tscn"),
	preload("res://scenes/chambers/levels/chamber_04_carry_throw.tscn"),
	preload("res://scenes/chambers/levels/chamber_05_echo_platforms.tscn"),
	preload("res://scenes/chambers/levels/06_moving_enemy.tscn"),
	preload("res://scenes/chambers/levels/07_shooting_targets.tscn"),
	preload("res://scenes/chambers/levels/08_turret_timing.tscn"),
	preload("res://scenes/chambers/levels/09_rerecord_slot.tscn"),
	preload("res://scenes/chambers/levels/10_final_combined.tscn"),
	preload("res://scenes/chambers/levels/11_different_floor.tscn"),
	preload("res://scenes/chambers/levels/12_repossession.tscn"),
	preload("res://scenes/chambers/levels/13_shot_into_tomorrow.tscn"),
	preload("res://scenes/chambers/levels/14_burn_after_use.tscn"),
	preload("res://scenes/chambers/levels/15_right_of_way.tscn"),
	preload("res://scenes/chambers/levels/16_enemy_on_payroll.tscn"),
	preload("res://scenes/chambers/levels/17_parcel_appointment.tscn"),
	preload("res://scenes/chambers/levels/18_door_must_close.tscn"),
	preload("res://scenes/chambers/levels/19_delete_the_ladder.tscn"),
	preload("res://scenes/chambers/levels/20_last_rehearsal.tscn"),
]

const SLOT_COUNT := 3
const SPAWN_SEPARATION_DISTANCE := 40.0
const ECHO_COLOURS := preload("res://scripts/presentation/sketch.gd").ECHOES

var memory_bank := MemoryBank.new(SLOT_COUNT)
var runtime: Node2D
var player: PlayerController
var memory_overlay: MemoryOverlay
var selected_slot := 0
var pending_overwrite_slot := -1
var current_level_index := 0
var committed_echo_died := false
var cleared := false
var hud: CanvasLayer

var _spawn_overlap_pairs: Array[Dictionary] = []

@onready var status_label: Label = $Status


func _ready() -> void:
	hud = CanvasLayer.new()
	hud.set_script(preload("res://scripts/presentation/game_hud.gd"))
	add_child(hud)
	$Instructions.hide()
	memory_overlay = MEMORY_OVERLAY_SCENE.instantiate()
	add_child(memory_overlay)
	_start_recording_in_slot(0, false)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if cleared and event.physical_keycode in [KEY_ENTER, KEY_SPACE]:
		_advance_chamber()
		return
	if cleared:
		return
	match event.physical_keycode:
		KEY_1: _select_slot(0)
		KEY_2: _select_slot(1)
		KEY_3: _select_slot(2)
		KEY_C: _commit_current_attempt()
		KEY_X: _clear_selected_slot()
		KEY_R: _restart_current_attempt()


func _select_slot(slot_index: int) -> void:
	if slot_index == selected_slot and memory_bank.get_active_slot_index() == slot_index:
		return
	if memory_bank.slot_has_recording(slot_index) and pending_overwrite_slot != slot_index:
		pending_overwrite_slot = slot_index
		selected_slot = slot_index
		status_label.text = "Slot %d is committed. Press %d again to overwrite it." % [slot_index + 1, slot_index + 1]
		_refresh_overlay()
		return
	_start_recording_in_slot(slot_index, memory_bank.slot_has_recording(slot_index))


func _start_recording_in_slot(slot_index: int, overwrite_confirmed: bool) -> void:
	if memory_bank.get_active_slot_index() != -1:
		memory_bank.cancel_attempt()
	selected_slot = slot_index
	pending_overwrite_slot = -1
	memory_bank.begin_attempt(slot_index, overwrite_confirmed)
	_reset_runtime()
	status_label.text = "Chamber %d: recording slot %d." % [current_level_index + 1, slot_index + 1]
	_refresh_overlay()


func _commit_current_attempt() -> void:
	if memory_bank.commit_attempt():
		get_node("/root/Sound").play("commit")
		_reset_runtime()
		status_label.text = "Slot %d committed. Select a slot to record again." % [selected_slot + 1]
	_refresh_overlay()


func _clear_selected_slot() -> void:
	if memory_bank.get_active_slot_index() != -1:
		memory_bank.cancel_attempt()
	memory_bank.clear_slot(selected_slot)
	pending_overwrite_slot = -1
	_reset_runtime()
	status_label.text = "Slot %d cleared." % [selected_slot + 1]
	_refresh_overlay()


func _restart_current_attempt() -> void:
	get_node("/root/Sound").play("restart")
	var active_slot := memory_bank.get_active_slot_index()
	if active_slot != -1:
		memory_bank.cancel_attempt()
		memory_bank.begin_attempt(active_slot, memory_bank.slot_has_recording(active_slot))
	_reset_runtime()
	status_label.text = "Current recording restarted."
	_refresh_overlay()


func _advance_chamber() -> void:
	var next_level := (current_level_index + 1) % LEVEL_SCENES.size()
	if next_level == 0:
		hud.elapsed = 0.0
	start_chamber(next_level)


func start_chamber(level_index: int) -> void:
	if level_index < 0 or level_index >= LEVEL_SCENES.size():
		return
	current_level_index = level_index
	memory_bank = MemoryBank.new(SLOT_COUNT)
	selected_slot = 0
	pending_overwrite_slot = -1
	_start_recording_in_slot(0, false)


func get_chamber_title(level_index: int) -> String:
	return "Chamber %02d" % (level_index + 1)


func get_chamber_hint() -> String:
	return str(runtime.get_meta("hint", "Keep every echo alive and reach the gateway."))


func _reset_runtime() -> void:
	cleared = false
	committed_echo_died = false
	if is_instance_valid(runtime):
		runtime.process_mode = Node.PROCESS_MODE_DISABLED
		remove_child(runtime)
		runtime.queue_free()
	runtime = LEVEL_SCENES[current_level_index].instantiate()
	runtime.name = "ChamberRuntime"
	add_child(runtime)
	_dress_chamber()
	_wire_chamber()
	_spawn_committed_echoes()
	_spawn_player()
	_configure_spawn_overlap_grace()


func _physics_process(_delta: float) -> void:
	for pair_index in range(_spawn_overlap_pairs.size() - 1, -1, -1):
		var pair := _spawn_overlap_pairs[pair_index]
		var first := pair.first as PlayerController
		var second := pair.second as PlayerController
		if not is_instance_valid(first) or not is_instance_valid(second):
			_spawn_overlap_pairs.remove_at(pair_index)
			continue
		if first.global_position.distance_to(second.global_position) < SPAWN_SEPARATION_DISTANCE:
			continue
		first.remove_collision_exception_with(second)
		second.remove_collision_exception_with(first)
		_spawn_overlap_pairs.remove_at(pair_index)


func _configure_spawn_overlap_grace() -> void:
	_spawn_overlap_pairs.clear()
	var actors: Array[PlayerController] = []
	for node in _all_nodes(runtime):
		if node is PlayerController:
			actors.append(node)
	for first_index in range(actors.size()):
		for second_index in range(first_index + 1, actors.size()):
			var first := actors[first_index]
			var second := actors[second_index]
			first.add_collision_exception_with(second)
			second.add_collision_exception_with(first)
			_spawn_overlap_pairs.append({"first": first, "second": second})


func _wire_chamber() -> void:
	for node in _all_nodes(runtime):
		if node is ChamberExit:
			node.reached.connect(_on_exit_reached)
		elif node is TurretEnemy:
			node.projectile_scene = PROJECTILE_SCENE
	var early_plate := runtime.find_child("EarlySlotPlate", true, false) as PressurePlate
	var later_plate := runtime.find_child("LaterSlotPlate", true, false) as PressurePlate
	var exit_door := runtime.find_child("ExitDoor", true, false) as ChamberDoor
	if early_plate and later_plate and exit_door:
		early_plate.active_changed.connect(_refresh_rerecord_door)
		later_plate.active_changed.connect(_refresh_rerecord_door)
		_refresh_rerecord_door()
	var echo_plate := runtime.find_child("EchoPlate", true, false) as PressurePlate
	var crate_plate := runtime.find_child("CratePlate", true, false) as PressurePlate
	if echo_plate and crate_plate and exit_door:
		echo_plate.active_changed.connect(_refresh_final_door)
		crate_plate.active_changed.connect(_refresh_final_door)
		_refresh_final_door()


func _all_nodes(root: Node) -> Array[Node]:
	var result: Array[Node] = [root]
	for child in root.get_children():
		result.append_array(_all_nodes(child))
	return result


func _spawn_committed_echoes() -> void:
	var echo_spawn := runtime.find_child("EchoSpawn", true, false) as Marker2D
	var spawn_position := echo_spawn.global_position if echo_spawn else Vector2(120.0, 560.0)
	for slot_index in SLOT_COUNT:
		if not memory_bank.slot_has_recording(slot_index):
			continue
		var echo: EchoActor = ECHO_SCENE.instantiate()
		echo.position = spawn_position
		echo.setup(memory_bank.get_committed_frames(slot_index), ECHO_COLOURS[slot_index])
		echo.died.connect(_on_echo_died)
		runtime.add_child(echo)


func _spawn_player() -> void:
	var spawn := runtime.find_child("PlayerSpawn", true, false) as Marker2D
	player = PLAYER_SCENE.instantiate()
	player.position = spawn.global_position if spawn else Vector2(120.0, 560.0)
	player.died.connect(_on_player_died)
	player.input_frame_applied.connect(_record_input_frame)
	runtime.add_child(player)


func _record_input_frame(frame: PlayerInputFrame) -> void:
	if cleared or memory_bank.get_active_slot_index() == -1:
		return
	memory_bank.append_frame(EchoInputFrame.new(frame.move_axis, frame.jump_pressed, false, frame.interact_pressed, frame.shoot_pressed, frame.throw_pressed, frame.aim_direction))


func _refresh_rerecord_door(_active: bool = false) -> void:
	var early_plate := runtime.find_child("EarlySlotPlate", true, false) as PressurePlate
	var later_plate := runtime.find_child("LaterSlotPlate", true, false) as PressurePlate
	var door := runtime.find_child("ExitDoor", true, false) as ChamberDoor
	if early_plate and later_plate and door:
		door.set_open(early_plate.is_active() and later_plate.is_active())


func _refresh_final_door(_active: bool = false) -> void:
	var echo_plate := runtime.find_child("EchoPlate", true, false) as PressurePlate
	var crate_plate := runtime.find_child("CratePlate", true, false) as PressurePlate
	var door := runtime.find_child("ExitDoor", true, false) as ChamberDoor
	if echo_plate and crate_plate and door:
		door.set_open(echo_plate.is_active() and crate_plate.is_active())


func _on_player_died(_actor: PlayerController) -> void:
	_restart_current_attempt.call_deferred()


func _on_echo_died(_echo: EchoActor) -> void:
	committed_echo_died = true
	status_label.text = "Echo lost. Press R to retry, or select its slot twice to re-record."
	get_node("/root/Sound").play("restart")


func _on_exit_reached(_actor: Node2D) -> void:
	if cleared:
		return
	if committed_echo_died:
		status_label.text = "An echo died. This chamber cannot clear."
		return
	cleared = true
	runtime.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	get_node("/root/Sound").play("clear")
	status_label.text = "Chamber clear. Press Enter for the next chamber."


func _refresh_overlay() -> void:
	var states: Array = []
	for slot_index in SLOT_COUNT:
		states.append(memory_bank.get_slot_state(slot_index))
	memory_overlay.set_slot_states(states, selected_slot, memory_bank.get_active_slot_index())


func _dress_chamber() -> void:
	var background := runtime.get_node_or_null("Background")
	if background:
		background.hide()
	var art := Node2D.new()
	art.set_script(preload("res://scripts/presentation/chamber_art.gd"))
	art.chamber = current_level_index
	runtime.add_child(art)
	preload("res://scripts/presentation/chamber_dress.gd").apply(_all_nodes(runtime))
	var burst := Node2D.new()
	burst.set_script(preload("res://scripts/presentation/burst.gd"))
	var spawn := runtime.find_child("PlayerSpawn", true, false) as Marker2D
	burst.position = spawn.position if spawn else Vector2(120, 560)
	runtime.add_child(burst)
