extends CharacterBody2D

# Constants
const SPEED = 1000.0
const JUMP_VELOCITY = -2252.0
const GRAVITY = 4000.0
const FAST_GRAVITY = 6000.0
const JUMP_ANIMATION_SPEED = 1.5
const MAX_JUMPS = 2
const HEALTH_MAX = 10

# Variables
var dying = false
var dashing = false
var spawning = true
var health = GameData.health
var coins = GameData.coins
var dead = false
var direction = 0
var jump_count = 0
var is_attacking = false
var is_fast_jumping = false
var last_save_point: Vector2 = Vector2(-4150, 906)
var push_speed = 500
var knock_backing = false
var dash_active = true
var keys = 0

# Nodes
@onready var audio_jump: AudioStreamPlayer2D = $AudioStreamPlayer2D4
@onready var audio_walk: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var coincount = $"CanvasLayer/CoinContainer/Label"
@onready var health_container = $"CanvasLayer/HealthContainer"
@onready var collision_shape_2d_2: CollisionShape2D = $AttackArea/CollisionShape2D2
@onready var attack_area = $AttackArea/CollisionShape2D
@onready var audio_hit: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_sword: AudioStreamPlayer2D = $AudioStreamPlayer2D3
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $"CanvasLayer/ChargeContainer/AnimatedSprite2D"
@onready var label: Label = $"CanvasLayer/KeyContainer/Label"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	position = GameData.save_point
	health = 5
	coins = 0
	GameData.health = health
	GameData.coins = coins
	health_container.update_items(health)
	coincount.text = str(coins)
	attack_area.disabled = true

func _physics_process(delta: float) -> void:
	if not knock_backing and not dashing:
		velocity.x = 0

	if not is_on_floor():
		velocity.y += (FAST_GRAVITY if is_fast_jumping else GRAVITY) * delta
	else:
		jump_count = 0
		is_fast_jumping = false
		animated_sprite.speed_scale = 1.0

	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking and not dashing and not spawning:
		if not knock_backing and not dying:
			perform_attack()
			return  # Skip movement during attack

	# Handle jump
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		if not knock_backing and not dying and not dashing:
			perform_jump()

	if Input.is_action_just_pressed("dash") and not spawning and dash_active:
		dashing = true
		direction = 1 if not animated_sprite.flip_h else -1
		velocity.x = 1000 * direction

		if not knock_backing and not dying:
			animated_sprite.stop()
			animated_sprite.play("dash")
			dash_active = false
			timer.start()
			animated_sprite_2d.play("default")
			collision_shape_2d_2.disabled = false
			return

	# Get horizontal input
	direction = Input.get_axis("move_left", "move_right")

	# Flip sprite and adjust attack area
	adjust_sprite_orientation()

	# Play animations
	update_animations()

	# Handle horizontal movement
	if not is_attacking and direction != 0 and not dashing:
		velocity.x = direction * SPEED

	move_and_slide()

func perform_jump() -> void:
	if jump_count == 0:  # Play sound only on the first jump
		audio_jump.play()

	is_fast_jumping = true
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	animated_sprite.play("jump")
	animated_sprite.speed_scale = JUMP_ANIMATION_SPEED

func perform_attack() -> void:
	velocity.x = 0
	animated_sprite.stop()
	is_attacking = true
	animated_sprite.play("attack")
	audio_sword.play()
	attack_area.disabled = false

func count_coin(amount: int) -> void:
	coins += amount
	coincount.text = str(coins)
	GameData.coins = coins
	print("Coins collected:", coins)

func die() -> void:
	#dead = true
	#collision_shape_2d.disabled=true
	dying= true
	velocity.x=0
	knock_backing=false
	print("Player died. Restarting...")
	animated_sprite.stop()
	animated_sprite.play("die")
	audio_stream_player_2d.play()

func knock_back(direct):
	# Apply knockback in the opposite direction
	knock_backing=true
	animated_sprite.play("knockback")
	#print(direct)
	velocity = direct * -push_speed

func heal(amount: int) -> void:
	if health < HEALTH_MAX:
		health += amount
		health = min(health, HEALTH_MAX)
		health_container.update_items(health)

func take_damage(amount: int,direct=null,) -> void:
	if dying:
		return
	health -= amount
	dying=true
	animated_sprite.play("die")
	health = max(health, 0)
	health_container.update_items(health)
	GameData.health = health
	print("Player health:", health)
	if direct && health > 0:
		knock_back(direct)
	if health == 0:
		die()

func _on_save_point_activated(position: Vector2) -> void:
	last_save_point = position
	print("Save point activated at:", position)

func adjust_sprite_orientation() -> void:
	if direction > 0:
		animated_sprite.flip_h = false
		$AttackArea.position.x = abs($AttackArea.position.x)
	elif direction < 0:
		animated_sprite.flip_h = true
		$AttackArea.position.x = -abs($AttackArea.position.x)

func update_animations() -> void:
	if is_attacking:
		audio_walk.stop()
		if not animated_sprite.is_playing():
			attack_area.disabled = true
			is_attacking = false
	elif is_on_floor() and not knock_backing and not dying and not dashing and not spawning:
		if direction == 0:
			animated_sprite.play("idle")
			if audio_walk.playing:  
				audio_walk.stop()
				audio_jump.stop()  # Stop sound when idle
		else:
			animated_sprite.play("walk")
			if not audio_walk.playing:  
				audio_walk.play()
				audio_jump.stop()  # Ensure jump sound doesn't interfere

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "spawn":
		spawning = false
	elif animated_sprite.animation == "dash":
		collision_shape_2d_2.disabled = true
		dashing = false
	elif animated_sprite.animation == "knockback":
		knock_backing = false
		velocity.x = 0
	elif animated_sprite.animation == "die":
		if health > 0:
			position = GameData.save_point
			dying = false
			dead = true
			animated_sprite.play("spawn")
		else:
			audio_hit.stop()
			dead = true
			dying = false
			health = 5
			position = GameData.save_point
			GameData.health = health
			health_container.update_items(health)
			animated_sprite.play("spawn")
			spawning = true

func _on_timer_timeout() -> void:
	dash_active = true

func take_key() -> void:
	keys += 1
	label.text = str(keys)

func show_ins(ins: String) -> void:
	$CanvasLayer/Label.text = ins
