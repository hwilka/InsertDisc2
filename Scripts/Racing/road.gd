extends Node2D

signal request_disc_change(disc, abort_position)
signal request_race_scene_change(scene_id, pos)


const ROAD_HEIGHT := 152
const SCREEN_HEIGHT := 200
const SKY_HEIGHT := SCREEN_HEIGHT - ROAD_HEIGHT

var road_curvature := 0.0
@onready var road_segments: Array = [$R0, $R1, $R2, $R3, $R4, $R5, $R6, $R7, $R8, $R9, $RE]
@onready var cars: Node2D = $Cars
@onready var hero_car: Area2D = $Cars/HeroCar
@onready var hero_car_sprite: Sprite2D = $Cars/HeroCar/Sprite2D
@onready var speed_rot: Node2D = $Speedometer/SpeedometerRot
@onready var progress_bar_line: Node2D = $ProgressBar/ProgressBarH/ProgressBarLine
@onready var label_score: Label = $LabelScore

const STREET_LENGTH = 3600.0
const CAR_ROAD_SPEED = 60.0
const CAR_GRASS_SPEED = 20.0
const ENEMY_ROAD_SPEED = 30.0
const CAR_COLL_SPEED = 30.0
const CAR_ACC = 30.0
const CAR_DEACC = 90.0
const CAR_MIN_POS = - 100.0
const CAR_MAX_POS = -CAR_MIN_POS
const CAR_H_SPEED = 75.0
const PROGRESS_HEIGHT = 43.0

const HORIZON_DISTANCE = 100.0
const PIXEL_HORIZON_POS = 0.0
const WORLD_MAX_ENEMY_POS = -30.0 # screen bottom
const PIXEL_MAX_ENEMY_POS = 160.0 # Screen bottom
const ENEMY_CAR_HORIZONTAL_SCALE = 50.0

var speed: float = 0.0
var time_passed := 0.0
var street_pos := 0.0

var cars_street_pos: Array = []
var cars_hpos: Array = []
var cars_col: Array = []
var cars_inst: Array = []
const road_points: Array = [ 0.0, 100.0, 160.0, 250.0, 360.0, 450.0, 570.0, 700.0, 850.0, 910.0, 990.0, 1200.0, 1300.0, 1400.0, 1600.0, 1900.0, 2050.0, 2300.0, 2360.0, 2600.0, 2900.0, 3100.0, 3150.0, 3300.0, 3400.0,    3600.0 ]
const road_curve: Array = [ 0.0,    0.0,  -1.0,  -1.0,   0.0,   0.0,  -0.7,  -0.7,   1.0,   1.0,  -0.3,   -0.3,   -1.1,   -1.1,    0.8,   -0.2,   -1.0,   -0.5,    0.0,    0.0,    0.7,   -0.5,   -0.1,    0.5,    0.0,       0.0 ]

var car_score: int = 20

var is_paused = false
var initialized = false


func _init():
	pass
	cars_street_pos = [200.0, 290.0, 370.0, 430.0, 520.0, 580.0, 620.0, 700.0, 770.0, 800.0, 830.0, 900.0, 940.0, 1035.0, 1075.0, 1090.0, 1120.0, 1130.0, 1200.0]
	cars_hpos = [0.0, -1.0, 0.75, 0.6, -0.3, -0.4, 0.1, -0.9, 0.7, 0.4, -0.2, 0.25, 0.7, -0.9, -0.6, -0.3, -0.0, 1.0, -0.2]
	cars_col = [0, 1, 0, 1, 2, 2, 1, 2, 0, 2, 0, 1, 1, 0, 2, 1, 0, 2, 1]
	
	
	
	for _c in cars_col:
		cars_inst.push_back(null)

func on_game_paused():
	is_paused = true
	
func on_game_continued():
	is_paused = false
	
var inventory
func set_inventory(_inventory):
	inventory = _inventory
	
func get_inventory():
	return inventory


func set_road_curve(_road_curvature: float):
	road_curvature = _road_curvature
	for r in road_segments:
		var h : float = SCREEN_HEIGHT - r.position.y
		r.get_child(0).position.x = h * road_curvature / float(ROAD_HEIGHT)

func set_road_mod():
	var do_flip = int(street_pos / 10.0) % 2 == 1
	for r in road_segments:
		r.get_child(0).flip_h = do_flip



var in_anim = false
var race_ended = false
func show_3():
	$LabelMsg.text = "3"
	
func show_2():
	$LabelMsg.text = "2"
	
func show_1():
	$LabelMsg.text = "1"
	
func show_Go():
	$LabelMsg.text = "GO"
	in_anim = false
	
func hide_Go():
	$LabelMsg.text = ""
	
func init_tween():
	in_anim = true
	var t = get_tree()
	var tween = t.create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(show_3)
	tween.tween_interval(1.0)
	tween.tween_callback(show_2)
	tween.tween_interval(1.0)
	tween.tween_callback(show_1)
	tween.tween_interval(1.0)
	tween.tween_callback(show_Go)
	tween.tween_interval(1.0)
	tween.tween_callback(hide_Go)
	

