extends Node2D

const Sketch := preload("res://scripts/presentation/sketch.gd")

@export var kind := "terrain"
var polygon := PackedVector2Array()
var bounds := Rect2()


func _ready() -> void:
	if not polygon.is_empty():
		bounds = Rect2(polygon[0], Vector2.ZERO)
		for point in polygon:
			bounds = bounds.expand(point)
	var subject := get_parent()
	if subject is ChamberDoor:
		subject.open_changed.connect(func(_open: bool): queue_redraw())
	if subject is PressurePlate:
		subject.active_changed.connect(func(_active: bool): queue_redraw())


func _draw() -> void:
	match kind:
		"terrain": _terrain()
		"door": _door()
		"plate": _plate()
		"crate": _crate()
		"target": _target()
		"enemy": _enemy()
		"turret": _turret()
		"hazard": _hazard()
		"projectile": _projectile()


func _terrain() -> void:
	if polygon.size() < 3:
		return
	draw_colored_polygon(polygon, Color("b9bbab"))
	Sketch.hatch(self, bounds.grow(-2), Color("686f5b70"), 8.0)
	Sketch.outline(self, polygon, Sketch.INK, 1.7)
	Sketch.stroke(self, bounds.position, Vector2(bounds.end.x, bounds.position.y), Sketch.INK, 2.3)
	Sketch.stroke(self, bounds.position + Vector2(1, 4), Vector2(bounds.end.x - 1, bounds.position.y + 4), Color("f3efdcaa"), 1.0)
	if bounds.size.x > 100 and bounds.size.y >= 20:
		var seed_value := global_position.x + global_position.y
		for index in range(int(bounds.size.x / 46)):
			var x := bounds.position.x + 18 + index * 46.0
			var y := bounds.position.y + 9 + fposmod(seed_value + index * 7.3, maxf(1, bounds.size.y - 14))
			Sketch.stroke(self, Vector2(x, y), Vector2(x + 8, y - 1), Color("525d4560"), 0.9, index)


func _door() -> void:
	var open: bool = get_parent().is_open()
	if open:
		for y in range(int(bounds.position.y), int(bounds.end.y), 10):
			Sketch.stroke(self, Vector2(bounds.position.x, y), Vector2(bounds.position.x, minf(y + 4, bounds.end.y)), Color("4b7c7270"), 1.0)
			Sketch.stroke(self, Vector2(bounds.end.x, y), Vector2(bounds.end.x, minf(y + 4, bounds.end.y)), Color("4b7c7270"), 1.0)
		return
	Sketch.box(self, bounds, Color("d8a491"), Sketch.RED, 1.7)
	Sketch.hatch(self, bounds.grow(-2), Color("af55455a"), 7.0)
	for y in range(int(bounds.position.y + 9), int(bounds.end.y), 19):
		Sketch.stroke(self, Vector2(bounds.position.x + 2, y), Vector2(bounds.end.x - 2, y + 1), Sketch.RED, 1.2, y)
	var center := bounds.get_center()
	Sketch.box(self, Rect2(center - Vector2(5, 7), Vector2(10, 14)), Sketch.LIGHT, Sketch.RED)
	draw_circle(center + Vector2(0, -1), 1.6, Sketch.RED)
	Sketch.stroke(self, center, center + Vector2(0, 4), Sketch.RED, 1.3)


func _plate() -> void:
	var active: bool = get_parent().is_active()
	var ink := Sketch.TEAL if active else Sketch.GOLD
	var y := 4.0 if active else 0.0
	Sketch.box(self, Rect2(-61, -1, 122, 10), Color("bab5a2"), Sketch.INK)
	Sketch.hatch(self, Rect2(-56, 2, 112, 5), Color("77766a60"), 7)
	var pad := PackedVector2Array([Vector2(-52, -10 + y), Vector2(52, -10 + y), Vector2(58, 2 + y), Vector2(-58, 2 + y)])
	draw_colored_polygon(pad, Color("b5c4a8") if active else Color("d9c18f"))
	Sketch.outline(self, pad, ink, 1.8)
	if active:
		Sketch.stroke(self, Vector2(-6, -5 + y), Vector2(-1, -1 + y), Sketch.TEAL, 1.7)
		Sketch.stroke(self, Vector2(-1, -1 + y), Vector2(8, -7 + y), Sketch.TEAL, 1.7)
	else:
		Sketch.ring(self, Vector2(0, -4), 3, ink, 1.1)


