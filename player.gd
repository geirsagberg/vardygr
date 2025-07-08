extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

const RUN_SPEED = 100
const GRAVITY = 1000
const JUMP_SPEED = -250

func _ready() -> void:
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity.x = 0
	
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	
	if Input.is_action_just_released("right") || Input.is_action_just_released("left"):
		sprite.play("idle")
		velocity.x = 0
		
	if right:
		sprite.flip_h = false
		velocity.x = RUN_SPEED
		camera.position.x = 64
	
	if left:
		sprite.flip_h = true
		velocity.x = -RUN_SPEED
		camera.position.x = -64
		
	if is_on_floor():
		if right || left:
			sprite.play("run")
		else:
			sprite.play("idle")
		
	if jump:
		velocity.y = JUMP_SPEED
		sprite.play("jump")
	
	if get_last_motion().y > 0:
		sprite.play("land")
		
	move_and_slide()
	
	
