extends Area2D

var is_collected=0
#$Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_entered(body: Node2D) -> void:
	if not is_collected:
		if body.is_in_group("player"):
			is_collected=true
			body.take_key()
			$Sprite2D.visible=false
