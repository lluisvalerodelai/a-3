class_name FragileTarget
extends StaticBody2D

signal broken(target: FragileTarget)

var _is_broken := false


func hit_by_projectile(_direction: Vector2, _force: float) -> void:
	if _is_broken:
		return
	_is_broken = true
	broken.emit(self)
	queue_free()


func is_broken() -> bool:
	return _is_broken
