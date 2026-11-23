extends Node

var muted := false
var voices: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sound in ["jump", "shoot", "commit", "restart", "clear", "switch", "impact"]:
		sounds[sound] = load("res://assets/audio/%s.wav" % sound)
	for index in range(8):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -14.0
		add_child(voice)
		voices.append(voice)


func play(sound: String) -> void:
	if muted or not sounds.has(sound) or DisplayServer.get_name() == "headless":
		return
	for voice in voices:
		if not voice.playing:
			voice.stream = sounds[sound]
			voice.play()
			return


func toggle_mute() -> void:
	muted = not muted
	if muted:
		for voice in voices:
			voice.stop()


func _exit_tree() -> void:
	for voice in voices:
		voice.stop()
