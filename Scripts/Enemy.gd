extends KinematicBody2D

export var gravity = true
export var move = true
export var ACC = 250
var vel = Vector2.ZERO
var dir = Vector2.RIGHT

func _ready():
	if gravity:
		dir.y = 10

func _process(delta):
	if move:
		vel = dir*ACC*delta
	vel=move_and_slide(vel)
