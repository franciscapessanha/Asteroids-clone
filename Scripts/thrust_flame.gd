extends KinematicBody2D

"""
Variables inicialization
================================= 
"""
var velocity = Vector2()
var collision_identified = false 

"""
Move thrust
================================= 
Arguments:
	spaceship_rotation = rotation of the player spaceship
	spaceship_velocity = velocity of the player spaceship
	spaceship_position = position of the player spaceship
"""
func move_thust(spaceship_rotation, spaceship_velocity, spaceship_position):
	global_position = spaceship_position
	rotation = spaceship_rotation
	velocity = spaceship_velocity
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.has_method("was_hit") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			get_parent().get_parent().get_parent().play_sound("explosion_asteroid")
			get_parent().get_parent().get_parent().play_explosion(collision.position)
			collision.collider.was_hit(receive_points(), collision.position, velocity) #hit velocity = velocity of the bullet
	
		if collision.collider.has_method("enemy_died") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			collision.collider.enemy_died(receive_points())
			get_parent().get_parent().get_parent().play_sound("explosion_spaceship")
			get_parent().get_parent().get_parent().play_explosion(collision.position)
			collision.collider.was_hit(receive_points(), collision.position, velocity) #hit velocity = velocity of the bullet
"""
The thrust flame has collided
================================= 
"""
func has_collided():
	pass

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
If the thrust flame collides with something the player will earn the points of its destruction
"""	
func receive_points():
	#if get_parent().get_parent().get_type() == "enemy":
		return true
	#if get_parent().get_parent().get_type() == "player": 
	#	return false