func _crate() -> void:
	Sketch.box(self, Rect2(-22, -22, 44, 44), Color("d5bd8e"), Sketch.INK, 1.6)
	Sketch.hatch(self, Rect2(-19, 12, 38, 7), Color("99835e88"), 6)
	Sketch.box(self, Rect2(-5, -21, 10, 42), Color("e7d5ad"), Color("a3916c"), 0.8)
	Sketch.stroke(self, Vector2(-21, -5), Vector2(21, -5), Sketch.PENCIL, 1.0)
	Sketch.stroke(self, Vector2(-21, -3), Vector2(21, -3), Sketch.PENCIL, 0.6)
	Sketch.box(self, Rect2(4, 3, 13, 9), Sketch.LIGHT, Sketch.PENCIL, 0.6)
	Sketch.stroke(self, Vector2(6, 6), Vector2(14, 6), Sketch.PENCIL, 0.7)
	Sketch.stroke(self, Vector2(6, 9), Vector2(11, 9), Sketch.PENCIL, 0.7)


func _target() -> void:
	Sketch.box(self, Rect2(-19, -19, 38, 38), Color("e6c4ac"), Sketch.RED, 1.5)
	Sketch.ring(self, Vector2.ZERO, 13, Sketch.RED, 1.6)
	Sketch.ring(self, Vector2.ZERO, 7, Sketch.RED, 1.1)
	draw_circle(Vector2.ZERO, 2.2, Sketch.RED)
	Sketch.stroke(self, Vector2(-18, -18), Vector2(-10, -10), Sketch.RED, 0.9)
	Sketch.stroke(self, Vector2(11, 11), Vector2(18, 18), Sketch.RED, 0.9)


func _enemy() -> void:
	var points := PackedVector2Array()
	for index in range(20):
		var angle := index * TAU / 20.0
		var radius := 25.0 if index % 2 == 0 else 20.0
		points.append(Vector2.from_angle(angle) * radius)
	draw_colored_polygon(points, Color("c2826c"))
	Sketch.outline(self, points, Sketch.RED, 1.5)
	Sketch.ring(self, Vector2.ZERO, 17, Sketch.INK, 1.2)
	Sketch.stroke(self, Vector2(-10, -7), Vector2(-3, -4), Sketch.INK, 2)
	Sketch.stroke(self, Vector2(10, -7), Vector2(3, -4), Sketch.INK, 2)
	draw_circle(Vector2(-6, 0), 2, Sketch.INK)
	draw_circle(Vector2(6, 0), 2, Sketch.INK)
	Sketch.stroke(self, Vector2(-5, 9), Vector2(5, 9), Sketch.INK, 1.3)


func _turret() -> void:
	Sketch.box(self, Rect2(-26, -26, 52, 52), Color("bc8572"), Sketch.INK, 1.7)
	Sketch.hatch(self, Rect2(-22, 13, 44, 10), Color("844c3e88"), 6)
	Sketch.box(self, Rect2(-38, -9, 33, 18), Color("9b9d8d"), Sketch.INK, 1.6)
	Sketch.stroke(self, Vector2(-34, -6), Vector2(-34, 6), Sketch.INK, 1.7)
	Sketch.ring(self, Vector2(8, -2), 10, Sketch.INK, 1.4)
	draw_circle(Vector2(7, -2), 3, Sketch.RED)
	Sketch.stroke(self, Vector2(4, -18), Vector2(15, -18), Sketch.INK, 1.2)


func _hazard() -> void:
	Sketch.box(self, bounds, Color("af55451a"), Color.TRANSPARENT)
	var x := bounds.position.x
	while x < bounds.end.x - 8:
		var points := PackedVector2Array([Vector2(x, bounds.end.y), Vector2(x + 6, bounds.position.y + 3), Vector2(x + 12, bounds.end.y)])
		draw_colored_polygon(points, Color("af554555"))
		Sketch.outline(self, points, Sketch.RED, 1)
		x += 16


func _projectile() -> void:
	Sketch.stroke(self, Vector2(-10, 0), Vector2(7, 0), Sketch.INK, 2.1)
	Sketch.stroke(self, Vector2(-11, -3), Vector2(-4, -3), Sketch.RED, 0.8)
	Sketch.stroke(self, Vector2(-13, 3), Vector2(-7, 3), Sketch.RED, 0.8)
	draw_circle(Vector2(5, 0), 3.2, Sketch.RED)
