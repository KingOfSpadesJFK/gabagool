extends Node2D

@export_file("*.tscn") var new_scene_path


func _on_begin_transition_body_entered(body):
	if body is Player:
		Gabagool.load_transition_scene(new_scene_path)


func _on_instantiate_transition_body_entered(body):
	if body is Player:
		Gabagool.instantiate_transition_scene()


func _on_end_transition_body_entered(body):
	if body is Player:
		Gabagool.transition_scene_to_main()
