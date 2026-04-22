class_name Player
extends CharacterBody2D

const SPEED: float = 100.0
const PLAYER_KNOCKBACK_FORCE: float = 220.0
const PLAYER_KNOCKBACK_RECOVERY: float = 600.0

var current_dir: String = "none"
var enemy_inattack_range: bool = false
var enemy_attack_cooldown: bool = true
var enemy_attacker: Node2D = null
var health: int = 100
var max_health: int = 100
var player_alive: bool = true

var attack_ip: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var can_attack: bool = true

var shake_intensity: float = 0.0
var base_camera_offset: Vector2 = Vector2.ZERO
var current_camera: Camera2D = null

func _ready():
	$AnimatedSprite2D.play("front_idle")
	$healthbar.max_value = max_health
	$healthbar.value = health
	setup_healthbar()

func setup_healthbar():
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	bg.corner_radius_top_left = 4
	bg.corner_radius_top_right = 4
	bg.corner_radius_bottom_left = 4
	bg.corner_radius_bottom_right = 4
	
	var fg = StyleBoxFlat.new()
	fg.bg_color = Color(0.2, 0.8, 0.2, 1.0)
	fg.corner_radius_top_left = 4
	fg.corner_radius_top_right = 4
	fg.corner_radius_bottom_left = 4
	fg.corner_radius_bottom_right = 4
	
	$healthbar.add_theme_stylebox_override("background", bg)
	$healthbar.add_theme_stylebox_override("fill", fg)
	$healthbar.show_percentage = false

func player():
	pass

func _physics_process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_E) and global.super_power_unlocked and not global.super_power_active:
		activate_super_power()
		
	if Input.is_physical_key_pressed(KEY_L):
		get_tree().change_scene_to_file("res://Scenes/wave_2_boss_f.tscn")
		
	enemy_attack()
	player_movement(delta)
	attack()
	update_health()
	
	if health <= 0:
		player_alive = false
		health = 0
		print("player has died")
		SceneTransition.change_scene_to("res://Scenes/world_1.tscn")

func player_movement(_delta: float) -> void:
	var movement: int = 0
	var input_velocity: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("right"):
		current_dir = "right"
		movement = 1
		input_velocity.x = SPEED
		input_velocity.y = 0
		
	elif Input.is_action_pressed("left"):
		current_dir = "left"
		movement = 1
		input_velocity.x = -SPEED
		input_velocity.y = 0
		
	elif Input.is_action_pressed("down"):
		current_dir = "down"
		movement = 1
		input_velocity.y = SPEED
		input_velocity.x = 0
		
	elif Input.is_action_pressed("up"):
		current_dir = "up"
		movement = 1
		input_velocity.y = -SPEED
		input_velocity.x = 0

	play_anim(movement)

	

	velocity = input_velocity + knockback_velocity
	move_and_slide()

	if knockback_velocity.length_squared() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, PLAYER_KNOCKBACK_RECOVERY * _delta)
		if knockback_velocity.length_squared() < 1.0:
			knockback_velocity = Vector2.ZERO



func play_anim(movement: int) -> void:
	var dir: String = current_dir
	var anim: AnimatedSprite2D = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walking")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walking")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	
	elif dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front_walking")
		elif movement == 0:
			if attack_ip == false:
					anim.play("front_idle")
	
	elif dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("back_idle")

			

	# Footstep timer: start when walking animation plays, stop otherwise.
	var current_anim: String = String(anim.animation)
	var is_walking: bool = current_anim.find("walk") >= 0 and anim.is_playing()
	if is_walking:
		if $footstep_timer.is_stopped():
			$footstep_timer.start()
	else:
		if not $footstep_timer.is_stopped():
			$footstep_timer.stop()

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true
		enemy_attacker = body
		


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false
		if body == enemy_attacker:
			enemy_attacker = null

func enemy_attack() -> void:
	if enemy_inattack_range and enemy_attack_cooldown:
		health -= 10
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		if enemy_attacker != null:
			_apply_knockback_from_enemy(enemy_attacker)
		print(health)


func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true


func _apply_knockback_from_enemy(attacker: Node2D) -> void:
	var direction: Vector2 = (global_position - attacker.global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.UP
	knockback_velocity = direction * PLAYER_KNOCKBACK_FORCE

func activate_super_power():
	global.super_power_active = true
	$AnimatedSprite2D.modulate = Color(2.0, 2.0, 0.5, 1.0) # Glow yellow
	print("Super power activated!")
	
	shake_intensity = 15.0
	current_camera = get_viewport().get_camera_2d()
	if current_camera:
		base_camera_offset = current_camera.offset
	
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(func():
		global.super_power_active = false
		shake_intensity = 0.0
		if is_instance_valid(current_camera):
			current_camera.offset = base_camera_offset
		if is_instance_valid(self) and has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
		print("Super power ended!")
	)

func _process(delta: float) -> void:
	if shake_intensity > 0 and is_instance_valid(current_camera):
		current_camera.offset = base_camera_offset + Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))

func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("attack") and can_attack:
		if not global.super_power_active:
			can_attack = false
			get_tree().create_timer(1.0).timeout.connect(func(): can_attack = true)
		
		$AttackAudio.play()
		global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("back_attack")
			$deal_attack_timer.start()
			
			
	


func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false
	


func _on_footstep_timer_timeout() -> void:
	$FootstepAudio.play()
	

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	
	if health >= max_health:
		healthbar.visible = false
	else:
		healthbar.visible = true

func _on_regin_timer_timeout() -> void:
	if health < max_health:
		health = health + 20
		if health > max_health:
			health = max_health
	if health <= 0:
		health = 0








	
