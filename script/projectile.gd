extends Node2D
class_name Projectile

@export var velocity: Vector2 = Vector2(0,0)
@export var lifetime: float = 1.0
@export var destroy_on_impact: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (lifetime > 0):
		$Timer.wait_time = lifetime
		$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += velocity * delta


# Called when the child Area2D touches a body
func _on_body_entered(_body: Node) -> void:
	if destroy_on_impact:
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
