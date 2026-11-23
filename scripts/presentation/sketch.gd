extends RefCounted

const PAPER := Color("f1ead9")
const LIGHT := Color("faf5e8")
const INK := Color("383c37")
const PENCIL := Color("77766a")
const FAINT := Color("c7c1ae")
const TEAL := Color("4b7c72")
const RED := Color("af5545")
const GOLD := Color("b38a48")
const ECHOES := [Color("597e8c"), Color("997181"), Color("a28443")]
const HAND := preload("res://assets/fonts/Caveat.ttf")
const BOOK := preload("res://assets/fonts/Lora.ttf")


static func wobble(value: float) -> float:
	return sin(value * 1.73 + 0.4) * 0.6 + sin(value * 4.31) * 0.4


static func stroke(canvas: CanvasItem, from: Vector2, to: Vector2, colour: Color = INK, width: float = 1.4, seed_value: float = 0.0) -> void:
	var points := PackedVector2Array()
	var steps := maxi(2, int(from.distance_to(to) / 9.0))
	var normal := (to - from).normalized().orthogonal()
	for step in range(steps + 1):
		var weight := float(step) / steps
		var drift := wobble(step * 0.8 + seed_value) * sin(weight * PI) * 0.85
		points.append(from.lerp(to, weight) + normal * drift)
	canvas.draw_polyline(points, colour, width, true)


static func outline(canvas: CanvasItem, points: PackedVector2Array, colour: Color = INK, width: float = 1.4) -> void:
	for index in points.size():
		stroke(canvas, points[index], points[(index + 1) % points.size()], colour, width, index * 3.7)


static func box(canvas: CanvasItem, rect: Rect2, fill: Color, border: Color = INK, width: float = 1.4) -> void:
	var a := rect.position
	var b := rect.end
	var points := PackedVector2Array([a + Vector2(0, 1), Vector2(b.x, a.y), b + Vector2(-0.6, -0.4), Vector2(a.x + 0.5, b.y)])
	canvas.draw_colored_polygon(points, fill)
	outline(canvas, points, border, width)


static func ring(canvas: CanvasItem, center: Vector2, radius: float, colour: Color = INK, width: float = 1.2, seed_value: float = 0.0) -> void:
	var points := PackedVector2Array()
	for index in range(41):
		var angle := float(index) / 40.0 * TAU
		var r := radius + wobble(angle * 3 + seed_value) * 0.55
		points.append(center + Vector2.from_angle(angle) * r)
	canvas.draw_polyline(points, colour, width, true)


static func hatch(canvas: CanvasItem, rect: Rect2, colour: Color, spacing: float = 9.0) -> void:
	var height := rect.size.y
	var offset := -height
	while offset < rect.size.x:
		var start := Vector2(maxf(offset, 0), height - maxf(-offset, 0))
		var end := Vector2(minf(offset + height, rect.size.x), maxf(offset + height - rect.size.x, 0))
		stroke(canvas, rect.position + start, rect.position + end, colour, 0.65, offset)
		offset += spacing


static func text(canvas: CanvasItem, point: Vector2, value: String, size: int = 22, colour: Color = PENCIL, font: Font = HAND) -> void:
	canvas.draw_string(font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, colour)


static func button_style(texture_name: String) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load("res://assets/ui/" + texture_name + ".svg")
	style.texture_margin_left = 12
	style.texture_margin_right = 12
	style.texture_margin_top = 12
	style.texture_margin_bottom = 12
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


static func theme() -> Theme:
	var result := Theme.new()
	result.default_font = BOOK
	result.default_font_size = 14
	for type_name in ["Button", "MenuButton", "PopupMenu"]:
		result.set_color("font_color", type_name, INK)
		result.set_color("font_hover_color", type_name, INK)
		result.set_color("font_pressed_color", type_name, LIGHT)
		result.set_color("font_focus_color", type_name, INK)
		result.set_stylebox("normal", type_name, button_style("button"))
		result.set_stylebox("hover", type_name, button_style("button-hover"))
		result.set_stylebox("pressed", type_name, button_style("button-pressed"))
		result.set_stylebox("focus", type_name, button_style("focus"))
	result.set_stylebox("panel", "PopupMenu", button_style("button"))
	result.set_stylebox("hover", "PopupMenu", button_style("button-hover"))
	result.set_color("font_hover_color", "PopupMenu", INK)
	result.set_constant("v_separation", "PopupMenu", 6)
	return result
