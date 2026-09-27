extends SceneTree

# Rendered-only check for the current 288x156 game viewport and run sprite.
# Run with Godot --path . --script res://tests/run_render_stability.gd \
#   --write-movie /tmp/vardygr-run.avi --fixed-fps 144
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Run render stability requires a graphics renderer")
		quit(1)
		return
	var game: Node2D = load("res://game.tscn").instantiate()
	root.add_child(game)
	Input.action_press("right")
	for i in 120:
		await RenderingServer.frame_post_draw
	var columns := {}
	for i in 120:
		await RenderingServer.frame_post_draw
		var image: Image = root.get_texture().get_image()
		if image == null:
			push_error("Run render stability needs a graphics renderer and --write-movie")
			quit(1)
			return
		var eye_right := -1
		for y in range(90, 132):
			for x in range(25, 100):
				var color := image.get_pixel(x, y)
				if color.r > 0.96 and color.g > 0.96 and color.b > 0.96:
					eye_right = maxi(eye_right, x)
		columns[eye_right] = true
	Input.action_release("right")
	if columns.size() != 1 or columns.has(-1):
		push_error("Rendered run eye shifts horizontally: %s" % [columns.keys()])
		quit(1)
		return
	print("Rendered run eye stays in column ", columns.keys()[0])
	quit(0)
