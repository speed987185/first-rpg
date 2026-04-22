extends Node2D

func _ready():
	# Create physics boundaries so the player and boss cannot leave the camera limits
	var limits = [
		Rect2(Vector2(-50, -100), Vector2(50, 800)), # Left
		Rect2(Vector2(1080, -100), Vector2(50, 800)), # Right
		Rect2(Vector2(0, -120), Vector2(1080, 50)), # Top
		Rect2(Vector2(0, 600), Vector2(1080, 50)) # Bottom
	]
	
	for rect in limits:
		var body = StaticBody2D.new()
		var shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = rect.size
		shape.shape = rect_shape
		body.position = rect.position + rect.size / 2.0
		body.add_child(shape)
		add_child(body)
