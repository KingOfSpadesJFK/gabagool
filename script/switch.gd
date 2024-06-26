extends Area2D


signal switch_on
signal switch_off


@export var on: bool = false

# Whether this switch can only work once
@export var one_shot: bool = false
var used: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if on:
		$AnimatedSprite2D.play("on")
		switch_on.emit()	# Emit switch_on since it's starting as on


# Check every frame if the player is overlapping the switch
func _process(_delta):
	for body in get_overlapping_bodies():
		if body is Player:
			if body.is_interacting():
				flip_switch()


# Switch between the two states
func flip_switch():
	if not used:
		if on:
			$AnimatedSprite2D.play("off")
			switch_off.emit()
		else:
			$AnimatedSprite2D.play("on")
			switch_on.emit()
		on = not on
		if one_shot:
			used = true
