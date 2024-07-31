class_name FieldOfView
extends Node

var _fov: Array[Tile] = []

func update_fov(map_data: MapData, origin: Vector2i, radius: int) -> void:
	clear_fov()
	var start_tile: Tile = map_data.get_tile(origin)
	start_tile.is_in_view = true
	_fov = [start_tile]
	compute_fov(map_data, origin, radius)


func mark_visible(map_data: MapData, tile: Vector2i) -> void:
	var visible_tile: Tile = map_data.get_tile(tile)
	visible_tile.is_in_view = true
	_fov.append(visible_tile)


func is_blocking(map_data: MapData, tile: Vector2i) -> bool:
	return not map_data.get_tile(tile).is_transparent()


func clear_fov() -> void:
	for tile in _fov:
		tile.is_in_view = false
	_fov.clear()


func compute_fov(map_data: MapData, origin: Vector2i, radius: int = INF):
	mark_visible(map_data, origin)

	for i in range(Cardinal.keys().size()):
		var quadrant = Quadrant.new(i, origin)
		
		var reveal = func(tile: Vector2i) -> void:
			mark_visible(map_data, quadrant.transform(tile))

		var is_wall = func(tile: Vector2i) -> bool:
			if tile == Vector2i.MIN:
				return false
			else:
				return is_blocking(map_data, quadrant.transform(tile))

		var is_floor = func(tile: Vector2i) -> bool:
			if tile == Vector2i.MIN:
				return false
			else:
				return not is_blocking(map_data, quadrant.transform(tile))

		var is_in_radius = func(tile: Vector2i, radius: int) -> bool:
			return tile.length() <= absi(radius)

		var scan = func(row: Row, limit: int) -> void:
			var rows: Array[Row] = [row]
			while not rows.is_empty():
				var current_row = rows.pop_back()
				var prev_tile: Vector2i = Vector2i.MIN
				for tile in current_row.tiles():
					if is_in_radius.call(tile, limit):
						if is_wall.call(tile) or FieldOfView.is_symmetric(current_row, tile):
							reveal.call(tile)
						if is_wall.call(prev_tile) and is_floor.call(tile):
							current_row.start_slope = FieldOfView.slope(tile)
						if is_floor.call(prev_tile) and is_wall.call(tile):
							var next_row = current_row.next()
							next_row.end_slope = FieldOfView.slope(tile)
							rows.push_back(next_row)
						prev_tile = tile
				if is_floor.call(prev_tile):
					rows.push_back(current_row.next())

		var first_row = Row.new(1, Rational.new(-1), Rational.new(1))
		scan.call(first_row, radius)


enum Cardinal { NORTH, EAST, SOUTH, WEST }

class Quadrant:

	var _cardinal: Cardinal
	var _origin: Vector2i

	func _init(cardinal: Cardinal, origin: Vector2i) -> void:
		_cardinal = cardinal
		_origin = origin


	func transform(tile: Vector2i) -> Vector2i:
		match(_cardinal):
			Cardinal.NORTH:
				return Vector2i(_origin.x + tile.y, _origin.y - tile.x)
			Cardinal.SOUTH:
				return Vector2i(_origin.x + tile.y, _origin.y + tile.x)
			Cardinal.EAST:
				return Vector2i(_origin.x + tile.x, _origin.y + tile.y)
			Cardinal.WEST, _:
				return Vector2i(_origin.x - tile.x, _origin.y + tile.y)


# A Row represents a segment of tiles bound between a start and end slope. depth
# represents the distance between the row and the quadrant’s origin. 
class Row:
	
	var depth: int
	var start_slope: Rational
	var end_slope: Rational

	func _init(d: int, start: Rational, end: Rational) -> void:
		self.depth = d
		self.start_slope = start
		self.end_slope = end

	# tiles returns an array of the tiles in the row. This function
	# considers a tile to be in the row if the sector swept out by the row’s
	# start and end slopes overlaps with a diamond inscribed in the tile. If the
	# diamond is only tangent to the sector, it does not become part of the row. 
	func tiles() -> Array:
		var min_col: int = FieldOfView.round_ties_up(
				Rational.new(self.depth).multiply(self.start_slope))
		var max_col: int = FieldOfView.round_ties_down(
				Rational.new(self.depth).multiply(self.end_slope))
		return range(min_col, max_col + 1).map(func(col: int) -> Vector2i: 
			return Vector2i(self.depth, col))


	func next() -> Row:
		return Row.new(
			self.depth + 1,
			self.start_slope,
			self.end_slope)


# slope calculates new start and end slopes. It’s used in two situations: [1],
# if prev_tile (on the left) was a wall tile and tile (on the right) is a floor
# tile, then the slope represents a start slope and should be tangent to the
# right edge of the wall tile. [2], if prev_tile was a floor tile and tile is a
# wall tile, then the slope represents an end slope and should be tangent to the
# left edge of the wall tile.
#
# In both situations, the line is tangent to the left edge of the current tile,
# so we can use a single slope function for both start and end slopes. 
static func slope(tile: Vector2i) -> Rational:
	var row_depth: int = tile.x
	var col: int = tile.y
	return Rational.new(2 * col - 1, 2 * row_depth)


# is_symmetric checks if a given floor tile can be seen symmetrically from the
# origin. It returns true if the central point of the tile is in the sector
# swept out by the row’s start and end slopes. Otherwise, it returns false. 
static func is_symmetric(row: Row, tile: Vector2i) -> bool:
	var row_depth: Rational = Rational.new(tile.x)
	var col: Rational = Rational.new(tile.y)
	return (col.is_gt_eq(row_depth.multiply(row.start_slope))
		and col.is_lt_eq(row_depth.multiply(row.end_slope)))


static func round_ties_up(n: Rational) -> int:
	return n.add(Rational.new(1, 2)).floor().to_int()


static func round_ties_down(n: Rational) -> int:
	return n.subtract(Rational.new(1, 2)).ceil().to_int()
