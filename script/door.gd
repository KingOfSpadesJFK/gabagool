extends Node2D


# Should the door already be opened or not
@export var opened: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	if opened:
		$AnimationPlayer.play("open")


# Connect a signal to this function for the door to open
func _on_door_open():
	$AnimationPlayer.play("open")


# Connect a signal to this function for the door to close
func _on_door_close():
	$AnimationPlayer.play_backwards("open")
