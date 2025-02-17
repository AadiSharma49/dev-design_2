extends Area2D

signal save_point_activated(position: Vector2)

var is_active: bool = false

func _on_body_entered(body: Node2D) -> void:
	if not is_active:#print("player detected")
		is_active = true
		$AnimatedSprite2D.visible=true
		GameData.save_point=position
