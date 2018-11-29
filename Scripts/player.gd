extends KinematicBody2D

"""
Scenes preload
================================= 
"""
var bullet = preload("res://Scenes/player_bullet.tscn")

"""
Variables inicialization
================================= 
"""
var rotation_speed = 4
var speed = 4
var velocity = Vector2()
var rot_direction = 0
var friction_vel = 0.02
var collision_identified = false
onready var window_size = [1024, 600]

onready var thrust_flame = get_node("thrust").get_node("thrust_flame")
onready var player_sprite = get_node("player").get_node("player_sprite")
onready var bullets_node = get_node("bullets")
onready var shotter_timer = get_node("shotter_timer")
onready var collision_timer = get_node("collision_timer")

"""
Ready function
================================= 
The player starts in "ghost mode" and can't be killed until the collision_timer ends

"""
func _ready():
	thrust_flame.hide()
	collision_timer.start()
	player_sprite.play("transparent")
	
	global_position.x = window_size[0] * 0.5
	global_position.y = window_size[1] * 0.5 
	rotation = 0	
	velocity = Vector2(0,0)

"""
Get input
================================= 
* "rotate_right" = rotates the player to the right
* "rotate_left" = rotates the player to the left
* "go_up" = moves the player to the front
* "shot" = shoots a bullet
"""
func get_input():
	rot_direction = 0
	if Input.is_action_pressed("rotate_right"):
		rot_direction += 1
	elif Input.is_action_pressed("rotate_left"):
		rot_direction -= 1
	elif Input.is_action_pressed("go_up"):
		velocity = Vector2(0, -speed).rotated(rotation)
		thrust_flame.show()
		thrust_flame.get_node("CollisionPolygon2D").disabled = false
			
	else:
		thrust_flame.hide()
		thrust_flame.get_node("CollisionPolygon2D").disabled = true
	
	if Input.is_action_pressed("shot"):
		if shotter_timer.get_time_left() == 0:
			player_shoot()

"""
Player shoot
================================= 
The player has shot
A new bullet with its rotation and the "bullet_spot" position is created
"""
func player_shoot():
	shotter_timer.start()
	var new_bullet = bullet.instance()
	bullets_node.add_child(new_bullet)
	new_bullet.start_shoot(rotation, get_node("bullet_spot").global_position)

"""
Player died
================================= 
"""
func player_died():
	get_parent().get_node("UI").take_life()
	get_parent().get_node("ressurection_timer").start()
	queue_free()

"""
"Ghost mode" desactivated
================================= 
The player's collision shape is activated
"""
func _on_collision_timer_timeout():
	get_node("CollisionPolygon2D").disabled = false
	player_sprite.play("default")
	pass # replace with function body

"""
A collision was identify
================================= 
To guarantee that the collision will only be detected once, on one of the bodies
"""

func collision_identified():
		collision_identified = true

func get_collision_identified():
	return collision_identified

"""
Receive points
================================= 
If the player dies against an asteroid it will earn the points of its destruction
"""	
func receive_points():
	return true

"""
Position Handling
================================= 
If the asteroid cross the border it will appear on the opposite side of the screen
"""
func position_handling():
	if global_position.x > window_size[0]:
		global_position.x = 0
	elif global_position.y > window_size[1]:
		global_position.y = 0
	elif global_position.x < 0:
		global_position.x = window_size[0]
	elif global_position.y < 0:
		global_position.y = window_size[1]	

"""
Collision Handling
================================= 
Handles with the movement
Arguments:
	collision = KinematicCollision that contains the collision data
"""
func collision_handling(collision):
	if collision:
		# Collision with an asteroid
		if collision.collider.has_method("was_hit") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			get_parent().play_sound("explosion_spaceship")
			get_parent().play_explosion(collision.position)
			collision.collider.was_hit(receive_points(),collision.position, velocity)
			player_died()
		
		# Collision with the enemy spaceship
		if collision.collider.has_method("enemy_died") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			collision.collider.enemy_died(receive_points())
			get_parent().play_sound("explosion_spaceship")
			get_parent().play_explosion(collision.position)
			player_died()

"""
Process function
================================= 
"""
func _process(delta):
	get_input()
	rotation += rot_direction * rotation_speed * delta
	var collision = move_and_collide(velocity)
	collision_handling(collision)
	velocity -= velocity * friction_vel
	position_handling()
	
	thrust_flame.move_thust(rotation, velocity,global_position)
	player_sprite.move_sprite(rotation,global_position)