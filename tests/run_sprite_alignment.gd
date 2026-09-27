extends SceneTree

# The bright front edge of the runner's head must stay in one screen column.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game: Node2D = load("res://game.tscn").instantiate()
	root.add_child(game)
	var sprite: AnimatedSprite2D = game.get_node("Player/AnimatedSprite2D")
	Input.action_press("right")
	for i in 80:
		await physics_frame
		await process_frame
	var transform := sprite.get_global_transform_with_canvas()
	var top := transform * Vector2(2.5, -15.5)
	var bottom := transform * Vector2(2.5, -11.5)
	Input.action_release("right")
	if absf(top.x - bottom.x) > 0.001:
		push_error("Run sprite's bright head edge tilts %.4f pixels across four rows" % absf(top.x - bottom.x))
		quit(1)
		return
	print("Run sprite's head edge stays in one screen column")
	quit(0)
