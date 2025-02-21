extends Node2D

var dead = false
var player_position = null  # Can hold null or Vector2
var is_attacking = false
var is_running = false
var speed = 500
var health = 1
var direction = 1
var attack_speed_boost = 700  # Increased speed during attack
var attack_boost_duration = 0.5  # Duration of speed boost in seconds
var boost_timer = 0.0  # Timer to track boost duration
# Called when the node enters the scene tree for the first time.
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var body: Area2D = $body
@onready var attack_area: Area2D = $AttackArea
@onready var detection_area: Area2D = $DetectionArea
@onready var collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dead:
		return
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
			is_running = false
			is_attacking = true
	if not is_attacking and not dead:
		#animated_sprite_2d.play("walk")
		global_position.x += direction * speed * delta
	if is_attacking:
		animated_sprite_2d.play("attack")
		#collision_shape_2d.disabled=false


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		speed = 1000
		is_running = true
		for bod in detection_area.get_overlapping_bodies():
			if bod is CharacterBody2D:
				player_position = bod.position
		if player_position.x > global_position.x:
			scale.x = 1  # Face right
			direction = 1
		else:
			scale.x = -1  # Face left
			direction = -1
		animated_sprite_2d.play("run")


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		speed=500
		is_running=false
		animated_sprite_2d.play("walk")
   

func _on_attack_area_body_entered(tle: TileMap) -> void:
	if direction == -1:
		direction = 1
		scale.x = 1
	elif direction == 1:
		direction = -1
		scale.x = -1


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		#collision_shape_2d.disabled = true
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				var attack_direction = (body.global_position - global_position).normalized()
				body.take_damage(1)
		is_attacking=false
		is_running=true
	if animated_sprite_2d.animation == "die":
		queue_free()


func _on_body_area_entered(area: Area2D) -> void:
	if area.is_in_group("sword"):
		health -= 1
		print("get attacked")
		print(health)
		if health == 0:
			dead = true
			is_attacking=false
			is_running=false
			animated_sprite_2d.play("die")
