extends Node2D

const Sketch := preload("res://scripts/presentation/sketch.gd")

var clock := 0.0


func _process(delta: float) -> void:
	clock += delta
	queue_redraw()


func _draw() -> void:
	var frame := PackedVector2Array([Vector2(-27, 48), Vector2(-27, -46), Vector2(26, -48), Vector2(27, 48)])
	draw_colored_polygon(frame, Color("4b7c7220"))
	Sketch.outline(self, frame, Sketch.TEAL, 2.2)
	Sketch.hatch(self, Rect2(-22, -43, 9, 87), Color("4b7c7260"), 5)
	var door := PackedVector2Array([Vector2(-23, -43), Vector2(8, -34), Vector2(8, 45), Vector2(-23, 44)])
	draw_colored_polygon(door, Color("d3dbbe"))
	Sketch.outline(self, door, Sketch.TEAL, 1.3)
	draw_circle(Vector2(1, 9), 2, Sketch.TEAL)
	Sketch.stroke(self, Vector2(-32, 49), Vector2(33, 49), Sketch.INK, 1.6)
	var label_x := minf(-22.0, 1270.0 - global_position.x - 65.0)
	Sketch.text(self, Vector2(label_x, -59), "way out", 23, Sketch.TEAL)
	var bob := sin(clock * 2) * 1.5
	Sketch.stroke(self, Vector2(13, -6 + bob), Vector2(22, -6 + bob), Sketch.TEAL, 1.3)
	Sketch.stroke(self, Vector2(18, -10 + bob), Vector2(23, -6 + bob), Sketch.TEAL, 1.3)
	Sketch.stroke(self, Vector2(18, -2 + bob), Vector2(23, -6 + bob), Sketch.TEAL, 1.3)
