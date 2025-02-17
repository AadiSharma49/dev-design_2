extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var dialogs = {1:[-110.8,],2:[55.4],3:[55.4],4:[55.4],5:[18.5],6:[9.2],7:[0],8:[-9.3],9:[],10:[],11:[],12:[],13:[],14:[],15:[],16:[],17:[],18:[],19:[],20:[]}
# Called every frame. 'deltha' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var frame = animated_sprite_2d.frame
	pass
