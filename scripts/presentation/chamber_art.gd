extends Node2D

const Sketch := preload("res://scripts/presentation/sketch.gd")

var chamber := 0


func _ready() -> void:
	z_index = -5
	var paper := ColorRect.new()
	paper.size = Vector2(1280, 720)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grain := ShaderMaterial.new()
	grain.shader = preload("res://assets/ui/paper.gdshader")
	paper.material = grain
	add_child(paper)
	paper.show_behind_parent = true


func _draw() -> void:
	var pale := Color("aaa28b28")
	var pencil := Color("8c8a7628")
	var shift := float(chamber % 4) * 27.0
	draw_circle(Vector2(1028 - shift, 278), 62, Color("c6aa6630"))
	Sketch.ring(self, Vector2(1028 - shift, 278), 66, Color("b5a47c28"), 0.8)
	var hills := PackedVector2Array([Vector2(-20, 578), Vector2(88, 522), Vector2(171, 539), Vector2(290, 440 + shift), Vector2(390, 475), Vector2(520, 387 + shift), Vector2(677, 454), Vector2(805, 399), Vector2(955, 493), Vector2(1110, 457), Vector2(1300, 546), Vector2(1300, 650), Vector2(-20, 650)])
	draw_colored_polygon(hills, Color("b4b9a21b"))
	for index in range(hills.size() - 3):
		Sketch.stroke(self, hills[index], hills[index + 1], pencil, 0.9, index)
	for index in range(21):
		var x := 27.0 + index * 63.0
		var y := 567.0 + Sketch.wobble(index * 2.1) * 21.0
		Sketch.stroke(self, Vector2(x, y), Vector2(x + 60, y - 35), pale, 0.7, index)
	_cloud(Vector2(360 - shift, 269), 1.0)
	_cloud(Vector2(775 + shift, 222), 0.67)
	Sketch.stroke(self, Vector2(21, 170), Vector2(20, 643), Color("af55451b"), 0.8)
	for index in range(8):
		var y := 192.0 + index * 60.0
		draw_circle(Vector2(9, y), 2.5, Color("bdb39b55"))
		Sketch.ring(self, Vector2(9, y), 3.5, Color("c6bca44a"), 0.6)
	for index in range(4):
		var x := 470.0 + index * 23 + shift
		var y := 320.0 + sin(index * 2.3) * 13.0
		Sketch.stroke(self, Vector2(x - 4, y - 2), Vector2(x, y), Color("8b8e7744"), 0.8)
		Sketch.stroke(self, Vector2(x, y), Vector2(x + 5, y - 3), Color("8b8e7744"), 0.8)


func _cloud(center: Vector2, factor: float) -> void:
	var points := PackedVector2Array()
	for index in range(45):
		var x := -65.0 + index * 3.0
		var y := -sin(float(index) / 44 * PI) * (12 + 4 * sin(index * 0.35))
		points.append(center + Vector2(x, y) * factor)
	draw_polyline(points, Color("aaa28b30"), 0.9, true)
	Sketch.stroke(self, center + Vector2(-76, 6) * factor, center + Vector2(60, 6) * factor, Color("aaa28b24"), 0.7)
