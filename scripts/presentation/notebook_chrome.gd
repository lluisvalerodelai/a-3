extends Node2D

const Sketch := preload("res://scripts/presentation/sketch.gd")


func _draw() -> void:
	draw_rect(Rect2(0, 664, 1280, 56), Sketch.PAPER)
	Sketch.stroke(self, Vector2(29, 665), Vector2(1251, 665), Sketch.FAINT, 1.0)
	_key(Vector2(36, 679), "A D", 36)
	_key(Vector2(161, 679), "space", 53)
	_key(Vector2(285, 679), "E", 23)
	_key(Vector2(388, 679), "LMB", 40)
	_key(Vector2(519, 679), "RMB", 40)
	_key(Vector2(652, 679), "C", 23)
	_key(Vector2(789, 679), "X", 23)
	_key(Vector2(902, 679), "R", 23)
	_key(Vector2(1005, 679), "esc", 35)


func _key(point: Vector2, value: String, width: float) -> void:
	Sketch.box(self, Rect2(point, Vector2(width, 22)), Sketch.LIGHT, Sketch.PENCIL, 0.85)
	Sketch.text(self, point + Vector2(5, 16), value, 13, Sketch.INK, Sketch.BOOK)
