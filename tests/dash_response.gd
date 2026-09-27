extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game: Node2D = load("res://game.tscn").instantiate()
	root.add_child(game)
	var player: CharacterBody2D = game.get_node("Player")
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	var camera: Camera2D = game.get_node("CameraTarget/Camera2D")
	for i in 20:
		await physics_frame
	Input.action_press("right")
	for i in 20:
		await physics_frame
		await process_frame
	var last_player_x := player.global_position.x
	var last_camera_x := camera.get_screen_center_position().x
	var move_tick := -1
	var largest_camera_step := 0.0
	Input.action_press("dash")
	for i in 100:
		await physics_frame
		await process_frame
		var player_x := player.global_position.x
		var camera_x := camera.get_screen_center_position().x
		if move_tick < 0 and absf(player_x - last_player_x) > 60.0:
			move_tick = i + 1
		largest_camera_step = maxf(largest_camera_step, absf(camera_x - last_camera_x))
		last_player_x = player_x
		last_camera_x = camera_x
	Input.action_release("dash")
	Input.action_release("right")
	if move_tick < 1 or move_tick > 3:
		push_error("Running dash moved on physics tick %d, expected within 3" % move_tick)
		quit(1)
		return
	if largest_camera_step >= 40.0:
		push_error("Camera jumped %.1f px in one step" % largest_camera_step)
		quit(1)
		return
	for i in 4:
		await physics_frame
	var standing_start_x := player.global_position.x
	Input.action_press("dash")
	for i in 4:
		await physics_frame
		await process_frame
	Input.action_release("dash")
	if player.global_position.x - standing_start_x < 80.0 or sprite.animation != &"idle_dash":
		push_error("Standing dash did not move immediately with its animation")
		quit(1)
		return
	if not is_equal_approx(sprite.offset.x, -108.0):
		push_error("Unswitched standing dash offset changed to %.1f px" % sprite.offset.x)
		quit(1)
		return
	print("Dash responds immediately and camera glides")
	quit(0)
