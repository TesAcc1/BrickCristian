extends CharacterBody2D

const SPEED = 1000.0

var touch_direction := 0.0  # dirección recibida por touch

func _input(event: InputEvent) -> void:
	# Detectar toque en pantalla (Android)
	if event is InputEventScreenTouch:
		if not event.pressed:
			touch_direction = 0.0  # dedo levantado, detener

	if event is InputEventScreenDrag:
		# Mover según posición del dedo respecto a la paleta
		var diff = event.position.x - global_position.x
		touch_direction = clamp(diff / 10.0, -1.0, 1.0)

func _physics_process(_delta: float) -> void:
	# Teclado / gamepad
	var keyboard_direction := Input.get_axis("ui_left", "ui_right")

	# Priorizar teclado si se usa, si no usar touch
	var direction := keyboard_direction if keyboard_direction != 0.0 else touch_direction

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
