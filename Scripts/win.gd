extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_fromstart_pressed():
	print("Play Again button pressed!")
	get_tree().paused = false
	global.super_power_unlocked = false
	global.super_power_active = false
	global.player_current_attack = false
	get_tree().change_scene_to_file("res://Scenes/world_1.tscn")
