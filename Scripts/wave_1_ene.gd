class_name Wave1Enemy
extends CharacterBody2D

const SPEED: float = 70.0
const KNOCKBACK_FORCE: float = 220.0
const KNOCKBACK_RECOVERY: float = 500.0

var player_chase: bool = false
var player: CharacterBody2D = null
var player_attacker: CharacterBody2D = null

var health: int = 50
var max_health: int = 50
var player_inattack_zone: bool = false
var can_take_damage: bool = true

var knockback_velocity: Vector2 = Vector2.ZERO
var hurt_audio: AudioStreamPlayer2D = null

func _ready() -> void:
	if has_node("HurtAudio"):
		hurt_audio = $HurtAudio
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

func _physics_process(delta: float) -> void:
	update_health()
	deal_with_damage()
	_apply_knockback(delta)

	if player_chase and player != null:
		var chase_direction: Vector2 = player.position - position
		position += chase_direction / SPEED
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = chase_direction.x < 0
	else:
		$AnimatedSprite2D.play("idle")
		
		



func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player = body
		player_chase = true
	


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
	player_chase = false
	
func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true
		player_attacker = body as CharacterBody2D
		


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		if player_attacker == body:
			player_attacker = null
		player_inattack_zone = false
		
func deal_with_damage():
	if player_inattack_zone and global.player_current_attack == true:
		if can_take_damage == true:
			health -= 10
			$take_damage_cooldown.start()
			can_take_damage = false
			if hurt_audio:
				hurt_audio.play()
			if player_attacker:
				var direction := (global_position - player_attacker.global_position).normalized()
				if direction == Vector2.ZERO:
					direction = Vector2.UP
				knockback_velocity = direction * KNOCKBACK_FORCE
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

func _apply_knockback(delta: float) -> void:
	if knockback_velocity.length_squared() > 0:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_RECOVERY * delta)
		if knockback_velocity.length_squared() < 1.0:
			knockback_velocity = Vector2.ZERO
