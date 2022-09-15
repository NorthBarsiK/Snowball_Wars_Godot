extends Area2D

var player_in_area = false

func _ready():
	position.y = global.screen_size.y - 16*scale.x - 50

func _physics_process(delta):
	get_parent().can_p_refill_sb = player_in_area

func player_entered(body):
	if body.max_snowballs:
		player_in_area = true

func player_exited(body):
	if body.max_snowballs:
		player_in_area = false
