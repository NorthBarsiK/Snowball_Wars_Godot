extends KinematicBody2D
#Характеристики
export var health = 2#Жизнь
export var move_speed = 50#Скорость перемещения
export var action_delay = 0.5#Задержка действия
export var throw_delay = 3#Количество действий между бросками
export var snowball_speed = 200#Скорость снежка
#Рабочие переменные
var movement_directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]#Массив направлений
var actions = ["move", "throw", "wait"]#Массив действий
var velocity = Vector2()#Вектор движения
var is_throw = false#Статус броска
var is_alive = true#Статус жизни
var snowball_path = "res://Scenes/snowball.tscn"#Путь к снежку
var _snowball#Экземпляр снежка
var player_position = Vector2()#Позиция цели
var current_throw_delay#Остаток действий между бросками
#Ссылки на дочерние элементы
onready var parent = get_parent()#Родительский объект
onready var hp_bar = $health_bar#Полоска здоровья
onready var action_timer = $action_timer#Задержка между действиями
onready var anim = $sprites#Графическая часть
onready var SCP_L = $snowball_create_point_1#Левая точка создания снежка
onready var SCP_R = $snowball_create_point_2#Правая точка создания снежка
onready var death_timer = $death_timer#Таймер сколько труп остаётся на арене
onready var t_audio = $throw_audio

func _ready():
	#Назначение свойств полоски здоровья
	hp_bar.max_value = health
	hp_bar.value = health
	hp_bar.visible = false
	
	#Назначение задержки перед бросками
	current_throw_delay = throw_delay
	
	#Назначение задержки между действиями
	action_timer.wait_time = action_delay
	
	#Получение позиции игрока
	recieve_player_position()
	
	#Добавляем в счёт противников наш экземпляр
	parent.add_enemy()
	
	#Подгружаем сцену снежка
	_snowball = load(snowball_path)

func _physics_process(_delta):
	#Масштабирование в зависимостии от положения на экране
	scale.x = (global.screen_size.y - (global.screen_size.y - global_position.y))/200
	scale.y = scale.x
	
	#Передвижение по вектору
	velocity = move_and_slide(velocity, Vector2.UP)
	
	#Получение позиции игрока
	recieve_player_position()
	

#Получение позиции игрока
func recieve_player_position():
	player_position = parent.get_player_position()

#Выбор следующего действия
func delay_timeout():
	if not parent.is_lose:	
		randomize()
		var action = actions[rand_range(0, actions.size())]#Выбираем действие из массива действий
		
		if not is_throw and is_alive:#Если противник не совершает бросок и не умер, выбирается действие
			match action:
				"move":
					move()
				"throw":
					throw()
				"wait":
					wait()
	else:
		enemy_win()

#Передвижение
func move():
	randomize()
	var direction = movement_directions[rand_range(0, movement_directions.size())]#Выбираем направление движение из массива направлений
	var animation = "idle"#По умолчанию ставим простую анимацию
	
	velocity = Vector2()#Обнуляем вектор передвижения
	match direction:#Заполняем вектор в зависимости от направления движения
		"N":
			velocity.y = -move_speed
		"NE":
			velocity.y = -move_speed
			velocity.x = move_speed
		"E":
			velocity.x = move_speed
		"SE":
			velocity.y = move_speed
			velocity.x = move_speed
		"S":
			velocity.y = move_speed
		"SW":
			velocity.y = move_speed
			velocity.x = -move_speed
		"W":
			velocity.x = -move_speed
		"NW":
			velocity.y = -move_speed
			velocity.x = -move_speed
	
	#Ограничиваем перемещение
	check_limits()
	
	#В зависимости от направления движения задаём анимацию
	if velocity.y > 0:
		animation = "run_D"
	elif velocity.y < 0:
		animation = "run_U"
	elif velocity.x > 0:
		animation = "run_R"
	elif velocity.x < 0:
		animation = "run_L"
		
	anim.animation = animation

#Ограничиваем перемещение
func check_limits():
	var pos = global_position#Получаем глобальную позицию на экране
	if pos.y >= global.screen_size.y - (32*3 + 250) and velocity.y > 0:#Ограничиваем движение вниз
		velocity.y = 0
	if pos.y <= global.screen_size.y/5 and velocity.y < 0:#Ограничиваем движение вверх
		velocity.y = 0
	if pos.x >= global.screen_size.x - scale.x*32 and velocity.x > 0:#Ограничиваем движение вправо
		velocity.x = 0
	if pos.x <= global.screen_size.x - (global.screen_size.x - scale.x*32) and velocity.x < 0:#Ограничиваем движение влево
		velocity.x = 0

#Бросок
func throw():
	#Если действие броска было выбрано, но задержка между бросками не закончилась, то просто ожидаем
	if current_throw_delay == 0:
		is_throw = true#Говорим игре, что враг бросает снежок
		current_throw_delay = throw_delay#Возвращаем задержку бросков
		velocity = Vector2()#Обнуляем вектор
		anim.animation = "throw_1"#Задаём анимацию
	else:
		current_throw_delay -= 1
		wait()

#Когда анимация броска заканчивается...
func throw_finished():
	if anim.animation == "throw_1" or anim.animation == "throw_2":
		is_throw = false#Говорим игре, что враг не бросает снежок
		create_snowball(anim.animation)#Cоздаём снежок со стороны руки
		anim.animation = "idle"#Возвращаем врага в стандартное положение

func create_snowball(side):
	var snowball = _snowball.instance()#Создаём экземпляр снежка
	#Задём снежку свойства как снежку противника
	snowball.strength = 50
	snowball.speed = snowball_speed
	snowball.is_enemy_snowball = true
	snowball.death_Y = player_position.y
	#Задаём снежку стартовую позицию и вектор движения в зависимости от анимации
	if side == "throw_1":
		snowball.velocity = player_position - SCP_L.global_position
		snowball.global_position = SCP_L.global_position
	if side == "throw_2":
		snowball.velocity = player_position - SCP_R.global_position
		snowball.global_position = SCP_R.global_position
	#Добавляем снежок на сцену
	parent.add_child(snowball)
	t_audio.play()

#Ожидание
func wait():
	velocity = Vector2()
	anim.animation = "idle"

#Получение урона
func take_damage(damage):
	health -= damage#Отнимаем жизни в зависимости от урона
	
	#Изменяем свойства полоски здоровья
	hp_bar.value = health
	if hp_bar.visible == false:
		hp_bar.visible = true
	
	#Если у врага не осталось жизней
	if health <= 0:
		velocity = Vector2()#Обнуляем вектор
		death_timer.start()#Запускаем таймер перед уничтожение объекта
		is_alive = false#Говорим себе, что враг умер
		hp_bar.visible = false#Убираем полоску здоровья
		anim.animation = "lose"#Рисуем анимацию смерти
		parent.deduct_enemy()#Говорим сцене, что враг умер

#Уничтожаем объект по таймеру
func death_timeout():
	queue_free()

func enemy_win():
	velocity = Vector2()
	anim.animation = "win"
