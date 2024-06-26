extends CharacterBody2D


# Path to the node to follow
@export var target_node: NodePath

@export var follow_weight = 4.0

# Path to the background camera or the background scene root
@export var background_camera: NodePath

@export var background_scroll_divisor = Vector2(16, 16)


var bgcam: Node3D
var bgdiv: Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	load_exports()
	Gabagool.transition_level_load.connect(_on_level_trans)
	

func load_exports():
	bgdiv = Vector3(background_scroll_divisor.x, background_scroll_divisor.y, 1.0)
	if has_node(background_camera):
		bgcam = get_node(background_camera)


# Reloads the exports upon level load
func _on_level_trans():
	load_exports()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_node(target_node):
		var target = get_node(target_node)
		var p = lerp(position, target.position, follow_weight * delta)
		var diff = p - position
		var direction = diff.normalized()
		var length = diff.length()
		velocity = direction * length
		move_and_slide()

	if has_node(background_camera):
		get_node(background_camera).position = Vector3(position.x, -position.y, 0) / bgdiv
