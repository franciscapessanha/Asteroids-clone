extends KinematicBody2D

"""
Variables inicialization
================================= 
"""
var max_speed = 1.5
var max_rot_speed = 3
var velocity = Vector2()
var rotation_speed = 0

var window_size = [1024, 600]
var textures = {'brown': "res://Images/asteroids_brown.png",
'red': "res://Images/asteroids_red.png", 
'orange': "res://Images/asteroids_orange.png" }

var my_scale
var color
var collision_identified

onready var ui =get_parent().get_node("UI")
onready var size = "big"

"""
Ready function
================================= 
Defines random rotation speed for the asteroid
"""
func _ready():
	rotation_speed = rand_range(-max_rot_speed, max_rot_speed)
	pass

"""
Asteroid initialization
================================= 
Initializes a new asteroid
Arguments:
	in_size = size of the asteroid (big, medium or small)
	in_color = color of the asteroid (red, brown, orange)
	in_position =  asteroid position
	in_velocity = asteroid velocity
"""
func asteroid_initialization(in_size,in_color,in_position, in_velocity):
	size = in_size
	color = in_color
	global_position = in_position
	
	if in_velocity != Vector2(0,0): #velocity = Vector2(0,0) if the asteroid was spawn and not created due to an asteroid explosion
		velocity = in_velocity
	else:
		velocity = Vector2(rand_range(max_speed/2, max_speed),0).rotated(rand_range(0, 2*PI))#rotation in radians
	
	# Create sprite with texture
	var texture = load(textures[in_color])
	if size == "big":
		my_scale = Vector2(0.25,0.25)
	elif size == "medium":
		my_scale = Vector2(0.15,0.15)
	elif size == "tiny":
		my_scale = Vector2(0.08,0.08)	
	get_node("Sprite").set_texture(texture)
	get_node("Sprite").set_scale(my_scale)
	
	# Create collision shape
	var circle = CircleShape2D.new()
	circle.set_radius(min((texture.get_width()*my_scale.x),(texture.get_height()*my_scale.y))/2)
	var collision_shape = CollisionShape2D.new()
	collision_shape.set_shape(circle)
	add_child(collision_shape)

"""
The asteroid was hit
================================= 
* Handles points
* Deletes the current asteroid
* Create new asteroids if the current asteroid is big or medium

Arguments:
	receive_points = bool that indicates if the collision is worth points (it was between the asteroid 
	and the player, player bullet or thrust flame
	collision_position = explosion position
	hit_velocity = velocity of the bullet/spaceship that collided with the parent asteroid
"""
func was_hit(receive_points, collision_position, hit_velocity):
	if size == "big":
		if receive_points:
			ui.add_points(20)
		get_parent().new_asteroids("medium",color, collision_position, velocity, hit_velocity)
		queue_free()
	
	elif size == "medium":
		if receive_points:
			ui.add_points(50)
		get_parent().new_asteroids("tiny",color, collision_position,velocity, hit_velocity)
		queue_free()

	elif size == "tiny":
		if receive_points:
			ui.add_points(100)
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
Collision Handling
================================= 
Handles with the movement
Arguments:
	collision = KinematicCollision that contains the collision data
"""
func collision_handling(collision):
	if collision:
		velocity = velocity.bounce(collision.normal).clamped(max_speed)
		
		# Collision with the player
		if collision.collider.has_method("player_died") && !collision.collider.get_collision_identified():
			
			collision_identified = true
			collision.collider.collision_identified()
			
			collision.collider.player_died()
			get_parent().play_sound("explosion_spaceship")
			get_parent().play_explosion(collision.position)
			was_hit(true, collision.position, velocity)
			
		if collision.collider.has_method("enemy_died") && !collision.collider.get_collision_identified():
			
			collision_identified = true
			collision.collider.collision_identified()
			collision.collider.enemy_died(false)
			get_parent().play_sound("explosion_spaceship")
			get_parent().play_explosion(collision.position)
			
			was_hit(true, collision.position, velocity)
		
		# Collision with bullet (from the enemy or player) or flame
		elif collision.collider.has_method("has_collided") && !collision.collider.get_collision_identified():

			collision.collider.collision_identified()
			collision_identified = true
			collision.collider.has_collided()
			get_parent().play_sound("explosion_asteroid")
			get_parent().play_explosion(collision.position)
			
			was_hit(collision.collider.receive_points(), collision.position, velocity) #hit velocity = velocity of the bullet
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
Process function
================================= 
"""	
func _process(delta):
	rotation = rotation + rotation_speed * delta
	var collision = move_and_collide(velocity)
	collision_handling(collision)
	position_handling()