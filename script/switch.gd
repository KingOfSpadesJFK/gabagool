extends Area2D


signal switch_on
signal switch_off


@export var on: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.flip_h = on
	if on:
		switch_on.emit()	# Emit switch_on since it's starting as on


func _process(_delta):
	for body in get_overlapping_bodies():
		if body is Player:
			if body.is_interacting():
				flip_switch()


# Switch between the two states
func flip_switch():
	if on:
		switch_off.emit()
	else:
		switch_on.emit()
	on = not on
	$Sprite2D.flip_h = on
