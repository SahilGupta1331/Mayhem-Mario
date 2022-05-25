extends Node

var lifes = 6
var checkpoint = null
var timer = false
var time = 000

func _process(delta):
	if timer:
		time += 1*delta
