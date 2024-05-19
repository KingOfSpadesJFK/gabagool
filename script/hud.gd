extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect any necessary signals
	Gabagool.player.player_collected_money.connect(_show_money)
	Gabagool.level_transition_complete.connect(_show_level_name)


func _show_level_name():
	$LevelName.text = str(Gabagool.main_scene_name)
	$LevelName/Number.text = 'Level ' + str(Gabagool.main_scene_number)
	if not $LevelName/AnimationPlayer.current_animation == "show_levelname" and $LevelName/Timer.is_stopped():
		$LevelName/AnimationPlayer.play("show_levelname")
	$LevelName/Timer.start()


func _hide_level_name():
	$LevelName/AnimationPlayer.play("hide_levelname")


func _show_money():
	$Money.text = '$' + str(Gabagool.player.player_info.money)
	if not $Money/AnimationPlayer.current_animation == "show_money" and $Money/Timer.is_stopped():
		$Money/AnimationPlayer.play("show_money")
	$Money/Timer.start()


func _hide_money():
	$Money/AnimationPlayer.play("hide_money")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
