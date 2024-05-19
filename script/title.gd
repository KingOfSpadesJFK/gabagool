extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_new_game_pressed():
	if Gabagool.main_scene.has_node("Entities/Camera"):
		Gabagool.main_scene.get_node("Entities/Camera").target_node = "../Player"
		Gabagool.main_scene.get_node("Entities/Camera").load_exports()
		queue_free()


func _on_level_select_pressed():
	$HomeMenu.visible = false
	$LevelSelectMenu.visible = true


func _on_exit_level_select_pressed():
	$HomeMenu.visible = true
	$LevelSelectMenu.visible = false
	
	
var another_dict = [
	{
		"name": "Dive in",
		"path": "level1.tscn",
		"number": 1
	},
]


func _on_play_level_pressed():
	print($LevelSelectMenu/ItemList.get_selected_items())
	pass # Replace with function body.
