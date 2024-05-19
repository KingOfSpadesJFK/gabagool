extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_new_game_pressed():
	if Gabagool.main_scene.has_node("Entities/Camera"):
		Gabagool.main_scene.get_node("Entities/Camera").target_node = "../Player"
		Gabagool.main_scene.get_node("Entities/Camera").load_exports()
		queue_free()


func _on_level_select_pressed():
	$HomeMenu.visible = false
	$LevelSelectMenu.visible = true
	for item in level_array:
		$LevelSelectMenu/ItemList.add_item(item["name"])
		print(item["name"])


func _on_exit_level_select_pressed():
	$HomeMenu.visible = true
	$LevelSelectMenu.visible = false
	
	
const level_path = "res://scene/level/"
const level_array = [
	{
		"name": "Dive In",
		"path": "level1.tscn",
		"number": 1
	},
	{
		"name": "Leaps of Faith",
		"path": "level2.tscn",
		"number": 2
	},
	{
		"name": "On the Move",
		"path": "level3.tscn",
		"number": 3
	},
]


func _on_play_level_pressed():
	if $LevelSelectMenu/ItemList.is_selected(0):
		_on_new_game_pressed()
	else:
		for item in $LevelSelectMenu/ItemList.get_selected_items():
			Gabagool.goto_scene(level_path + level_array[item]["path"])
			get_node("/root/Control/UnderwaterAmbience").play()
			get_node("/root/Control/OceanWaves").stop()
	queue_free()
