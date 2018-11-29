extends Path2D

onready var follow = get_node("follow")

"""
Process function
================================= 
Follow will follow path
"""
func _process(delta):
	follow.set_offset(follow.get_offset() + 200*delta)

