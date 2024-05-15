extends RichTextLabel


# Path to level root
@export var level_root: NodePath


var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(level_root).get_node("Entities/Player")
	player.player_died.connect(_on_player_death)


func _on_player_death():
	player = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player:
		text = Player.PlayerState.keys()[player.player_state] + '\n'
		text += str(player.velocity) + '\n'
		text += str(floor(player.global_position / 16.0)) + '\n'
		text += '$' + str(player.money) + '\n'
