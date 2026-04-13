extends Node2D
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	SceneTransition.change_scene_to("res://Scenes/world_1.tscn")
