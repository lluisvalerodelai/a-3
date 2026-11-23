class_name MemoryBank
extends RefCounted

var _slots: Array[MemorySlot] = []
var _active_slot_index: int = -1


func _init(slot_count: int = 1) -> void:
	for index in range(maxi(slot_count, 1)):
		_slots.append(MemorySlot.new())


func get_slot_count() -> int:
	return _slots.size()


func get_active_slot_index() -> int:
	return _active_slot_index


func get_slot_state(slot_index: int) -> MemorySlot.State:
	if not _is_valid_slot(slot_index):
		return MemorySlot.State.EMPTY
	return _slots[slot_index].state


func slot_has_recording(slot_index: int) -> bool:
	return _is_valid_slot(slot_index) and _slots[slot_index].is_committed()


func begin_attempt(slot_index: int, overwrite_confirmed: bool = false) -> bool:
	if not _is_valid_slot(slot_index) or _active_slot_index != -1:
		return false
	if not _slots[slot_index].begin_recording(overwrite_confirmed):
		return false
	_active_slot_index = slot_index
	return true


func append_frame(frame: EchoInputFrame) -> bool:
	if _active_slot_index == -1:
		return false
	return _slots[_active_slot_index].append_frame(frame)


func restart_attempt() -> bool:
	if _active_slot_index == -1:
		return false
	return _slots[_active_slot_index].restart_recording()


func commit_attempt() -> bool:
	if _active_slot_index == -1:
		return false
	var slot := _slots[_active_slot_index]
	if not slot.commit_recording():
		return false
	_active_slot_index = -1
	return true


func cancel_attempt() -> bool:
	if _active_slot_index == -1:
		return false
	var slot := _slots[_active_slot_index]
	if not slot.cancel_recording():
		return false
	_active_slot_index = -1
	return true


func clear_slot(slot_index: int) -> bool:
	if not _is_valid_slot(slot_index):
		return false
	_slots[slot_index].clear()
	if _active_slot_index == slot_index:
		_active_slot_index = -1
	return true


func get_committed_frames(slot_index: int) -> Array[EchoInputFrame]:
	if not _is_valid_slot(slot_index):
		return []
	return _slots[slot_index].get_committed_frames()


func _is_valid_slot(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < _slots.size()
