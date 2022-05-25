extends KinematicBody2D

export var ACC = 50
export var MAXSPEED = 5000
export var FRIC = 75
export var MAXJUMP = 80
var vel = Vector2.ZERO
var jumping = false
var in_water = false
var climbing = false
var dir = Vector2.DOWN
var type = 'player'
var coins = 000
var has_key = false

func move(delta):
	$CanvasLayer/Coin/RichTextLabel.bbcode_text = 'x'+str(coins)
	$CanvasLayer/Live/RichTextLabel.bbcode_text = 'x'+str(main.lifes)
	$CanvasLayer/RichTextLabel.bbcode_text = str(int(main.time))
	$CanvasLayer/Key.visible = has_key
	if jumping:
		if vel.y <= -MAXJUMP or is_on_ceiling():
			vel.y = -MAXJUMP
			jumping = false
		dir.y = -1
	if dir.x != 0:
		vel.x += dir.x*ACC*delta
		vel.x = vel.clamped(MAXSPEED*delta).x
	else:
		vel.x = vel.move_toward(Vector2.ZERO, FRIC*delta).x
	if climbing:
		if dir.y!=0:
			vel.y += dir.y*ACC*delta
			vel.y = vel.clamped(MAXSPEED*delta).y
		else:
			vel.y = vel.move_toward(Vector2.ZERO, FRIC*delta).y
	else:
		vel.y += dir.y*(ACC*2)*delta
	vel = move_and_slide(vel, Vector2.UP, false, 4, 0.785398, false)
	for i in get_slide_count():
		var col = get_slide_collision(i)
		if col.collider.get('type') == 'pow' and dir.x > 0:
			col.collider.call('move_and_collide',Vector2(-col.normal.x*5,0))
			dir = col.normal.round()

func sprite():
	$AnimatedSprite.playing = true
	if climbing:
		$AnimatedSprite.animation = 'climb'
		$AnimatedSprite.speed_scale = 1
		if dir == Vector2.ZERO:
			$AnimatedSprite.playing = false
			$AnimatedSprite.frame = 0
	else:
		$AnimatedSprite.speed_scale = abs(vel.x/25)
		if abs(vel.x) < 10:
			$AnimatedSprite.playing = false
			$AnimatedSprite.frame = 0
		if in_water:
			if vel.y < 0:
				$AnimatedSprite.animation = 'swim'
			else:
				$AnimatedSprite.animation = 'glide'
		elif $RayCast2D.is_colliding() or vel.y==0:
			$AnimatedSprite.animation = 'run'
		else:
			$AnimatedSprite.animation = 'jump'
		if in_water or vel.y == 0 or $RayCast2D.is_colliding():
			if dir.x<0:
					$AnimatedSprite.flip_h = true
					if vel.x > 0 and !in_water:
						$AnimatedSprite.animation = "skid"
			elif dir.x>0:
					$AnimatedSprite.flip_h = false
					if vel.x < 0 and !in_water:
						$AnimatedSprite.animation = "skid"

func die():
	main.lifes-=1
	if main.lifes == -1:
		get_tree().change_scene("res://Scenes/Game Over.tscn")
	$AnimationPlayer.play("die")

func checkpoint():
	get_tree().reload_current_scene()

func _ready():
	if main.checkpoint != null:
		global_position = main.checkpoint
		if global_position == Vector2(-120,-136):
			var tiles:TileMap = owner.get_node("TempTiles")
			for i in range(-16,-7):
				tiles.set_cell(i,-9,-1)

func _physics_process(delta):
	$RayCast2D.force_raycast_update()
	dir = Vector2.DOWN
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if climbing:
		dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or in_water or $RayCast2D.is_colliding():
			jumping = true
	if Input.is_action_just_released("ui_accept"):
		if jumping:
			if vel.y >=-80:
				vel.y = -80
			jumping = false
	move(delta)
	sprite()
