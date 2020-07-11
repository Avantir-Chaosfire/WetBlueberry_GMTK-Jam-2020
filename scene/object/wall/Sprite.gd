extends Sprite

func _ready():
	var parentScale = get_parent().scale
	region_rect.size = Vector2(region_rect.size.x * parentScale.x, region_rect.size.y * parentScale.y)
	scale = Vector2(1 / parentScale.x, 1 / parentScale.y)
