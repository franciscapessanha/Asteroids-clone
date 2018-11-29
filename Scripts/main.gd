extends Node
"""
Scenes preload
================================= 
"""
onready var asteroids = preload("res://Scenes/asteroid.tscn")
onready var explosion = preload("res://Scenes/explosion.tscn")
onready var player = preload("res://Scenes/player.tscn")
onready var enemy = preload("res://Scenes/enemy_movement.tscn")

"""
Variables inicialization
================================= 
"""
onready var initial_spots = [get_node("p0").global_position, get_node("p1").global_position, 
get_node("p2").global_position, get_node("p3").global_position, get_node("p4").global_position, 
get_node("p5").global_position, get_node("p6").global_position, get_node("p7").global_position,
get_node("p8").global_position, get_node("p9").global_position]

onready var shotting_sound = get_node("shotting_sound")
onready var explosion_sound = get_node("explosion_sound")
onready var explosion_spaceship_sound = get_node("explosion_spaceship_sound")

onready var colors = ["brown","red","orange"]

onready var enemy_timer = get_node("enemy_timer")
onready var asteroids_timer = get_node("asteroids_timer")

var over = false
var points_threshold = 1000

"""
Ready function
================================= 
Initializes one spaceship and five asteroids
"""
func _ready():
	player_spawn()
	asteroids_spawn(5)	
	asteroids_timer.start()

"""
New Asteroids
================================= 
Creates two asteroids for each asteroid (big or medium) destroyed
Arguments:
	size = size of the new asteroids (medium or small)
	color = color of the new asteroids (equal to the color of the parent asteroid)
	asteroid_position = explosion position
	velocity = velocity of the parent asteroid when the collision occurred
	hit_velocity = velocity of the bullet/spaceship that collided with the parent asteroid
"""
func new_asteroids(size, color, asteroid_position, velocity, hit_velocity):
	for i in [-1,1]:
		var a = asteroids.instance()
		add_child(a)
		var new_position = asteroid_position + (hit_velocity.tangent().clamped(10) + Vector2(5,5))* i
		var new_velocity = (velocity + hit_velocity.tangent() *i).clamped(2)
		a.asteroid_initialization(size,color, new_position, new_velocity)
	
	var points = get_node("UI").get_points()
	if points > points_threshold: 
	
		if points_threshold == 1000: #initial threshold
			enemy_timer.start()
		points_threshold = points_threshold + 400
		if  asteroids_timer.get_wait_time() > 6:
			asteroids_timer.set_wait_time( asteroids_timer.get_wait_time() - 1)
		asteroids_timer.start()

"""
Spawn Asteroids
================================= 
Spawns asteroids on predefined positions
Arguments:
	number_asteroids = number of asteroids to spawn
"""
func asteroids_spawn(number_asteroids):
	var start = randi()%initial_spots.size() #random index on the positions list
	var index = start
	
	for i in range(number_asteroids):
		if index == initial_spots.size():
			index = 0
			
		var asteroid_position = initial_spots[index]
		var color = colors[randi() % colors.size()]
		var a = asteroids.instance()
		add_child(a)		
		a.asteroid_initialization("big", color, asteroid_position, Vector2(0,0))

"""
Spawn Player
================================= 
Spawn a player spaceship
"""
func player_spawn():
	var new_player = player.instance()
	add_child(new_player)	

"""
Play Sound
================================= 
Plays sound
Arguments:
	event = the event related to the sound
"""
func play_sound(event):
	if event == "shot":
		shotting_sound.play()		
	elif event == "explosion_asteroid":
		explosion_sound.play()	
	elif event == "explosion_spaceship":
		explosion_spaceship_sound.play()	

"""
Play Explosion
================================= 
Plays explosion animation
Arguments:
	position = position where the explosion occurred
"""
func play_explosion(position):
	var expl = explosion.instance()
	add_child(expl)
	expl.global_position = position
	expl.play()	

"""
Ressurection Timer
================================= 
When over, spawns a new player
"""
func _on_ressurection_timer_timeout():
	if !over:
		player_spawn()

"""
Enemy Timer
================================= 
When over, spawns a new enemy
"""
func _on_enemy_timer_timeout():
	var e = enemy.instance()
	add_child(e)
	if  enemy_timer.get_wait_time() > 6:
		enemy_timer.set_wait_time( asteroids_timer.get_wait_time() - 1)
	enemy_timer.start()

"""
Asteroids Timer
================================= 
When over, spawns a new asteroid
"""
func _on_asteroids_timer_timeout():
	asteroids_spawn(2)
	pass # replace with function body

"""
Game Over Signal
================================= 
"""	
func _on_UI_dead():
	over = true
	pass # replace with function body
