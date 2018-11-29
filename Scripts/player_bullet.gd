extends KinematicBody2D

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
		# Collision with an asteroid
		if collision.collider.has_method("was_hit") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			get_tree().get_root().get_node("main").play_sound("explosion_asteroid")
			get_tree().get_root().get_node("main").play_explosion(collision.position)
			collision.collider.was_hit(receive_points(), collision.position, velocity) #hit velocity = velocity of the bullet
			has_collided()
		
		# Collision with the enemy spaceship
		if collision.collider.has_method("enemy_died") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			collision.collider.enemy_died(receive_points())
			get_tree().get_root().get_node("main").play_sound("explosion_spaceship")
			get_tree().get_root().get_node("main").play_explosion(collision.position)
			has_collided()
		
		# Collision with bullet (from the enemy or player) or flame
		if collision.collider.has_method("has_collided") && !collision.collider.get_collision_identified():
			collision_identified = true
			collision.collider.collision_identified()
			collision.collider.has_collided()
			get_tree().get_root().get_node("main").play_sound("explosion_asteroid")
			get_tree().get_root().get_node("main").play_explosion(collision.position)
			has_collided()

"""
The bullet has collided
================================= 
The bullet will be destroyed
"""
func has_collided():
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
Start shoot
================================= 
Arguments:
	player_rotation = rotation of the player on the moment of the shot
	player_position = position of the player on the moment of the shot
"""
func start_shoot(player_rotation,player_position):
	global_position = player_position
	rotation = player_rotation
	get_parent().get_parent().get_parent().play_sound("shot")
	velocity = -Vector2(0,speed).rotated(rotation)
	set_process(true)


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
If the bullets hits something the player will earn the points associted 
"""	
func receive_points():
	return true

"""
Process function
================================= 
"""
func _process(delta):
	var collision = move_and_collide(velocity * delta)
	collision_handling(collision)

