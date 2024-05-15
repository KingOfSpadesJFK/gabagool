extends CharacterBody2D


# Path to the node to follow
@export var target_node: NodePath

@export var follow_weight = 4.0

# Path to the background camera or the background scene root
@export var background_camera: NodePath

@export var background_scroll_divisor = Vector2(16, 16)


var target: Node2D
var bgcam: Node3D
var bgdiv: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(target_node)
	bgdiv = Vector3(background_scroll_divisor.x, background_scroll_divisor.y, 1.0)
	bgcam = get_node(background_camera)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		var p = lerp(position, target.position, follow_weight * delta)
		velocity = p - position
		move_and_slide()

	if bgcam:
		bgcam.position = Vector3(position.x, -position.y, 0) / bgdiv
