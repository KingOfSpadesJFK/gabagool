extends Node2D

@export var speed = 10.0

@onready var path_follow = $Path2D/PathFollow2D
@onready var staticbody = $Path2D/PathFollow2D/StaticBody2D


func _physics_process(delta):
	path_follow.progress += speed * delta
