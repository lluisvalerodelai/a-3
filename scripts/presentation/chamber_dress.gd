extends RefCounted

const Sketch := preload("res://scripts/presentation/sketch.gd")
const WorldArt := preload("res://scripts/presentation/world_art.gd")


static func apply(nodes: Array[Node]) -> void:
	for node in nodes:
		if node is Label:
			node.add_theme_font_override("font", Sketch.HAND)
			node.add_theme_font_size_override("font_size", 19 if node.text.length() <= 3 else 18)
			node.add_theme_color_override("font_color", Sketch.PENCIL)
			if node.text.length() > 3:
				node.text = node.text.to_lower()
		elif node is Line2D:
			node.default_color = Color("77766a55")
			node.antialiased = true
		elif node is ChamberDoor:
			_attach(node, "door", node.get_node("DoorVisual").polygon)
		elif node is PressurePlate:
			_attach(node, "plate")
		elif node is ShotPushableCrate:
			_attach(node, "crate")
		elif node is FragileTarget:
			_attach(node, "target")
		elif node is MovingEnemy:
			_attach(node, "enemy")
		elif node is TurretEnemy:
			_attach(node, "turret")
		elif node is KillZone:
			_attach(node, "hazard", node.get_node("Warning").polygon)
		elif node is Polygon2D and node.get_parent() is StaticBody2D:
			var subject := node.get_parent()
			if subject is ChamberDoor or subject is FragileTarget or subject is TurretEnemy:
				continue
			var art := Node2D.new()
			art.set_script(WorldArt)
			art.polygon = node.polygon
			art.transform = node.transform
			node.hide()
			subject.add_child(art)


static func _attach(subject: Node2D, kind: String, polygon: PackedVector2Array = PackedVector2Array()) -> void:
	for child in subject.get_children():
		if child is Polygon2D:
			child.hide()
	var art := Node2D.new()
	art.set_script(WorldArt)
	art.kind = kind
	art.polygon = polygon
	subject.add_child(art)
