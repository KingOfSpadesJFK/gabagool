extends Node2D


# Should the door already be opened or not
@export var opened: bool

# Animation playback speed
@export var speed = 1.0

# Which animation to use
@export_enum("90d Rotation", "180d Rotation", "Move Up") var animation = "90d Rotation"


# Called when the node enters the scene tree for the first time.
func _ready():
	if opened:
		$AnimationPlayer.current_animation = animation
		$AnimationPlayer.seek(1.0)


# Connect a signal to this function for the door to open
func _on_door_open():
	if not opened:
		$AnimationPlayer.play(animation, -1, speed)
		opened = true


# Connect a signal to this function for the door to close
func _on_door_close():
	if opened:
		$AnimationPlayer.play(animation, -1, -speed, true)
		opened = false


# Connect a signal to this function to toggle the door opening
func _on_door_toggle():
	if not opened:
		_on_door_open()
	else:
		_on_door_close()


func _on_area_2d_body_entered(body):
	if body is Player:
		pass
