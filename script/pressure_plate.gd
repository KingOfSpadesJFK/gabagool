extends Node2D

signal plate_pressed
signal plate_unpressed


# Weight of the pressure plate. The more weight, the more mass you will need to activate it
@export var weight = 10.0

# How long to press on the pressure plate to activate
@export var check_time = 1.0

var run_timer: bool
var pressed: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	$Plate.mass = weight
	pass # Replace with function body.


# This just locks the plate's x position
func _physics_process(_delta):
	$Plate.global_position.x = position.x
	$Plate.linear_velocity.x = 0.0
	pass


func _on_threshold_body_entered(body):
	if body is RigidBody2D:
		# Run the timer when the pressure plate is pressed
		if not run_timer:
			run_timer = true
			$CheckTimer.start(check_time)


func _on_threshold_body_exited(body):
	if body is RigidBody2D:
		if run_timer:
			run_timer = false
			$CheckTimer.stop()
		elif pressed:
			plate_unpressed.emit()
			pressed = false


func _on_check_timer_timeout():
	plate_pressed.emit()
	run_timer = false
	pressed = true
