extends KinematicBody2D
#Рабочие переменные
var speed = 500#Скорость снежка
var damage = 1#Урон снежка
var velocity = Vector2()#Вектор движения
var strength = 0#Сила броска
var is_enemy_snowball = false#Принадлежит ли снежок противнику
var death_Y = 0#Позиция Y на экране, после которой снежок исчезает
#Ссылки на дочерние объекты
onready var self_col = $collision#Коллайдер снежка
onready var area_col = $hit_area/area_collision#Площадь поражения снежка
onready var anim = $sprites#Графическая часть
onready var die_audio = $die_audio#Звук уничтожения снежка

func _ready():
	#Задание начальных свойств дочерним объектам
	self_col.disabled = true#Отключаем коллайдер снежка
	area_col.disabled = true#Отключаем площадь поражения
	anim.animation = "idle"#Выставляем стандартную анимацию

#Функция уничтожения снежка
func die():
	anim.animation = "die"#Выставляем анимацию уничтожения
	velocity = Vector2()#Обнуляем вектор передвижения

func _physics_process(_delta):
	#Если снежок не принадлежит противнику, то длина его полёта зависит от силы игрока
	#или пока его размер не станет слишком маленьким
	#Если снежок принадлежит противнику, то он уничтожается достигнув заданной линии
	if not is_enemy_snowball:
		if global_position.y < global.screen_size.y - global.screen_size.y/30 * strength or scale.x <= 0:
			die()
	else:
		if global_position.y > death_Y:
			die()
	#Изменяем размер снежка в зависимости от позиции на экране
	scale.x = (global.screen_size.y - (global.screen_size.y - global_position.y))/200
	scale.y = scale.x
	#Перемещаем снежок по вектору движения
	velocity = move_and_slide(velocity.normalized() * speed, Vector2.UP)

func animation_finished():
	#Если заканчивается анимация уничтожения, убираем снежок из памяти
	if anim.animation == "die":
		queue_free()

func snowball_frame_changed():
	#Если меняется кадр в анимации смерти
	if anim.animation == "die":
		#Если проигрывается первый кадр анимации смерти, то включаем площадь поражения
		#и проигрываем звук
		#На остальных кадрах площадь поражения отключена
		if anim.frame == 1:
			area_col.disabled = false
			die_audio.play()
		else:
			area_col.disabled = true

#Функция нанесения урона
func give_damage(body):
	#Если в площадь поражения попал объект, то у него выполняется функция получения урона
	if body != null:
		body.take_damage(damage)
