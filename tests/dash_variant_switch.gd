extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _check_switch(start_running: bool) -> bool:
	Input.action_release("right")
	Input.action_release("dash")
	var game: Node2D = load("res://game.tscn").instantiate()
	root.add_child(game)
	var player: CharacterBody2D = game.get_node("Player")
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	for i in 20:
		await physics_frame
	if start_running:
		Input.action_press("right")
		await physics_frame
		await physics_frame
	Input.action_press("dash")
	await physics_frame
	await physics_frame
	Input.action_release("dash")
	var first_animation: StringName = &"run_dash" if start_running else &"idle_dash"
	if sprite.animation != first_animation:
		push_error("Dash started with %s instead of %s" % [sprite.animation, first_animation])
		game.queue_free()
		return false
	for i in 8:
		await physics_frame
	var old_frame := sprite.frame
	if start_running:
		Input.action_release("right")
	else:
		Input.action_press("right")
	await physics_frame
	var expected_animation: StringName = &"idle_dash" if start_running else &"run_dash"
	var expected_frame := old_frame - 7 if start_running else old_frame + 7
	if sprite.animation != expected_animation or sprite.frame != expected_frame:
		push_error("Input changed during %s, but animation is %s frame %d (expected %s frame %d)" % [first_animation, sprite.animation, sprite.frame, expected_animation, expected_frame])
		game.queue_free()
		return false
	for i in 100:
		await physics_frame
		if sprite.animation != &"idle_dash" and sprite.animation != &"run_dash":
			var final_animation: StringName = &"idle" if start_running else &"run"
			if sprite.animation != final_animation:
				push_error("Dash ended in %s instead of %s" % [sprite.animation, final_animation])
				game.queue_free()
				return false
			game.queue_free()
			return true
	push_error("Dash did not finish after switching animation")
	game.queue_free()
	return false

func _run() -> void:
	if not await _check_switch(true) or not await _check_switch(false):
		quit(1)
		return
	Input.action_release("right")
	print("Dash animation follows running input in both directions")
	quit(0)
