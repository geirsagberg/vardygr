extends Marker2D

var target_offset_x = 0

const SPEED = 200

func _process(delta: float) -> void:
	if position.x != target_offset_x:
		if abs(position.x - target_offset_x) < 1.0:
			position.x = target_offset_x
		elif position.x < target_offset_x:
			position.x += delta * SPEED
		else:
			position.x -= delta * SPEED
			
