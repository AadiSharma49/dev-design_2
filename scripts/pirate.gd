extends Node2D

var dead = false
var player_position = null  # Can hold null or Vector2
var is_attacking = false
var is_running = false
var speed = 500
var health = 3
var direction = 1
var attack_speed_boost = 1500  # Increased speed during attack
var attack_boost_duration = 0.5  # Duration of speed boost in seconds
var boost_timer = 0.0  # Timer to track boost duration
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_enemy: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var ray_cast_right = $RayCastRight
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

func _process(delta: float) -> void:
	if dead:
		return

	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			speed = 500  # Reset to normal speed after boost

	if ray_cast_right.is_colliding():
		var collider = ray_cast_right.get_collider()
		if collider and collider.is_class("TileMap"):
			if direction == -1:
				direction = 1
				scale.x = 1
			elif direction == 1:
				direction = -1
				scale.x = -1
		elif collider and collider.is_class("CharacterBody2D"):
			print("player detectted")
			is_running = false
			is_attacking = true

	if is_attacking:
		for body in detection_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				player_position = body.global_position
				print("attacking")
				flip_towards_player()
				speed = attack_speed_boost  # Increase speed during attack
				boost_timer = attack_boost_duration
				animated_sprite_2d.speed_scale = 1.2  # Faster attack animation
				audio_stream_player_enemy.play()
				animated_sprite_2d.play("attack")
				
	elif is_running:
		for body in detection_area.get_overlapping_bodies():
			if body is CharacterBody2D:
				player_position = body.position
				flip_towards_player()
				move_toward_player(delta)
			else:
				is_running = false
	else:
		if animated_sprite_2d.animation != "attack":
			position.x += direction * speed * delta
			animated_sprite_2d.speed_scale = speed / 166.67
			animated_sprite_2d.speed_scale = 1
			animated_sprite_2d.play("idle")

func flip_towards_player() -> void:
	if player_position.x > global_position.x:
		scale.x = 1  # Face right
	else:
		scale.x = -1  # Face left

func move_toward_player(delta: float) -> void:
	if player_position:
		direction = (player_position.x - global_position.x)
		direction = direction / abs(direction) if direction != 0 else 0  # Normalize
		global_position.x += direction * speed * delta
		animated_sprite_2d.speed_scale = 1.5
		animated_sprite_2d.play("run")

func knockback(direction: Vector2) -> void:
	var slide_time = 0.2  # Duration of slide effect (in seconds)
	var slide_distance = 50  # Distance to slide back
	var slide_speed = slide_distance / slide_time

	var target_position = global_position + direction.normalized() * slide_distance
	var tween = create_tween()

func _on_detection_area_body_entered(body: CharacterBody2D) -> void:
	animated_sprite_2d.stop()
	is_running = true
	is_attacking = false

func _on_detection_area_body_exited(body: CharacterBody2D) -> void:
	is_running = false
	is_attacking = false
	player_position = null  # Clear player position

func _on_attack_area_body_entered(tle: TileMap) -> void:
	if direction == -1:
		direction = 1
		scale.x = 1
	elif direction == 1:
		direction = -1
		scale.x = -1

func _on_attack_area_body_exited(player) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("sword"):
		health -= 1
		if health == 0:
			dead = true
			animated_sprite_2d.play("die")

func _on_animated_sprite_2d_animation_finished() -> void:
	for body in detection_area.get_overlapping_bodies():
		player_position = body.global_position
	if animated_sprite_2d.animation == "attack":
		audio_stream_player_enemy.play()
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				var attack_direction = (body.global_position - global_position).normalized()
				body.take_damage(1)
		is_attacking = false
		is_running = true
	elif animated_sprite_2d.animation == "die":
		queue_free()
