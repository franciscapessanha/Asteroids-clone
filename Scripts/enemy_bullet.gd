extends KinematicBody2D

"""
Variables inicialization
================================= 
"""
var velocity = Vector2()
var speed = 500
var collision_identified = false 
var window_size = [1024, 600]

"""
Collision Handling
================================= 
Handles with the movement
Arguments:
	collision = KinematicCollision that contains the collision data
"""
func collision_handling(collision):
	if collision:
		#velocity = velocity.bounce(collision.normal).clamped(600)
		
		# Collision with an asteroid
		if collision.collider.has_method("was_hit") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			get_tree().get_root().get_node("main").play_sound("explosion_asteroid")
			get_tree().get_root().get_node("main").play_explosion(collision.position)
			collision.collider.was_hit(receive_points(), collision.position, velocity) 
		
		# Collision with the player spaceship
		if collision.collider.has_method("player_died") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			collision.collider.player_died()
			get_tree().get_root().get_node("main").play_sound("explosion_spaceship")
			get_tree().get_root().get_node("main").play_explosion(collision.position)
			queue_free()
		
		# Collision with bullet (from the enemy or player) or flame
		if collision.collider.has_method("has_collided") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			collision.collider.has_collided()
			get_tree().get_root().get_node("main").play_sound("explosion_asteroid")
			get_tree().get_root().get_node("main").play_explosion(collision.position)
			queue_free()

"""
Check if the bullet is on screen
================================= 
If the bullet is not on screen it will be destroyed
"""
func on_screen():
	if global_position.x > window_size[0]+ 10:
		queue_free()
	elif global_position.y > window_size[1] + 10:
		queue_free()
	elif global_position.x < -10:
		queue_free()
	elif global_position.y < -10:
		queue_free()

"""
Shoot
================================= 
Arguments:
	enemy_rotation = rotation of the enemy on the moment of the shot
	enemy_position = position of the enemy on the moment of the shot
"""
func shoot(enemy_rotation,enemy_position):
	global_position = enemy_position
	rotation = enemy_rotation + rand_range(-PI/3,PI/3) 
	get_tree().get_root().get_node("main").play_sound("shot")
	velocity = -Vector2(0,speed).rotated(rotation)
	set_process(true)

"""
The bullet has collided
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
If the bullets hits something the player will not earn the points associted 
"""	
func receive_points():
	return false

"""
Process function
================================= 
"""
func _process(delta):
	var collision = move_and_collide(velocity * delta)
	collision_handling(collision)
	on_screen()
