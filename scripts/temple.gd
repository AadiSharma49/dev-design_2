extends Node2D
var in_conversation=false
var dialogs = [
	{"speaker": "npc", "text": "Hello Rajan"},
	{"speaker": "player", "text": "Hi! Who are you?"},
	{"speaker": "npc", "text": "I'm the Tantrik"},
	{"speaker": "player", "text": "Nice to meet you!"},
]
var index=0
#d=dialogs[1]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tantrik_2_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		in_conversation=true
		#print("player detected")
		conversation()
		
func conversation() -> void:
	if index < dialogs.size():
		var dialog = dialogs[index]
		if dialog.speaker == "npc":
			$tantrik2/TextureRect.visible = true
			$Player/DialogueLabel.visible = false
			$tantrik2/TextureRect/Label.text = dialog.text
		elif dialog.speaker == "player":
			$tantrik2/TextureRect.visible = false
			$Player/DialogueLabel.visible = true
			$Player/DialogueLabel/Label.text = dialog.text
		index += 1
	else:
		end_conversation()
func _input(event: InputEvent) -> void:
	if in_conversation and event.is_action_pressed("next"):
		conversation()
func end_conversation() -> void:
	$Player/DialogueLabel.visible = false
	$tantrik2/TextureRect.visible = false
	index = 0
	in_conversation = false
	

	


func _on_tantrik_2_body_exited(body: Node2D) -> void:
	index=0
	$Player/DialogueLabel.visible = false
	$tantrik2/TextureRect.visible = false
