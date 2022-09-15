extends Node2D

onready var screen_size = get_viewport_rect().size#Размер экрана

var scenes = [
	"level_1",
	"level_2", 
	"level_3"
]

func restart_scene():
	get_tree().reload_current_scene()

func load_scene(scene_name):
	for i in scenes:
		if i == scene_name:
			get_tree().change_scene("res://Scenes/" + scene_name + ".tscn")
			break
		else:
			get_tree().change_scene("res://Scenes/menu.tscn")

func stop_time(is_stopped):
	get_tree().paused = is_stopped

func get_current_scene():
	return get_tree().current_scene.name
