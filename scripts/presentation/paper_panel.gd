extends PanelContainer

const Sketch := preload("res://scripts/presentation/sketch.gd")

var paper := Sketch.LIGHT
var ink := Sketch.FAINT
var taped := false
var selected := false


func _ready() -> void:
	var spacing := StyleBoxEmpty.new()
	spacing.content_margin_left = 28 if taped else 8
	spacing.content_margin_right = 28 if taped else 8
	spacing.content_margin_top = 28 if taped else 5
	spacing.content_margin_bottom = 28 if taped else 5
	add_theme_stylebox_override("panel", spacing)
	resized.connect(queue_redraw)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	Sketch.box(self, Rect2(Vector2(3, 4), size), Color(0.22, 0.21, 0.17, 0.08), Color.TRANSPARENT)
	Sketch.box(self, Rect2(Vector2.ZERO, size), paper, ink, 1.6 if selected or taped else 0.9)
	if selected:
		Sketch.stroke(self, Vector2(7, size.y - 5), Vector2(size.x - 6, size.y - 6), ink, 2.0)
	if taped:
		var x := size.x * 0.5
		draw_colored_polygon(PackedVector2Array([Vector2(x - 52, -9), Vector2(x + 46, -13), Vector2(x + 50, 13), Vector2(x - 48, 17)]), Color("dacba8b8"))
		for index in range(12):
			Sketch.stroke(self, Vector2(x - 44 + index * 8, -8), Vector2(x - 39 + index * 8, 12), Color("c2b48e50"), 0.6)
