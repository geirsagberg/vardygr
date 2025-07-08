class_name AnimationController
extends RefCounted

enum MovementState { IDLE, RUNNING, JUMPING, FALLING }
enum CombatState { NO_ATTACK, LIGHT_ATTACK_1, LIGHT_ATTACK_2 }

signal attack_finished
signal attack_can_combo

var sprite: AnimatedSprite2D

func _init(animated_sprite: AnimatedSprite2D):
	sprite = animated_sprite
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)

func handle_state_change(movement_state: MovementState, combat_state: CombatState, prev_movement: MovementState, prev_combat: CombatState):
	if combat_state != prev_combat:
		if combat_state == CombatState.NO_ATTACK:
			_handle_movement_animation(movement_state)
		else:
			_handle_combat_state_change(movement_state, combat_state, prev_combat)
	elif movement_state != prev_movement and combat_state != CombatState.NO_ATTACK:
		_handle_movement_during_combat(movement_state, combat_state, prev_movement)
	elif combat_state == CombatState.NO_ATTACK and movement_state != prev_movement:
		_handle_movement_animation(movement_state)

func _handle_combat_state_change(movement_state: MovementState, combat_state: CombatState, prev_combat: CombatState):
	match combat_state:
		CombatState.LIGHT_ATTACK_1:
			if movement_state == MovementState.RUNNING:
				sprite.play("run_light_attack_1")
			else:
				sprite.play("light_attack_1")
		CombatState.LIGHT_ATTACK_2:
			if movement_state == MovementState.RUNNING:
				sprite.play("run_light_attack_2")
			else:
				sprite.play("light_attack_2")

func _handle_movement_during_combat(movement_state: MovementState, combat_state: CombatState, prev_movement: MovementState):
	var frame = sprite.frame
	
	if (prev_movement == MovementState.JUMPING or prev_movement == MovementState.FALLING) and movement_state == MovementState.RUNNING:
		match sprite.animation:
			"light_attack_1":
				sprite.animation = "run_light_attack_1"
			"light_attack_2":
				sprite.animation = "run_light_attack_2"
		sprite.frame = frame
	elif prev_movement == MovementState.RUNNING and (movement_state == MovementState.JUMPING or movement_state == MovementState.IDLE):
		sprite.animation = sprite.animation.replace("run_", "")
		sprite.frame = frame

func _handle_movement_animation(movement_state: MovementState):
	match movement_state:
		MovementState.JUMPING:
			sprite.play("jump")
		MovementState.FALLING:
			sprite.play("fall")
		MovementState.RUNNING:
			sprite.play("run")
		MovementState.IDLE:
			sprite.play("idle")

func _on_animation_finished():
	match sprite.animation:
		"light_attack_1", "run_light_attack_1", "light_attack_2", "run_light_attack_2":
			attack_finished.emit()

func _on_frame_changed():
	if sprite.frame > 1:
		match sprite.animation:
			"light_attack_1", "run_light_attack_1":
				attack_can_combo.emit()