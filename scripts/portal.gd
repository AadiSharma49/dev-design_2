extends Area2D

#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var is_activated = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	



func _on_body_entered(body: Node2D) -> void:
	if not is_activated:
		if body.is_class("CharacterBody2D"):
			if body.keys>=4:
				is_activated= true
				print("player detected")
				animated_sprite_2d.play("open")
			else:
				#print(key_count)
				body.show_ins("you need to find 4 keys to open these portal")
				#ins.text=str("lyou need to find key to open these portda")
				



func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "open":
		animated_sprite_2d.play("start")
		GameData.save_point=Vector2(-189,-105)
		get_tree().change_scene_to_file("res://scean/level.tscn")


func _on_body_exited(body: Node2D) -> void:
	if not is_activated:
		if body.is_class("CharacterBody2D"):
			body.show_ins("")
