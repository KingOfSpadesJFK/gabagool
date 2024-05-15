# GdUnit generated TestSuite
class_name PlayerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://script/player.gd'

var player = preload("res://scene/player.tscn")
var scene = preload("res://test/scene/harpoon_test.tscn")


func test_harpoon_tile_check() -> void:
	# Instantiate the scene and get the player node
	var s = scene.instantiate()
	add_child(s)
	
	var p = s.get_node("Entities/Player")
	p.shoot_dir = Vector2(0,-1)
	p._on_shoot_timeout()

	# Process the player
	for i in range(10):
		for j in range(60):
			process_children(s, 1.0 / 60.0)

	assert_bool(p.at_harpoon_end())\
		.is_true()


func process_children(node, _delta):
	for child in node.get_children():
		process_children(child, _delta)
	
	if node.has_method("_process") and node.has_method("_physics_process"):
		node._process(_delta)
		node._physics_process(_delta)
