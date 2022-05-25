extends Area2D

export var level = '0'

func _on_Area2D_body_entered(body):
	owner.level = 'Level-'+level
	owner.get_node("AnimationPlayer").play('enter')
