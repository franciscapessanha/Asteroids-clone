extends CanvasLayer

"""
Variables inicialization
================================= 
"""
onready var points = 0
onready var lifes = 3
onready var transparent_background = get_node("transparent_background")
onready var pause = get_node("pause")
onready var game_over = get_node("game_over")
onready var game_over_timer = get_node("game_over_timer")

onready var paused = false
onready var over = false
signal dead

"""
Get input
================================= 
* "pause" = pause / unpause the game
* "exit" = quit the game
"""
func get_input():
	if Input.is_action_just_pressed("pause"):
		if !paused:
			get_tree().paused = true
			transparent_background.show()
			pause.show()
			paused = true
		else:
			get_tree().paused = false
			transparent_background.hide()
			pause.hide()
			paused = false

	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene("res://Scenes/main_menu.tscn")

"""
Get points
================================= 
Return:
	number of points
"""
func get_points():
	return points

"""
Add points
================================= 
Updates the score
Arguments:
	new_points = points to add
"""
func add_points(new_points):
	points += new_points

"""
Takes life
================================= 
Takes one life and hides the respective marker
"""
func take_life():
	lifes -= 1
	if lifes == 2:
		get_node("first_life").hide()
	elif lifes == 1:
		get_node("second_life").hide()
	elif lifes == 0:
		get_node("last_life").hide()
	
	elif lifes == -1:
		over = true
		game_over_timer.start()
		transparent_background.show()
		game_over.show()
		emit_signal("dead")

"""
Game over timer
================================= 
When over, returns to the main menu
"""
func _on_Game_over_timer_timeout():
	get_tree().change_scene("res://Scenes/main_menu.tscn")

"""
Process function
================================= 
"""
func _process(delta):
	get_node("points").text = str(points)
	if !over:
		get_input()
