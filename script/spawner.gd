extends Node


# The scene to instantiate
@export_file('*.tscn') var scene

# Initial linear velocity of the scene (if applicable)
@export var linear_velocity: Vector2

# Initial angular velocity of the scene (if applicable)
@export var angular_velocity: float


func _on_spawn_instance(_body):
	var scene = load(scene).instantiate()
	if scene is CharacterBody2D:
		scene.velocity = linear_velocity
	elif scene is RigidBody2D:
		scene.angular_velocity = angular_velocity
		scene.linear_velocity = linear_velocity
	call_deferred("add_child", scene)
