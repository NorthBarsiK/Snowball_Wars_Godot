extends KinematicBody2D
#Характеристики игрока
export var movement_speed = 25#Скорость передвижения
export var max_health = 6#Максимум жизней
export var max_snowballs = 5#Максимум снежков
#Рабочие переменные
var health#Текущее количество жизней
var snowballs#Текущее количество снежков
var strength = 0#Уровень силы броска
var max_strength = 30#Максимальный уровень силы броска
var velocity = Vector2()#Вектор передвижения
var is_left_hand = true#Переменная выбора руки броска
var is_throw = false#Переменная броска снежка
var is_prepare_throw = false#Переменная подготовки к броску
var add_strength = true#Переменная изменения уровня силы
var snowball_path = load("res://Scenes/snowball.tscn")#Путь к сцене снежка
#ссылки на дочерние элементы
onready var parent = get_parent()#Родительский узел
onready var anim = $player_sprites#Графическая часть
onready var S_bar = $strength_bar#Полоска силы
onready var SCP_L = $snowball_create_point_1#Левая точка создания снежка
onready var SCP_R = $snowball_create_point_2#Правая точка создания снежка
onready var SDP_L = $snowball_direction_point_1#Левая точка направления снежка
onready var SDP_R = $snowball_direction_point_2#Правая точка направления снежка
onready var t_audio = $throw_audio
#Обработка ввода
func get_input():
	velocity.x = 0#Обнуляем X вектора передвижения
	
	var left = Input.is_action_pressed("move_left")#Проверяем нажата ли клавиша влево
	var right = Input.is_action_pressed("move_right")#Проверяем нажата ли клавиша вправо
	var prepare_throw = Input.is_action_pressed("throw")#Проверяем нажата ли клавиша броска
	var throw = Input.is_action_just_released("throw")#Проверяем отпущена ли клавиша броска
		
	if snowballs > 0:
		#Если клавиша броска нажата, то прибавляем силу, когда отпускаем запускаем снежок
		if prepare_throw:
			is_prepare_throw = true
			strength_addiction()
		if throw:
			is_prepare_throw = false
			is_throw = true
			add_strength = true
	#Если не бросаем снежок и не готовимся к броску, то можем двигаться
	if not is_throw and not is_prepare_throw:
		if left:
			velocity.x = -movement_speed
		if right:
			velocity.x = movement_speed
#Анимация игрока
func animation():
	S_bar.value = strength#Передаём значение силы на полоску силы
	#Если готовимся к броску или бросаем, проигрываем анимацию бросков, 
	#иначе проигрываем анимацию передвижения
	if is_prepare_throw or is_throw:
		#Если удерживаем кнопку броска, проигрываем анимацию подготовки
		if is_prepare_throw:
			#Если бросок левой руки, то проигрываем анимацию с левой руки, 
			#иначе проигрываем анимацию правой руки
			if is_left_hand:
				anim.animation = "prepare_throw_1"
			else:
				anim.animation = "prepare_throw_2"
		#Если отпускаем кнопку броска, проигрываем анимацию броска
		if is_throw:
			#Если бросок левой руки, то проигрываем анимацию с левой руки, 
			#иначе проигрываем анимацию правой руки
			if is_left_hand:
				anim.animation = "throw_1"
			else:
				anim.animation = "throw_2"
	else:
		#Если Х вектора передвижения меньше нуля, то проигрываем анимацию движения влево
		#Если Х вектора передвижения больше нуля, то проигрываем анимацию движения вправо
		#Если Х вектора передвижения равен нулю, то проигрываем анимацию стойки
		if velocity.x < 0:
			anim.animation = "run_L"
		elif velocity.x > 0:
			anim.animation = "run_R"
		else:
			anim.animation = "idle"

