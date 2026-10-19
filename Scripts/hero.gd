extends CharacterBody2D

signal hero_coin_collected(sender)
signal attack

const SPEED: int = 64
const SPEED_JUMP: float = 128
const SPEED_JUMP_ACCEL_AIR: float = 80
const SPEED_JUMP_ACCEL: float = 250
const SPEED_JUMP_DEACCEL: float = 500
const SPEED_JUMP_DEACCEL_AIR: float = 200
const SPEED_JUMP_GRAV: float = 250
const SPEED_JUMP_FORCE: float = 200
var looking_direction: int = 0 # 0: down, 1: right, 2: up, 3: left
@onready var anim_sprite = $Sprite2D

var is_paused: bool = false
var only_lr: bool = false
var can_jump: bool = false
var can_interact = false
var interaction_callback = null
var has_sword = false

func _init():
	pass
	
var attack_cooldown = 0.0
func _process(delta):
	if is_paused:
		return
	
	
	if can_jump:
		
		var velocity_pre_h = 0
		if Input.is_action_pressed("Left"):
			velocity_pre_h -= 1.0
		if Input.is_action_pressed("Right"):
			velocity_pre_h += 1.0
		
		if is_on_floor():
			if Input.is_action_pressed("Accept"):
				velocity.y -= SPEED_JUMP_FORCE
			
		velocity.y += SPEED_JUMP_GRAV*delta
		
		if abs(velocity_pre_h) > 1e-8:
			if is_on_floor():
				velocity.x += SPEED_JUMP_ACCEL*velocity_pre_h*delta
			else:
				velocity.x += SPEED_JUMP_ACCEL_AIR*velocity_pre_h*delta
		else:
			var vel_pre = velocity.x
			if is_on_floor(): 
				velocity.x -= SPEED_JUMP_DEACCEL*sign(velocity.x)*delta
			else:
				velocity.x -= SPEED_JUMP_DEACCEL_AIR*sign(velocity.x)*delta
			if vel_pre*velocity.x <= 0:
				velocity.x = 0
		
		velocity.x = clamp(velocity.x, -SPEED_JUMP, SPEED_JUMP)
		
		if velocity.x > 0:
			looking_direction = 1
		elif velocity.x < 0:
			looking_direction = 3
		
		
		var _collisions = move_and_slide()
		handle_animation()
	else:
		if attack_cooldown > 0:
			attack_cooldown -= delta
		if attack_cooldown > 0:
			return
			
		
		velocity = Vector2.ZERO
			
		if Input.is_action_pressed("Left"):
			velocity.x -= 1.0
		if Input.is_action_pressed("Right"):
			velocity.x += 1.0
			
		if velocity.x == 0:
			if not only_lr:
				if Input.is_action_pressed("Up"):
					velocity.y -= 1.0
				if Input.is_action_pressed("Down"):
					velocity.y += 1.0
		
		
		if velocity.y > 0:
			looking_direction = 0
		elif velocity.x > 0:
			looking_direction = 1
		elif velocity.y < 0:
			looking_direction = 2
		elif velocity.x < 0:
			looking_direction = 3
	
		velocity *= SPEED
		
		var _collisions = move_and_slide()
		handle_animation()
		
		if has_sword:
			if Input.is_action_just_pressed("Accept"):
				if interaction_callback == null:
					do_attack()
	
func hide_sword():
	$SwordRot/Sword.visible = false
	$SwordRot/hitbox.monitorable = false
	
func do_attack():
	attack_cooldown = 0.5
	anim_sprite.stop()
	$SwordRot/Sword.visible = true
	$SwordRot/hitbox.monitorable = true
	if looking_direction == 0:
		$SwordRot.rotation_degrees = 90.0
	elif looking_direction == 1:
		$SwordRot.rotation_degrees = 0.0
	elif looking_direction == 2:
		$SwordRot.rotation_degrees = 270.0
	elif looking_direction == 3:
		$SwordRot.rotation_degrees = 180.0
	var tween = get_tree().create_tween()
	tween.tween_property($SwordRot, "rotation_degrees", $SwordRot.rotation_degrees+180.0, 0.4)
	tween.tween_callback(hide_sword)
	attack.emit()
	
func switch_anim(anim_name):
	if not (anim_name == anim_sprite.animation):
		anim_sprite.play(anim_name)

func handle_animation():
	if velocity.length() < 1e-8:
		if looking_direction == 0:
			switch_anim("idle_down")
		elif looking_direction == 1:
			switch_anim("idle_right")
		elif looking_direction == 2:
			switch_anim("idle_up")
		elif looking_direction == 3:
			switch_anim("idle_left")
	else:
		if looking_direction == 0:
			switch_anim("walk_down")
		elif looking_direction == 1:
			switch_anim("walk_right")
		elif looking_direction == 2:
			switch_anim("walk_up")
		elif looking_direction == 3:
			switch_anim("walk_left")
	
func on_game_paused():
	is_paused = true
	anim_sprite.pause()
	
func on_game_continued():
	is_paused = false
	anim_sprite.play()

func enable_interact(_interaction_callback):
	can_interact = true
	$Interact.visible = true
	interaction_callback = _interaction_callback
	
func disable_interact():
	can_interact = false
	$Interact.visible = false
	interaction_callback = null

func get_interaction_callback():
	return interaction_callback

func on_coin_collected(sender):
	hero_coin_collected.emit(sender)

func set_front():
	switch_anim("idle_down")
	
func set_right():
	switch_anim("idle_right")
	
