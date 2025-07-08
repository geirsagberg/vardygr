extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var camera_target = $CameraTarget

enum {IDLE, RUNNING, JUMPING, FALLING}
enum {NO_ATTACK, LIGHT_ATTACK_1, LIGHT_ATTACK_2}
var queued_attack = false

var movement = IDLE
var combat = NO_ATTACK
var prev_movement = IDLE
var prev_combat = NO_ATTACK

var animation_controller: AnimationController

signal state_changed(movement_state: int, combat_state: int, prev_movement_state: int, prev_combat_state: int)

const RUN_SPEED = 120
const GRAVITY = 1000
const JUMP_SPEED = -300
const CAMERA_OFFSET = 96

func _ready() -> void:
	animation_controller = AnimationController.new(sprite)
	state_changed.connect(_on_state_changed)
	animation_controller.attack_finished.connect(_on_attack_finished)
	animation_controller.attack_can_combo.connect(_on_attack_can_combo)
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
				combat = LIGHT_ATTACK_1
			LIGHT_ATTACK_1:
				if sprite.frame > 1:
					combat = LIGHT_ATTACK_2
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
		camera_target.target_offset_x = - CAMERA_OFFSET
		
	# Set movement
	prev_movement = movement
	if !is_on_floor():
		if velocity.y < 0:
			movement = JUMPING
		else:
			movement = FALLING
	elif velocity.x != 0:
		movement = RUNNING
	else:
		movement = IDLE
	
	# Emit state change signal if states changed
	if movement != prev_movement or combat != prev_combat:
		state_changed.emit(movement, combat, prev_movement, prev_combat)
		prev_combat = combat
		
	move_and_slide()

func _on_attack_finished():
	match combat:
		LIGHT_ATTACK_1:
			if queued_attack:
				combat = LIGHT_ATTACK_2
				queued_attack = false
			else:
				combat = NO_ATTACK
		LIGHT_ATTACK_2:
			combat = NO_ATTACK

func _on_attack_can_combo():
	if queued_attack:
		queued_attack = false
		combat = LIGHT_ATTACK_2

func _on_state_changed(movement_state: int, combat_state: int, prev_movement_state: int, prev_combat_state: int):
	animation_controller.handle_state_change(movement_state, combat_state, prev_movement_state, prev_combat_state)
