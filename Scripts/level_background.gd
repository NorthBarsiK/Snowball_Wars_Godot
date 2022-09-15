extends Sprite

export var bg_size_x = 480#Ширина спрайта
export var bg_size_y = 640#Высота спрайта

func _ready():
	#Настройка размера спрайта по размеру экрана
	scale.x = global.screen_size.x/bg_size_x
	scale.y = global.screen_size.y/bg_size_y
	#Задаём позицию посередине экрана
	position.x = global.screen_size.x/2
	position.y = global.screen_size.y/2
