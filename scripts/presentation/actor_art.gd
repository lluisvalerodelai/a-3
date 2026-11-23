extends Node2D

const Sketch := preload("res://scripts/presentation/sketch.gd")

var actor: PlayerController
var clock := 0.0
var was_grounded := false


func _ready() -> void:
	actor = get_parent() as PlayerController


func _process(delta: float) -> void:
	clock += delta
	var grounded := actor.is_on_floor()
	if grounded and not was_grounded:
		scale = Vector2(1.13, 0.86)
		var burst := Node2D.new()
		burst.set_script(preload("res://scripts/presentation/burst.gd"))
		burst.position = actor.position + Vector2(0, 14)
		burst.tint = Sketch.PENCIL
		burst.strength = 0.25
		actor.get_parent().add_child(burst)
	elif not grounded and was_grounded and actor.velocity.y < 0:
		scale = Vector2(0.9, 1.08)
	scale = scale.lerp(Vector2.ONE, 1.0 - exp(-delta * 14.0))
	was_grounded = grounded
	queue_redraw()


func _draw() -> void:
	var is_echo := actor.control_mode == PlayerController.ControlMode.EXTERNAL
	var colour := actor.actor_color if is_echo else Sketch.RED
	var ink := colour.darkened(0.3) if is_echo else Sketch.INK
	var moving := absf(actor.velocity.x) > 5.0
	var stride := sin(clock * 17.0) * 3.0 if moving and was_grounded else 0.0
	var face := 1.0 if actor._aim_direction.x >= 0.0 else -1.0
	var coat := PackedVector2Array([Vector2(-6, -3), Vector2(5, -3), Vector2(8, 11), Vector2(-8, 11)])
	draw_colored_polygon(coat, colour)
	Sketch.outline(self, coat, ink, 1.2)
	Sketch.stroke(self, Vector2(-4, 11), Vector2(-5 - stride, 15), ink, 2.2)
	Sketch.stroke(self, Vector2(4, 11), Vector2(5 + stride, 15), ink, 2.2)
	Sketch.stroke(self, Vector2(-7 - stride, 15), Vector2(-3 - stride, 15), ink, 2.0)
	Sketch.stroke(self, Vector2(3 + stride, 15), Vector2(7 + stride, 15), ink, 2.0)
	draw_circle(Vector2(0, -9), 7, Sketch.LIGHT)
	Sketch.ring(self, Vector2(0, -9), 7, ink, 1.35)
	Sketch.stroke(self, Vector2(-6, -12), Vector2(1, -16), ink, 1.7)
	Sketch.stroke(self, Vector2(-3, -15), Vector2(4, -14), ink, 1.7)
	draw_circle(Vector2(face * 3, -9), 1.2, ink)
	Sketch.stroke(self, Vector2(face * 5, -6), Vector2(face * 7, -7), ink, 0.8)
	var flutter := sin(clock * 9) * (1.8 if moving else 0.6)
	var scarf_colour := Sketch.GOLD if not is_echo else colour.lightened(0.25)
	var tail := PackedVector2Array([Vector2(-4 * face, -2), Vector2(-15 * face, flutter), Vector2(-13 * face, 3 + flutter), Vector2(-4 * face, 0)])
	draw_colored_polygon(tail, scarf_colour)
	Sketch.outline(self, tail, ink, 0.7)
	Sketch.box(self, Rect2(-6, -3, 12, 3), scarf_colour, ink, 0.7)
	Sketch.stroke(self, Vector2(-4, 3), Vector2(-3, 8), colour.lightened(0.3), 0.8)
	Sketch.stroke(self, Vector2(6 * face, 3), Vector2(9 * face, 6), ink, 1.2)
	if is_echo:
		Sketch.ring(self, Vector2(0, -24), 4, colour, 0.9)
		Sketch.stroke(self, Vector2(-9, -22), Vector2(-12, -20), colour, 0.8)
		Sketch.stroke(self, Vector2(9, -22), Vector2(12, -20), colour, 0.8)
