extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _visible_character_x(player: CharacterBody2D, sprite: AnimatedSprite2D) -> float:
	# Track the dark character pixels, ignoring the white dash trail.
	var texture := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var image := texture.get_image()
	var left := image.get_width()
	var right := -1
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a > 0.5 and color.r < 0.5 and color.g < 0.5 and color.b < 0.5:
				left = mini(left, x)
				right = maxi(right, x)
	if right < left:
		return NAN
	var local_x := (left + right) / 2.0 - image.get_width() / 2.0
	return player.global_position.x + sprite.position.x + sprite.offset.x + local_x * (-1.0 if sprite.flip_h else 1.0)

func _check_dash(player: CharacterBody2D, sprite: AnimatedSprite2D, direction: StringName, dash_animation: StringName, last_frame: int, expect_full_move: bool = true) -> bool:
	Input.action_release("left")
	Input.action_release("right")
	if direction != &"":
		Input.action_press(direction)
	for i in 4:
		await physics_frame
	var start_x := player.global_position.x
	Input.action_press("dash")
	await physics_frame
	Input.action_release("dash")
	var dash_end_x := NAN
	for i in 150:
		await physics_frame
		if sprite.animation == dash_animation and sprite.frame == last_frame:
			dash_end_x = _visible_character_x(player, sprite)
		if not is_nan(dash_end_x) and sprite.animation != dash_animation:
			var snap := _visible_character_x(player, sprite) - dash_end_x
			if absf(snap) > 8.0:
				push_error("%s snaps %.1f px after dash" % [dash_animation, snap])
				return false
			if direction == &"" and expect_full_move and absf(player.global_position.x - start_x) < 80.0:
				push_error("Idle dash did not move the player body")
				return false
			return true
	push_error("%s did not finish in time" % dash_animation)
	return false

func _run() -> void:
	var game: Node2D = load("res://game.tscn").instantiate()
	root.add_child(game)
	var player: CharacterBody2D = game.get_node("Player")
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	for i in 20:
		await physics_frame
	if not player.is_on_floor():
		push_error("Player did not reach the floor")
		quit(1)
		return
	if not await _check_dash(player, sprite, &"", &"idle_dash", 7):
		quit(1)
		return
	if not await _check_dash(player, sprite, &"right", &"run_dash", 15):
		quit(1)
		return
	if not await _check_dash(player, sprite, &"left", &"run_dash", 15):
		quit(1)
		return
	Input.action_release("left")
	Input.action_press("right")
	for i in 2:
		await physics_frame
	Input.action_release("right")
	var wall := StaticBody2D.new()
	wall.position = Vector2(player.position.x + 50.0, player.position.y - 16.0)
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(8, 100)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	game.add_child(wall)
	await physics_frame
	if not await _check_dash(player, sprite, &"", &"idle_dash", 7, false):
		quit(1)
		return
	if player.global_position.x >= wall.global_position.x - 5.0:
		push_error("Dash crossed the wall: player=%.1f wall=%.1f" % [player.global_position.x, wall.global_position.x])
		quit(1)
		return
	print("Dash keeps the character in place after each animation")
	quit(0)
