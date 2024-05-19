extends Node


var fade = false
var fade_timer = 0.0
var currently_playing: AudioStreamPlayer2D = null
var previously_playing: AudioStreamPlayer2D = null


# Called when the node enters the scene tree for the first time.
func _ready():
	Gabagool.play_music.connect(play_music)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not $FadeTimer.is_stopped() and previously_playing:
		previously_playing.volume_db = $FadeTimer.wait_time - $FadeTimer.time_left * -200.0


func play_music(path):
	if get_node(path) is AudioStreamPlayer2D:
		previously_playing = currently_playing
		currently_playing = get_node(path)
		$FadeTimer.start()
	pass


func _on_fade_timer_timeout():
	if previously_playing:
		previously_playing.stop()
	currently_playing.play()
