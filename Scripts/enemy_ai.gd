class_name EnemyAI
extends CharacterBody2D

@export var move_speed: float = 40.0
@export var max_health: int = 30
@export var knockback_force: float = 220.0
@export var knockback_recovery: float = 500.0

var current_health: int = 0
var player_chase: bool = false
var player: CharacterBody2D | null = null
var player_attacker: CharacterBody2D | null = null
var player_inattack_zone: bool = false
var can_take_damage: bool = true

var knockback_velocity: Vector2 = Vector2.ZERO
var hurt_audio: AudioStreamPlayer2D | null = null
var health_bar: ProgressBar | null = null

onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    current_health = max_health
    if has_node("HurtAudio"):
        hurt_audio = $HurtAudio
    if has_node("healthbar"):
        health_bar = $healthbar
        health_bar.max_value = max_health
        health_bar.value = current_health

func _physics_process(delta: float) -> void:
    deal_with_damage()
    _apply_knockback(delta)

    if player_chase and player != null:
        var chase_direction := player.position - position
        position += chase_direction / move_speed
        animated_sprite.play("walk")
        animated_sprite.flip_h = chase_direction.x < 0
    else:
        animated_sprite.play("idle")

func _on_detection_area_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D:
        player = body
        player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
    if body == player:
        player = null
    player_chase = false

func enemy() -> void:
    pass

func deal_with_damage() -> void:
    if not player_inattack_zone or not global.player_current_attack or not can_take_damage:
        return

    current_health -= 10
    _update_health_bar()
    $take_damage_cooldown.start()
    can_take_damage = false
    _apply_knockback_from_player(player_attacker if player_attacker != null else player)
    _play_hurt_sound()
    print("enemy health = ", current_health)

    if current_health <= 0:
        queue_free()

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
    if body.has_method("player"):
        player_inattack_zone = true
        player_attacker = body as CharacterBody2D

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
    if body.has_method("player"):
        if player_attacker == body:
            player_attacker = null
        player_inattack_zone = false

func _apply_knockback(delta: float) -> void:
    if knockback_velocity == Vector2.ZERO:
        return
    position += knockback_velocity * delta
    knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_recovery * delta)

func _apply_knockback_from_player(attacker: CharacterBody2D | null) -> void:
    if attacker == null:
        return
    var direction := (global_position - attacker.global_position).normalized()
    if direction == Vector2.ZERO:
        direction = Vector2.UP
    knockback_velocity = direction * knockback_force

func _play_hurt_sound() -> void:
    if hurt_audio != null and hurt_audio.stream != null:
        hurt_audio.play()

func _update_health_bar() -> void:
    if health_bar != null:
        health_bar.value = current_health

func _on_take_damage_cooldown_timeout() -> void:
    can_take_damage = true
