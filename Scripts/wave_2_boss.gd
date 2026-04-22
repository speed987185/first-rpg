class_name Wave2Boss
extends CharacterBody2D

const SPEED: float = 140.0
const DAMAGE: int = 15

var player_chase: bool = false
var player: CharacterBody2D = null

var health: int = 10000
var max_health: int = 10000
var player_inattack_zone: bool = false
var can_take_damage: bool = true

var dialogue_scene = preload("res://Scenes/dialogue_panel.tscn")
var has_talked = false
var superpower_dialogue_shown = false

@onready var healthbar: ProgressBar = $healthbar

func _ready():
	healthbar.max_value = max_health
	healthbar.value = health
	setup_healthbar()

func setup_healthbar():
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	bg.corner_radius_top_left = 6
	bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6
	
	var fg = StyleBoxFlat.new()
	fg.bg_color = Color(0.9, 0.1, 0.1, 1.0)
	fg.corner_radius_top_left = 6
	fg.corner_radius_top_right = 6
	fg.corner_radius_bottom_left = 6
	fg.corner_radius_bottom_right = 6
	
	healthbar.add_theme_stylebox_override("background", bg)
	healthbar.add_theme_stylebox_override("fill", fg)
	healthbar.show_percentage = false

func _physics_process(delta: float) -> void:
	update_health()
	deal_with_damage()

	if player_chase and player:
		var chase_direction: Vector2 = player.position - position
		position += chase_direction.normalized() * SPEED * delta
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = chase_direction.x < 0
	else:
		$AnimatedSprite2D.play("idle")
		
		



func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return
	player = body
	player_chase = true
	if not has_talked:
		has_talked = true
		var dialogue = dialogue_scene.instantiate()
		get_tree().current_scene.add_child(dialogue)
		dialogue.start_dialogue([
			"So, you defeated the first guardian...",
			"Impressive, but I am much stronger.",
			"Your journey ends right here. Die!"
		])
	

func enemy():
	pass

func _on_detection_area_body_exited(body: Node2D) -> void:
	if not body.has_method("player"):
		return
	player = null
	player_chase = false
	
func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return
	player_inattack_zone = true
		


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if not body.has_method("player"):
		return
	player_inattack_zone = false
		
func deal_with_damage() -> void:
	if not player_inattack_zone or not global.player_current_attack or not can_take_damage:
		return

	var dmg_taken = DAMAGE
	if global.super_power_active:
		dmg_taken = 5000

	health = max(health - dmg_taken, 0)
	can_take_damage = false
	$take_damage_cooldown.start()
	print("enemy health = ", health)
	
	if health <= 9900 and health > 0 and not superpower_dialogue_shown:
		superpower_dialogue_shown = true
		var dialogue = dialogue_scene.instantiate()
		get_tree().current_scene.add_child(dialogue)
		dialogue.start_dialogue([
			"You are surprisingly resilient...",
			"But wait, what is this power awakening within you?!",
			"(You have unlocked a SUPER POWER! Press 'E' to activate!)"
		])
		global.super_power_unlocked = true

	if health <= 0:
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/win.tscn")
		queue_free()
			
		


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
	
func update_health() -> void:
	healthbar.value = health
	healthbar.visible = true
