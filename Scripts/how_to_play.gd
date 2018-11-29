extends MarginContainer

func get_input():
	if  Input.is_action_just_pressed("exit"):
		get_tree().change_scene("res://Scenes/main_menu.tscn")

func _process(delta):
	get_input()