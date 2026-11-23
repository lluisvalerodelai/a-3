extends Node2D

const Sketch := preload("res://scripts/presentation/sketch.gd")

var tint := Sketch.PENCIL
var age := 0.0
var duration := 0.38
var strength := 1.0


func _ready() -> void:
	z_index = 15


func _process(delta: float) -> void:
	age += delta
	if age >= duration:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var progress := age / duration
	var colour := tint.lerp(Sketch.PENCIL, 0.65)
	colour.a = (1.0 - progress) * 0.7
	for index in range(7):
		var direction := Vector2.from_angle(index * TAU / 7.0 + 0.2)
		var point := direction * (6.0 + progress * 35.0 * strength)
		Sketch.stroke(self, point, point + direction * 4.0 * (1.0 - progress), colour, 1.2, index)
		if index % 2 == 0:
			draw_circle(point * 0.7, 1.2 * (1.0 - progress), colour)
