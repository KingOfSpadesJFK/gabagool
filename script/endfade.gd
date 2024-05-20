extends ColorRect


func _ready():
	Gabagool.ending.connect(end_fade)
	
	
func end_fade():	
	$AnimationPlayer.play("fadeout")
	Gabagool.camera.target_node = ""
	Gabagool.player.allow_input = false
	$AnimationPlayer/EndingTimer.start()
	pass


func _on_ending_timer_timeout():
	# fuck it, im so done with this project
	get_tree().quit()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


