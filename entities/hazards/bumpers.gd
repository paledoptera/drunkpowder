extends NinePatchRect

func _ready() -> void:
	animation_loop()
	var rect = RectangleShape2D.new()
	rect.size = size
	$StaticBody2D/CollisionShape2D.shape = rect
	$StaticBody2D/CollisionShape2D.position = size/2

func animation_loop():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GREEN_YELLOW ,0.8)
	await tween.finished
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE ,0.8)
	await tween.finished
	animation_loop()