func show_lost():
	$LabelMsg.text = "You lost"
	
func show_won():
	$LabelMsg.text = "You won\na trophy!"
	
func back_to_title():
	request_race_scene_change.emit('title', 'right')

func end_tween():
	if inventory.won_race:
		show_won()
	else:
		show_lost()
	var tween = get_tree().create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(back_to_title)

func _process(delta):
	if (is_paused):
		return 
	if not initialized:
		initialized = true
		init_tween()
		
	if (in_anim):
		return 
		
	time_passed += delta
	
	
	var hmov := 0.0
	if Input.is_action_pressed('Left'):
		hmov -= 1.0
	if Input.is_action_pressed('Right'):
		hmov += 1.0
		
	if hmov < 0.0:
		hero_car_sprite.frame = 1
	elif hmov > 0.0:
		hero_car_sprite.frame = 2
	else:
		hero_car_sprite.frame = 0
		
	hero_car.position.x = clamp(hero_car.position.x + hmov*CAR_H_SPEED*delta, CAR_MIN_POS, CAR_MAX_POS)
	
	var target_speed: float = CAR_ROAD_SPEED
	if not is_on_road():
		target_speed = CAR_GRASS_SPEED
	if is_colliding_with_car():
		target_speed = CAR_COLL_SPEED
		
	if speed < target_speed:
		speed += delta * CAR_ACC
		if speed > target_speed:
			speed = target_speed
	elif speed > target_speed:
		speed -= delta * CAR_DEACC
		if speed < target_speed:
			speed = target_speed
			
	speed_rot.rotation_degrees = 170.0 * speed / 60.0
	
	street_pos += delta*speed
	progress_bar_line.position.y = round(-(clamp(street_pos/ STREET_LENGTH, 0.0, 1.0)) * PROGRESS_HEIGHT)+0.5
	
	var interpolated_curve = interpolate_curvature()
	set_road_curve(interpolated_curve*100.0)
	
	manage_enemy_cars(delta)
	set_road_mod()
	
	label_score.text = str(car_score) + "/" + str(len(cars_street_pos)+1)
	
	if street_pos >= STREET_LENGTH:
		if not race_ended:
			race_ended = true
			if car_score == 1:
				inventory.trophy = true
				inventory.won_race = true
			end_tween()
	
func manage_enemy_cars(delta):
	car_score = len(cars_street_pos)+1
	for i in range(len(cars_street_pos)):
		cars_street_pos[i] += delta*ENEMY_ROAD_SPEED
		
		var spos : float = cars_street_pos[i]
		
		var rel_pos := spos - street_pos
		if rel_pos < 0:
			car_score -= 1
			
		if rel_pos < WORLD_MAX_ENEMY_POS:
			var inst = cars_inst[i]
			if not (inst == null):
				cars.remove_child(inst)
				inst.queue_free()
				cars_inst[i] = null
		elif rel_pos <= HORIZON_DISTANCE - 1.0:
			var inst: StaticBody2D = cars_inst[i]
			if (inst == null):
				inst = preload("res://Scenes/Racing/EnemyCar.tscn").instantiate()
				if cars_col[i] == 1:
					inst.get_node('Sprite2D').texture = preload("res://img/car_green.png")
				elif cars_col[i] == 2:
					inst.get_node('Sprite2D').texture = preload("res://img/car_red.png")
				else:
					inst.get_node('Sprite2D').texture = preload("res://img/car_blue.png")
				cars_inst[i] = inst
				cars.add_child(inst)
			var dist_frac = (HORIZON_DISTANCE - rel_pos) / (HORIZON_DISTANCE)
			var dist_frac_better = dist_frac*dist_frac*dist_frac*dist_frac
			inst.scale = Vector2.ONE * (dist_frac_better * 2.0)
			inst.position.y = dist_frac_better*(hero_car.position.y-PIXEL_HORIZON_POS)
			
			inst.position.x = dist_frac_better*ENEMY_CAR_HORIZONTAL_SCALE*cars_hpos[i]
			
			var h : float = ROAD_HEIGHT-inst.position.y 
			inst.position.x += h * road_curvature / float(ROAD_HEIGHT)
			

func interpolate_curvature():
	if road_points[0] >= street_pos:
		return road_curve[0]
	if road_points[len(road_points)-1] <= street_pos:
		return road_curve[len(road_points)-1]
		
	for i in range(1, len(road_points)):
		if street_pos >= road_points[i-1] and street_pos < road_points[i]:
			var rpa: float = road_points[i-1]
			var rpb: float = road_points[i]
			var rca: float = road_curve[i-1]
			var rcb : float= road_curve[i]
			
			var p: = (street_pos - rpa) / (rpb - rpa)
			return p * rcb + (1.0 - p) * rca
	return 0.0
	
func is_on_road():
	var colls := hero_car.get_overlapping_bodies()
	for c in colls:
		if c.get_collision_layer_value(6):
			return true
	return false
	
func is_colliding_with_car():
	var colls := hero_car.get_overlapping_bodies()
	for c in colls:
		if c.get_collision_layer_value(7):
			return true
	return false
