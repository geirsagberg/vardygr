extends Marker2D

@onready var player: CharacterBody2D = $"../Player"

var target_offset_x := 0.0
var _offset_x := 0.0

const SPEED := 200.0

func _ready() -> void:
	global_position = player.global_position
	reset_physics_interpolation()

func _physics_process(delta: float) -> void:
	_offset_x = move_toward(_offset_x, target_offset_x, SPEED * delta)
	global_position = player.global_position + Vector2(_offset_x, 0)
