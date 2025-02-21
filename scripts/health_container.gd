extends HBoxContainer

@export var max_count: int = 10  # Maximum number of items to display
#var texture: Texture  # Dynamically assigned
var is_paused = false
@onready var pause: Button = $"../pause/pause"
@onready var pause_icon: TextureRect = $"../pause"
@onready var pause_menu: TextureRect = $"../pause menu"
@onready var play: Button = $"../pause menu/play"
@onready var restart: Button = $"../pause menu/restart"
@onready var home: Button = $"../pause menu/home"


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
	var health_stage = hlt
	print(health_stage)
	health_bar.texture = health_textures[health_stage]


func _on_button_pressed() -> void:
	get_tree().paused=true
	pause.disabled=true
	pause_icon.visible=false
	pause_menu.visible=true
	play.disabled=false
	restart.disabled=false
	home.disabled=false


func _on_play_pressed() -> void:
	get_tree().paused=false
	pause.disabled=false
	pause_icon.visible=true
	pause_menu.visible=false
	play.disabled=true
	restart.disabled=true
	home.disabled=true


func _on_restart_pressed() -> void:
	get_tree().paused=false
	pause.disabled=false
	pause_icon.visible=true
	pause_menu.visible=false
	play.disabled=true
	restart.disabled=true
	home.disabled=true
	get_tree().change_scene_to_file("res://scean/temple.tscn")
	GameData.save_point= Vector2(-1600, 1034)

func _on_home_pressed() -> void:
	get_tree().paused=false
	get_tree().change_scene_to_file("res://scean/main_menu.tscn")
