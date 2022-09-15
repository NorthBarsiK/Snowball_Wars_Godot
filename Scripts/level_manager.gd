extends Node2D

var player_position = Vector2()
var enemies = 0
var is_win = false
var is_lose = false
var can_p_refill_sb = false

onready var interface = $UI

func set_player_position(pos):
	player_position = pos

func get_player_position():
	return player_position

func add_enemy():
	enemies += 1

func deduct_enemy():
	enemies -= 1
	if enemies <= 0:
		$UI.start_game_over()
		is_win = true

func player_die():
	$UI.start_game_over()
	is_lose = true

func send_player_health(health):
	$UI.set_health(health)

func send_player_max_health(health):
	$UI.set_max_health(health)

func send_player_snowballs(snowballs):
	$UI.set_snowballs(snowballs)

func snowballs_refill():
	return can_p_refill_sb
