extends ScrollContainer

func center_scroll_bars() -> void:
	var innerRect = $CanvasMargin.get_rect()
	var containerRect = get_rect()
	var maxX = max(0, innerRect.size.x - containerRect.size.x)
	var maxY = max(0, innerRect.size.y - containerRect.size.y)
	
	scroll_horizontal = floor(maxX / 2)
	scroll_vertical = floor(maxY / 2)

func _ready() -> void:
	call_deferred("center_scroll_bars")
