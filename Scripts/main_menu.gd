extends MarginContainer

"""
Variables inicialization
================================= 
"""
var options = ["Play", "How", "Exit"]
var option = 0

"""
Get input
================================= 
* Arrow keys (up and down): Changes the current option 
* Space key: select
"""
func get_input():
	if Input.is_action_just_pressed("ui_up"):
		if option == 0:
			option = 2
		else:
			option -= 1
	if Input.is_action_just_pressed("ui_down"):
		if option == 2:
			option = 0
		else:
			option +=1
	
	if Input.is_action_just_pressed("select"):
		#get_node("Fade_in").show()
		#get_node("Fade_in").fade_in()
		if option == 0:
			get_tree().change_scene("res://Scenes/main.tscn")
		elif option == 1:
			get_tree().change_scene("res://Scenes/how_to_play.tscn")
		elif option == 2:
			get_tree().quit()

"""
Process function
================================= 
* Gets input
* Changes the color of the current option text
"""
func _process(delta):
	get_input()
	if options[option] == "Play":
		get_node("Options").get_node("Play").add_color_override("font_color", Color8(255,255,255,255))
		get_node("Options").get_node("How").add_color_override("font_color", Color8(216,162,221,100))
		get_node("Options").get_node("Exit").add_color_override("font_color", Color8(216,162,221,100))
	
	elif options[option] == "How":
		get_node("Options").get_node("How").add_color_override("font_color", Color8(255,255,255))
		get_node("Options").get_node("Play").add_color_override("font_color", Color8(216,162,221,100))
		get_node("Options").get_node("Exit").add_color_override("font_color", Color8(216,162,221,100))
	
	elif options[option] == "Exit":
		get_node("Options").get_node("Exit").add_color_override("font_color", Color8(255,255,255))
		get_node("Options").get_node("Play").add_color_override("font_color", Color8(216,162,221,100))
		get_node("Options").get_node("How").add_color_override("font_color", Color8(216,162,221,100))
