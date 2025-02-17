extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
func _on_body_entered(body: Node2D) -> void:
	GameData.save_point=Vector2(-4252,913)
	get_tree().change_scene_to_file("res://scean/game.tscn")
	#print(get_tree())
