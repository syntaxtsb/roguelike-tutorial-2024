extends Node2D

signal entities_focused(entity_list)


var _mouse_tile := Vector2i(-1, -1)

@onready var map: Map = get_parent()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_position: Vector2 = get_local_mouse_position()
		var tile_position: Vector2i = Grid.world_to_grid(mouse_position)
		if _mouse_tile != tile_position:
			_mouse_tile = tile_position
			var entity_names = get_names_at_location(tile_position)
			entities_focused.emit(entity_names)


func get_names_at_location(grid_position: Vector2i) -> String:
	return map.map_data.get_names_at_location(grid_position)
