extends Node2D
class_name Projectile

@export var velocity: Vector2 = Vector2(0,0)
@export var lifetime: float = 1.0
@export var destroy_on_impact: bool = false
@export var stop_on_impact: bool = false

signal impact
signal dead

var impacted = false
var tilemap_positions = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (lifetime > 0):
		$Timer.wait_time = lifetime
		$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not (stop_on_impact and impacted):
		position += velocity * delta


# Called when the child Area2D touches a body
func _on_body_entered(_body: Node) -> void:
	impacted = true
	impact.emit()
	if destroy_on_impact:
		dead.emit()
		queue_free()
	if _body is Crab:
		_body.queue_free()
		dead.emit()
		queue_free()


func _on_timer_timeout() -> void:
	dead.emit()
	queue_free()


func get_tilemap_positions() -> Array:
	return tilemap_positions
