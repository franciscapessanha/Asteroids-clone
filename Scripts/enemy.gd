extends KinematicBody2D

"""
Variables inicialization
================================= 
"""
onready var bullets_node = get_node("enemy_bullets")
onready var shotter_timer = get_node("shotter_timer")
onready var collision_timer = get_node("collision_timer")
onready var thrust_flame = get_node("thrust_flame")
onready var bullet = preload("res://Scenes/enemy_bullet.tscn")
onready var ui =get_tree().get_root().get_node("main").get_node("UI")

var new_bullet
var collision_identified = false

"""
Ready function
================================= 
"""
func _ready():
	get_node("CollisionPolygon2D").disabled = true
	thrust_flame.get_node("CollisionPolygon2D").disabled = true
	collision_timer.start()
	shotter_timer.start()

"""
Enemy shoot
================================= 
The enemy has shot
A new bullet set is created
"""
func shoot():
	shotter_timer.start()
	new_bullet = bullet.instance()
	bullets_node.add_child(new_bullet)
	new_bullet.shoot(global_rotation, get_node("bullet_spot").global_position)

"""
The spaceship has collided
================================= 
The spaceship will be destroyed
"""
func has_collided():
	queue_free()

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
Enemy died
================================= 
"""			
func enemy_died(receive_points):
	if receive_points:
		ui.add_points(200)
	queue_free()

"""
Receive points
================================= 
The destruction caused by the enemy won't earn points to the player
"""		
func receive_points():
	return false

"""
Collision Handling
================================= 
Handles with the movement
Arguments:
	collision = KinematicCollision that contains the collision data
"""
func collision_handling(collision):
	if collision:
		# Collision with the player spaceship
		if collision.collider.has_method("player_died") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			collision.collider.player_died()
			get_parent().play_sound("explosion_spaceship")
			get_parent().play_explosion(collision.position)
			enemy_died(collision.collider.receive_points())


"""
Shooter Timer
================================= 
When over, shoots a new bullet
"""
func _on_Shotter_timer_timeout():
	shoot()
	pass # replace with function body

"""
"Ghost mode" desactivated
================================= 
The enemy's collision shape is activated
"""
func _on_Collision_timer_timeout():
	get_node("CollisionPolygon2D").disabled = false
	pass # replace with function body

