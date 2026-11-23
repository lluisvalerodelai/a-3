class_name MemorySlot
extends RefCounted

enum State {
	EMPTY,
	RECORDING,
	COMMITTED,
}

var state: State = State.EMPTY
var _has_committed_recording: bool = false
var _committed_frames: Array[EchoInputFrame] = []
var _working_frames: Array[EchoInputFrame] = []


func is_empty() -> bool:
	return state == State.EMPTY


func is_recording() -> bool:
	return state == State.RECORDING


func is_committed() -> bool:
	return _has_committed_recording


func begin_recording(overwrite_confirmed: bool = false) -> bool:
	if state == State.RECORDING:
		return false
	if is_committed() and not overwrite_confirmed:
		return false
	_working_frames.clear()
	state = State.RECORDING
	return true


func append_frame(frame: EchoInputFrame) -> bool:
	if state != State.RECORDING or frame == null:
		return false
	_working_frames.append(frame.copy())
	return true


func restart_recording() -> bool:
	if state != State.RECORDING:
		return false
	_working_frames.clear()
	return true


func commit_recording() -> bool:
	if state != State.RECORDING:
		return false
	_committed_frames = _copy_frames(_working_frames)
	_has_committed_recording = true
	_working_frames.clear()
	state = State.COMMITTED
	return true


func cancel_recording() -> bool:
	if state != State.RECORDING:
		return false
	_working_frames.clear()
	state = State.COMMITTED if is_committed() else State.EMPTY
	return true


func clear() -> void:
	_has_committed_recording = false
	_committed_frames.clear()
	_working_frames.clear()
	state = State.EMPTY


func get_committed_frames() -> Array[EchoInputFrame]:
	return _copy_frames(_committed_frames)


func get_working_frame_count() -> int:
	return _working_frames.size()


func _copy_frames(source: Array[EchoInputFrame]) -> Array[EchoInputFrame]:
	var result: Array[EchoInputFrame] = []
	for frame in source:
		result.append(frame.copy())
	return result
