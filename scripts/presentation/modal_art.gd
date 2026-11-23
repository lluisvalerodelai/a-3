extends Control

const Sketch := preload("res://scripts/presentation/sketch.gd")


func _ready() -> void:
	custom_minimum_size.y = 66
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var x := size.x * 0.5
	Sketch.ring(self, Vector2(x, 32), 28, Sketch.FAINT, 0.8)
	Sketch.box(self, Rect2(x - 13, 10, 26, 42), Color("d8dfc9"), Sketch.TEAL, 1.5)
	Sketch.stroke(self, Vector2(x - 8, 14), Vector2(x + 5, 18), Sketch.TEAL)
	Sketch.stroke(self, Vector2(x + 5, 18), Vector2(x + 5, 50), Sketch.TEAL)
	draw_circle(Vector2(x + 1, 34), 1.4, Sketch.TEAL)
	for index in range(5):
		var point := Vector2(x - 60 + index * 9, 55 - index * 2)
		Sketch.stroke(self, point, point + Vector2(3, -2), Sketch.PENCIL, 1.3)
	Sketch.stroke(self, Vector2(x + 36, 17), Vector2(x + 43, 12), Sketch.GOLD, 1.2)
	Sketch.stroke(self, Vector2(x + 39, 28), Vector2(x + 48, 27), Sketch.GOLD, 1.2)
