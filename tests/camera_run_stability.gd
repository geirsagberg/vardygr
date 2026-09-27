extends SceneTree

# Run with --fixed-fps 30 to catch camera-target overshoot during a steady run.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game: Node2D = load("res://game.tscn").instantiate()
	root.add_child(game)
	var player: CharacterBody2D = game.get_node("Player")
	var camera_target: Marker2D = game.get_node("CameraTarget")
	Input.action_press("right")
	for i in 80:
		await physics_frame
		await process_frame
	if camera_target.get("target_offset_x") != 96:
		push_error("Running input did not set the camera target")
		quit(1)
		return
	var minimum := camera_target.position.x - player.position.x
	var maximum := minimum
	for i in 12:
		await physics_frame
		await process_frame
		var offset_x := camera_target.position.x - player.position.x
		minimum = minf(minimum, offset_x)
		maximum = maxf(maximum, offset_x)
	Input.action_release("right")
	if maximum - minimum > 0.5:
		push_error("Camera target jitters %.2f px during a steady run" % (maximum - minimum))
		quit(1)
		return
	print("Camera target stays still during a steady run")
	quit(0)
