extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect any necessary signals
	Gabagool.player.player_collected_money.connect(_show_money)


func _show_money():
	$Money.text = '$' + str(Gabagool.player.player_info.money)
	if not $Money/AnimationPlayer.current_animation == "show_money" and $Money/Timer.is_stopped():
		$Money/AnimationPlayer.play("show_money")
	$Money/Timer.start()


func _hide_money():
	$Money/AnimationPlayer.play("hide_money")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
