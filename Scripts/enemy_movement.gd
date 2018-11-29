extends Node

onready var paths = [get_node("path_0"), get_node("path_1"), get_node("path_2"),
get_node("path_3"), get_node("path_4"), get_node("path_5")]
onready var enemy = preload("res://Scenes/enemy.tscn")
var path
var new_enemy
var follow

"""
Ready function
================================= 
The enemy will follow a predefined path
"""
func _ready():
	path = paths[randi() % paths.size()]
	new_enemy = enemy.instance()
	follow = PathFollow2D.new()
	#follow.set_rotate(false)
	path.add_child(follow)
	follow.add_child(new_enemy)
	pass

"""
Process function
================================= 
"""
func _process(delta):
	if follow.get_unit_offset() > 1:
		queue_free()
	else:
		follow.set_offset(follow.get_offset() + 200*delta)
		
