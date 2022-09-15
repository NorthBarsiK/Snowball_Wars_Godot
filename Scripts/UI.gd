extends Control

var player_max_health = 3
var player_health = 3
var snowballs = 0

onready var hp100_face = load("res://Sprites/player_face_100hp.png")
onready var hp60_face = load("res://Sprites/player_face_60hp.png")
onready var hp25_face = load("res://Sprites/player_face_25hp.png")

onready var Php_bar = $game_UI/player_health
onready var face_rect = $game_UI/player_face
onready var snowball_count = $game_UI/snowball_count
onready var end_timer = $end_game_timer
onready var win_ui = $win_UI
onready var lose_ui = $lose_UI
onready var pause_ui = $pause_UI
onready var game_ui = $game_UI

func _ready():
	Php_bar.max_value = player_max_health
	Php_bar.value = player_max_health
	face_rect.texture = hp100_face
	rect_size = global.screen_size
	win_ui.visible = false
	lose_ui.visible = false
	pause_ui.visible = false
	game_ui.visible = true
	
func _physics_process(_delta):
	Php_bar.value = player_health
	snowball_count.text = str(snowballs)
	if player_health <= player_max_health - player_max_health/3 and player_health > player_max_health/3:
		face_rect.texture = hp60_face
	elif player_health <= player_max_health/3:
		face_rect.texture = hp25_face
	else:
		face_rect.texture = hp100_face

func set_health(health):
	player_health = health

func set_max_health(health):
	player_max_health = health

func set_snowballs(_snowballs):
	snowballs = _snowballs
	if snowballs == 0:
		$game_UI/snowball_count.modulate = Color.darkred
	else:
		$game_UI/snowball_count.modulate = Color.white

func start_game_over():
	end_timer.start()

func game_over():
	game_ui.visible = false
	if get_parent().is_lose:
		lose_ui.visible = true	
	elif get_parent().is_win:
		win_ui.visible = true

func restart():
	global.restart_scene()

func pause():
	pause_ui.visible = true
	game_ui.visible = false
	global.stop_time(true)

func continue_game():
	pause_ui.visible = false
	game_ui.visible = true
	global.stop_time(false)

func load_menu():
	global.load_scene("menu")

func load_next_scene():
	var current_scene = global.get_current_scene()
	var level_index = global.scenes.find(current_scene)
	global.load_scene(global.scenes[level_index + 1])
