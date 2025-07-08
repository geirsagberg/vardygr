extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var camera_target = $CameraTarget

enum { IDLE, RUNNING, JUMPING, FALLING }
enum { NO_ATTACK, LIGHT_ATTACK_1, LIGHT_ATTACK_2 }
var queued_attack = false

var movement = IDLE
var combat = NO_ATTACK

const RUN_SPEED = 120
const GRAVITY = 1000
const JUMP_SPEED = -300
const CAMERA_OFFSET = 96

func _ready() -> void:
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	var attack = Input.is_action_just_pressed("attack")
	
	# Set velocity from input
	velocity.x = 0
	
	# Set combat state
	if attack:
		match combat:
			NO_ATTACK:
				match movement:
					IDLE, JUMPING, FALLING:
						combat = LIGHT_ATTACK_1
						sprite.play("light_attack_1")
					RUNNING:
						combat = LIGHT_ATTACK_1
						sprite.play("run_light_attack_1")
			LIGHT_ATTACK_1:
				if sprite.frame > 1:
					match movement:
						IDLE, JUMPING, FALLING:
							combat = LIGHT_ATTACK_2
							sprite.play("light_attack_2")
						RUNNING:
							combat = LIGHT_ATTACK_2
							sprite.play("run_light_attack_2")
				else:
					queued_attack = true
	
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
	var prev_movement = movement
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
	elif (prev_movement == JUMPING || prev_movement == FALLING) && movement == RUNNING:
		var frame = sprite.frame
		match sprite.animation:
			"light_attack_1":
				sprite.animation = "run_light_attack_1"
			"light_attack_2":
				sprite.animation = "run_light_attack_2"
		sprite.frame = frame
	elif prev_movement == RUNNING && (movement == JUMPING || movement == IDLE):
		var frame = sprite.frame
		sprite.animation = sprite.animation.replace("run_", "")
		sprite.frame = frame
		
	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	match sprite.animation:
		"light_attack_1":
			if queued_attack:
				combat = LIGHT_ATTACK_2
				sprite.play("light_attack_2")
				queued_attack = false
			else:
				combat = NO_ATTACK
		"light_attack_2":
			combat = NO_ATTACK
		"run_light_attack_1":
			if queued_attack:
				combat = LIGHT_ATTACK_2
				sprite.play("run_light_attack_2")
				queued_attack = false
			else:
				combat = NO_ATTACK
		"run_light_attack_2":
			combat = NO_ATTACK


func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.frame > 1 && queued_attack:
		queued_attack = false
		match sprite.animation:
			"light_attack_1":
				combat = LIGHT_ATTACK_2
				sprite.play("light_attack_2")
			"run_light_attack_1":
				combat = LIGHT_ATTACK_2
				sprite.play("run_light_attack_2")
	
	
