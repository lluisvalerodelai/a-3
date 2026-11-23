class_name TurretEnemy
extends StaticBody2D

signal fired(projectile: Node2D)
signal defeated(turret: TurretEnemy)

@export var projectile_scene: PackedScene
@export var fire_direction := Vector2.LEFT
@export_range(0.1, 20.0, 0.1) var fire_interval := 1.5
@export var active := true

@onready var muzzle: Marker2D = $Muzzle
@onready var fire_timer: Timer = $FireTimer

var _defeated := false


func _ready() -> void:
	fire_timer.wait_time = fire_interval
	fire_timer.timeout.connect(fire_once)
	if active:
		fire_timer.start()


func set_active(value: bool) -> void:
	active = value
	if not is_node_ready():
		return
	if active:
		fire_timer.start(fire_interval)
	else:
		fire_timer.stop()


func set_fire_direction(direction: Vector2) -> void:
	if not direction.is_zero_approx():
		fire_direction = direction.normalized()


func fire_once() -> Node2D:
	if not active or _defeated or projectile_scene == null:
		return null
	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return null
	var host := get_parent()
	while host.get_parent() != null and host.name != "ChamberRuntime":
		if host.get_parent() == get_tree().root:
			break
		host = host.get_parent()
	host.add_child(projectile)
	projectile.global_position = muzzle.global_position
	var direction := fire_direction.normalized()
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	elif projectile.has_method("configure"):
		projectile.configure(direction)
	elif projectile.has_method("setup"):
		projectile.setup(muzzle.global_position, direction)
	fired.emit(projectile)
	return projectile


func hit_by_projectile(_direction: Vector2 = Vector2.ZERO, _force: float = 0.0) -> void:
	if _defeated:
		return
	_defeated = true
	fire_timer.stop()
	defeated.emit(self)
	queue_free()
