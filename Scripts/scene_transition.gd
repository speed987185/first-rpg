extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func change_scene_to(scene_path: String) -> void:
	# Make sure the ColorRect is visible and fully transparent at start
	color_rect.modulate.a = 0.0
	color_rect.show()
	
	# Create new tween
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Fade to black
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.3)
	
	# After fade-in finishes, change the scene
	tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
	)
	
	# Fade out (this will happen in the new scene)
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.4)
	
	# Hide ColorRect after fade out
	tween.tween_callback(color_rect.hide)
