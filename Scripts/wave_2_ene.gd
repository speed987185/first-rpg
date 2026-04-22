extends CharacterBody2D

var speed = 70.0
var player_chase = false
var player = null

var health = 60
var max_health = 60
var player_inattack_zone = false
var can_take_damage = true

func _ready():
	$healthbar.max_value = max_health
	$healthbar.value = health
	setup_healthbar()

func setup_healthbar():
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	bg.corner_radius_top_left = 3
	bg.corner_radius_top_right = 3
	bg.corner_radius_bottom_left = 3
	bg.corner_radius_bottom_right = 3
	
	var fg = StyleBoxFlat.new()
	fg.bg_color = Color(0.8, 0.2, 0.2, 1.0)
	fg.corner_radius_top_left = 3
	fg.corner_radius_top_right = 3
	fg.corner_radius_bottom_left = 3
	fg.corner_radius_bottom_right = 3
	
	$healthbar.add_theme_stylebox_override("background", bg)
	$healthbar.add_theme_stylebox_override("fill", fg)
	$healthbar.show_percentage = false

func _physics_process(delta):
	update_health()
	deal_with_damage()
	
	if player_chase:
		position += (player.position - position).normalized() * speed * delta
		$AnimatedSprite2D.play("walk")
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")
		
		



func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	


func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true
		


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false
		
func deal_with_damage():
	if player_inattack_zone and global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 10
			$take_damage_cooldown.start()
			can_take_damage = false
		print("enemy health = ", health)
		if health <= 0:
			self.queue_free()
			
		


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
	
func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	
	if health >= max_health:
		healthbar.visible = false
	else:
		healthbar.visible = true
