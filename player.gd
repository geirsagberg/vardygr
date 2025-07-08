extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var camera_target = $CameraTarget

enum { IDLE, RUNNING, JUMPING, FALLING }
enum { NO_ATTACK, ATTACK_1, ATTACK_2, JUMP_ATTACK, RUN_ATTACK_1 }
var queued_attack = false

var movement = IDLE
var combat = NO_ATTACK

const RUN_SPEED = 120
const GRAVITY = 1000
const JUMP_SPEED = -250
const CAMERA_OFFSET = 96

func _ready() -> void:
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	var attack = Input.is_action_just_pressed("attack")
	var was_moving = velocity.x != 0
	
	# Set velocity from input
	velocity.x = 0
	
	# Set combat state
	if attack:
		match combat:
			NO_ATTACK:
				match movement:
					IDLE:
						combat = ATTACK_1
						sprite.play("idle_attack_1")
					JUMPING, FALLING:
						combat = JUMP_ATTACK
						sprite.play("jump_attack_1")
					RUNNING:
						combat = RUN_ATTACK_1
						sprite.play("run_attack_1")
			ATTACK_1:
				queued_attack = true
	
	if combat != ATTACK_1 && combat != ATTACK_2:
		if right:
			velocity.x += RUN_SPEED
		
		if left:
			velocity.x -= RUN_SPEED
			
		if jump:
			velocity.y = JUMP_SPEED
		
		
	# Update sprite and camera
	if velocity.x > 0:
		sprite.flip_h = false
		camera_target.target_offset_x = CAMERA_OFFSET
	elif velocity.x < 0:
		sprite.flip_h = true
		camera_target.target_offset_x = -CAMERA_OFFSET
		
	# Set movement
	if !is_on_floor():
		if velocity.y < 0:
			movement = JUMPING
		else:
			movement = FALLING
	elif velocity.x != 0:
		movement = RUNNING
	else:
		movement = IDLE
		
	# Set animation
	if combat == NO_ATTACK:
		match movement:
			JUMPING: sprite.play("jump")
			FALLING: sprite.play("fall")
			RUNNING: sprite.play("run")
			_: sprite.play("idle")
	elif combat == RUN_ATTACK_1 && was_moving && movement == IDLE:
		var frame = sprite.frame
		sprite.animation = "jump_attack_1"
		sprite.frame = frame
		
	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	match sprite.animation:
		"idle_attack_1":
			if queued_attack:
				combat = ATTACK_2
				sprite.play("idle_attack_2")
				queued_attack = false
			else:
				combat = NO_ATTACK
		"idle_attack_2":
			combat = NO_ATTACK
		"run_attack_1":
			combat = NO_ATTACK
		"jump_attack_1":
			combat = NO_ATTACK
			
