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
var dashing=false
var spawning=true
var health = GameData.health
var coins = GameData.coins
var dead = false
var direction = 0
var jump_count = 0
var is_attacking = false
var is_fast_jumping = false
var last_save_point: Vector2 = Vector2(-4150, 906)
var push_speed = 500
var knock_backing=false
var dash_active=true

# Nodes
@onready var audio_stream_player_2d_2: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var coincount = $"CanvasLayer/CoinContainer/Label"
@onready var health_container = $"CanvasLayer/HealthContainer"
@onready var collision_shape_2d_2: CollisionShape2D = $AttackArea/CollisionShape2D2
@onready var attack_area = $AttackArea/CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_stream_player_2d_sword: AudioStreamPlayer2D = $AudioStreamPlayer2D3
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $"CanvasLayer/ChargeContainer/AnimatedSprite2D"



func _ready() -> void:
	# Initialize game state
	position = GameData.save_point
	health = 5
	coins = 0
	GameData.health = health
	GameData.coins = coins
	health_container.update_items(health)
	coincount.text = str(coins)
	
	attack_area.disabled = true
	#animated_sprite.play("")

func take_damage(amount: int,direct=null,) -> void:
	if dying:
		return
	health -= amount
	health = max(health, 0)
	health_container.update_items(health)
	GameData.health = health
	print("Player health:", health)
	if direct && health > 0:
		knock_back(direct)
	if health == 0:
		die()

func heal(amount: int) -> void:
	if health < HEALTH_MAX:
		health += amount
		health = min(health, HEALTH_MAX)
		health_container.update_items(health)

func count_coin(amount: int) -> void:
	coins += amount
	coincount.text = str(coins)
	GameData.coins = coins
	print("Coins collected:", coins)

func _on_save_point_activated(position: Vector2) -> void:
	last_save_point = position
	print("Save point activated at:", position)

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
	
	#health = 5
	#position = GameData.save_point
	#GameData.health = health
	#health_container.update_items(health)
	#animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	if not knock_backing and not dashing:
		velocity.x = 0
	#var box=is_colliding_with_box()
	#if box:
		##box = get_colliding_box()
		#if box:
			#box.push(direction * push_speed)

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
		dashing=true
		if animated_sprite.flip_h == false:
			direction=1
		if animated_sprite.flip_h == true:
			direction=-1	
			
		velocity.x=1000*direction
		#direction = 1
		if not knock_backing and not dying:
			animated_sprite.stop()
			animated_sprite.play("dash")
			dash_active=false
			timer.start()
			print("performing dash")
			animated_sprite_2d.play("default")
			collision_shape_2d_2.disabled=false
			return
	# Get horizontal input
	direction = Input.get_axis("move_left", "move_right")
	
	print(velocity.x)

	# Flip sprite and adjust attack area
	adjust_sprite_orientation()

	# Play animations
	update_animations()

	# Handle horizontal movement
	if not is_attacking and direction != 0 and not dashing:
		velocity.x = direction * SPEED
	move_and_slide()

func perform_jump() -> void:
	is_fast_jumping = true
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	animated_sprite.play("jump")
	audio_stream_player_2d_2.stop()
	animated_sprite.speed_scale = JUMP_ANIMATION_SPEED

func is_colliding_with_box() -> bool:
	var collision_shape = $CollisionShape2D
	return collision_shape.ge(1)  # Ensure layer 1 is the box layer
	
func get_colliding_box(box: RigidBody2D):
	for body in box.get_colliding_bodies():
		if body.is_in_group("box"):
			return body
	return null
func perform_attack() -> void:
	velocity.x = 0
	animated_sprite.stop()
	is_attacking = true
	animated_sprite.play("attack")
	audio_stream_player_2d_sword.play()
	attack_area.disabled = false

func adjust_sprite_orientation() -> void:
	if direction > 0:
		animated_sprite.flip_h = false
		
		$AttackArea.position.x = abs($AttackArea.position.x)
	elif direction < 0:
		animated_sprite.flip_h = true
		$AttackArea.position.x = -abs($AttackArea.position.x)

func knock_back(direct):
	# Apply knockback in the opposite direction
	knock_backing=true
	animated_sprite.play("knockback")
	#print(direct)
	velocity = direct * -push_speed

func update_animations() -> void:
	if is_attacking:
		audio_stream_player_2d_2.stop()
		if not animated_sprite.is_playing():
			attack_area.disabled = true
			is_attacking = false
	elif is_on_floor() and not knock_backing and not dying and not dashing and not spawning:
		if direction == 0:
			animated_sprite.play("idle")
			if audio_stream_player_2d_2.playing:  
				audio_stream_player_2d_2.stop()  # Stop sound when idle
		else:
			animated_sprite.play("walk")
			if not audio_stream_player_2d_2.playing:  
				audio_stream_player_2d_2.play()  # Play sound if not already playing



func _on_animated_sprite_2d_animation_finished() -> void:
	#print("animation finished:  "+ animated_sprite.animation)
	if animated_sprite.animation == "spawn":
		spawning=false
	if animated_sprite.animation == "dash":
		collision_shape_2d_2.disabled=true
		dashing=false
	if animated_sprite.animation == "knockback":
		print("knock back finish")
		knock_backing=false
		velocity.x=0
	if animated_sprite.animation == "die":
		audio_stream_player_2d.stop()
		dead=true
		dying=false
		print("die animation finish")
		health = 5
		position = GameData.save_point
		GameData.health = health
		health_container.update_items(health)
		animated_sprite.play("spawn")
		spawning=true


func _on_timer_timeout() -> void:
	dash_active=true
