extends RichTextLabel


# Path to level root
@export var level_root: NodePath


var player: Player
var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_level_reload()
	Gabagool.level_load.connect(_on_level_reload)


func _on_player_death():
	player.player_died.disconnect(_on_player_death)
	camera = null
	player = null
	

func _on_level_reload():
	player = Gabagool.main_scene.get_node("Entities/Player")
	player.player_died.connect(_on_player_death)
	camera = Gabagool.main_scene.get_node("Entities/Camera")
	
	
func _input(event):
	if event.is_action_pressed("debug_hud"):
		visible = not visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player:
		text = Player.PlayerState.keys()[player.player_state] + '\n'
		text += str(player.velocity) + '\n'
		text += str(floor(player.global_position / 16.0)) + '\n'
		if player.player_info:
			text += 'Checkpoint: ' + str(player.player_info.checkpoint_position) + '\n'
			text += '$' + str(player.player_info.money) + '\n'
	if camera:
		text += 'Camera position: ' + str(camera.position) +'\n'
