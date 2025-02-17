extends HBoxContainer

@export var max_count: int = 10  # Maximum number of items to display
# Called when the node enters the scene tree for the first time.
var is_paused = true
var health_textures = [
	preload("res://aseets/health bar/empty.png"),
	preload("res://aseets/health bar/1.png"),
	preload("res://aseets/health bar/2.png"),
	preload("res://aseets/health bar/3.png"),
	preload("res://aseets/health bar/4.png"),
	preload("res://aseets/health bar/5.png"),
	preload("res://aseets/health bar/6.png"),
	preload("res://aseets/health bar/full.png")
]
@onready var health_bar = $TextureRect
var max_health = 6
var current_health = GameData.health

func update_items(hlt: int) -> void:
	var health_stage = int((current_health / max_health) * (len(health_textures)-1))
	health_bar.texture = health_textures[health_stage]
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
