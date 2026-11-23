class_name ChamberExit
extends Area2D

signal reached(actor: Node2D)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$Glow.hide()
	$Core.hide()
	var art := Node2D.new()
	art.set_script(preload("res://scripts/presentation/portal_art.gd"))
	add_child(art)


func _on_body_entered(body: Node2D) -> void:
	if body.get("can_clear_chamber") == true:
		reached.emit(body)
