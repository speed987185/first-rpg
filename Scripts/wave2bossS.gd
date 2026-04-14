extends Node2D





func _on_back_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	SceneTransition.change_scene_to("res://Scenes/wave1.tscn")
