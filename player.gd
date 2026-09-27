extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var camera_target = $"../CameraTarget"

enum {IDLE, RUNNING, JUMPING, FALLING, DASHING}
enum {NO_ATTACK, LIGHT_ATTACK_1, LIGHT_ATTACK_2}
var queued_attack = false
var dash_active = false
var dash_moved = false
var dash_direction = 1

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
# Horizontal shifts baked into the final dash frames of dark-hollow.png.
const IDLE_DASH_DISTANCE = 108.0
const RUN_DASH_DISTANCE = 120.0

func _ready() -> void:
	animation_controller = AnimationController.new(sprite)
	state_changed.connect(_on_state_changed)
	animation_controller.attack_finished.connect(_on_attack_finished)
	animation_controller.attack_can_combo.connect(_on_attack_can_combo)
	animation_controller.dash_finished.connect(_on_dash_finished)
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	var attack = Input.is_action_just_pressed("attack")
	var dash = Input.is_action_just_pressed("dash")
	if dash_active and (jump or attack or not is_on_floor()):
		dash_active = false
	
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

	if dash and not jump and is_on_floor() and combat == NO_ATTACK and not dash_active:
		dash_active = true
		dash_moved = false
		dash_direction = -1 if sprite.flip_h else 1
		
	# Set movement
	prev_movement = movement
	if dash_active:
		movement = DASHING
	elif !is_on_floor():
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

	if dash_active:
		animation_controller.update_dash_animation(velocity.x != 0)
		var run_dash = sprite.animation == &"run_dash"
		var move_frame = 8 if run_dash else 1
		var distance = RUN_DASH_DISTANCE if run_dash else IDLE_DASH_DISTANCE
		# Move the collision body where the sheet draws the character, then cancel the sheet's offset.
		if not dash_moved and sprite.frame >= move_frame:
			move_and_collide(Vector2(distance * dash_direction, 0))
			reset_physics_interpolation()
			dash_moved = true
		if dash_moved:
			sprite.offset.x = distance if sprite.flip_h else -distance

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

func _on_dash_finished():
	dash_active = false

func _on_state_changed(movement_state: int, combat_state: int, prev_movement_state: int, prev_combat_state: int):
	if prev_movement_state == DASHING and movement_state != DASHING:
		sprite.offset.x = 0
	animation_controller.handle_state_change(movement_state, combat_state, prev_movement_state, prev_combat_state, velocity.x != 0)
