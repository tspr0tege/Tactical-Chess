extends Camera2D

func _ready():
	_on_sub_viewport_container_item_rect_changed()

func _on_sub_viewport_container_item_rect_changed():
	var viewportRatio = get_viewport_rect().size / Vector2(512, 320)
	var minAxis = viewportRatio.min_axis_index()
	#print(str(minAxis))
	self.zoom = Vector2(viewportRatio[minAxis], viewportRatio[minAxis])
