extends Node

@export var base_volume = -10.0


var fade = false
var fade_timer = 0.0
var currently_playing: AudioStreamPlayer = null
var previously_playing: AudioStreamPlayer = null


# Called when the node enters the scene tree for the first time.
func _ready():
	Gabagool.play_music.connect(play_music)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not $FadeTimer.is_stopped() and previously_playing:
		var time = 1.0 - $FadeTimer.time_left / $FadeTimer.wait_time
		previously_playing.volume_db = base_volume - 5.0 - time * 80.0


func play_music(path):
	if get_node(path) != currently_playing:
		previously_playing = currently_playing
		currently_playing = get_node(path)
		currently_playing.play()
		currently_playing.volume_db = base_volume
		$FadeTimer.start()
	pass


func _on_fade_timer_timeout():
	if previously_playing:
		previously_playing.stop()