func _ready():
	health = max_health#Задаём текущему здоровью значение максимального здоровья
	snowballs = max_snowballs#Задаем текущему количеству снежков максимум
	#Отправляем данные о здоровье и снежках игрока сцене
	parent.send_player_health(health)
	parent.send_player_max_health(max_health)
	parent.send_player_snowballs(snowballs)
	#Прячем полоску силы
	S_bar.visible = false
	#Задаём начальную позицию и размер игрока
	position.x = global.screen_size.x/2
	position.y = global.screen_size.y - 16*scale.x
	scale.x = (global.screen_size.y - (global.screen_size.y - global_position.y))/200
	scale.y = scale.x
	position.y = global.screen_size.y - 16*scale.x
	
	movement_speed *= scale.x#Умножаем скорость на размер игрока

func _physics_process(_delta):
	#Получаем от сцены информацию о выйграше или проигрыше
	var win = parent.is_win
	var lose = parent.is_lose
	
	#Если игра не закончилась, запускаем рабочие функции и перемещаем игрока
	if not win and not lose:
		get_input()
		animation()
		send_position()
		check_limits()
		refill_snowballs()
		velocity = move_and_slide(velocity, Vector2.UP)
	#Задаём анимацию в зависимости от исхода игры
	if win:
		anim.animation = "win"
	if lose:
		anim.animation = "lose"

func animation_finished():
	#Если заканчивается анимация, то создаём снежок в зависимости от стороны броска
	if anim.animation == "throw_1" or anim.animation == "throw_2":
		create_snowball(is_left_hand)
		is_throw = false#Говорим игре, что игрок закончил бросок
		S_bar.visible = false#Прячем полоску силы
		#Меняем руку после броска
		if is_left_hand:
			is_left_hand = false
		else:
			is_left_hand = true
#Функция отправки игре позиции игрока
func send_position():
	parent.set_player_position(global_position)
#Функция создания снежка
func create_snowball(side):
	var snowball = snowball_path.instance()#Создаём экземпляр снежка
	snowball.strength = strength#Задаём снежку силу
	var create_point#Временная переменная точки создания снежка
	var direction_point#Временная переменная точки направления снежка
	#В зависимости от стороны броска получаем точку создания и направления снежка
	if side:
		create_point = SCP_L.global_position
		direction_point = SDP_L.global_position
	else:
		create_point = SCP_R.global_position
		direction_point = SDP_R.global_position
	snowball.velocity = direction_point - create_point#Задаём снежку вектор передвижения
	snowball.global_position = create_point#Задаём снежку начальную позицию
	snowball.is_enemy_snowball = false#Говорим игре, что снежок кинул игрок
	parent.add_child(snowball)#Добавляем снежок на сцену
	t_audio.play()
	strength = 0#Обнуляем силу
	
	snowballs -= 1
	parent.send_player_snowballs(snowballs)
#Функция прибавления силы
func strength_addiction():
	S_bar.visible = true#Показываем полоску силы
	#Если уровень силы меньше максимального, то прибавляем силу
	#Если уровень силы больше максимально, то начинаем убавлять
	if add_strength:
		strength += 1
		if strength >= max_strength:
			add_strength = false
	else:
		strength -= 1
		if strength <= 0:
			add_strength = true
#Функция получения урона
func take_damage(damage):
	if not parent.is_win:
		health -= damage#Убавляем от количества здоровья количество урона
	
	parent.send_player_health(health)#Отправляем сцене данные о здоровье игрока
	#Если здоровья меньше нуля, то говорим игре, что игрок проиграл
	if health <= 0:
		parent.player_die()
#Функция ограничения движения игрока
func check_limits():
	var pos = global_position#Получаем позицию игрока
	if pos.x >= global.screen_size.x - scale.x*16 and velocity.x > 0:#Ограничиваем движение вправо
		velocity.x = 0
	if pos.x <= global.screen_size.x - (global.screen_size.x - scale.x*16) and velocity.x < 0:#Ограничиваем движение влево
		velocity.x = 0

func refill_snowballs():
	if parent.snowballs_refill():
		snowballs = max_snowballs
		parent.send_player_snowballs(snowballs)
