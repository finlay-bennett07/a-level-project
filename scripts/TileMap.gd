extends TileMap

func _ready():
	for tile in get_used_cells(1):
		if get_cell_atlas_coords(1, tile) != Vector2i(3, 3):
			match randi_range(0, 12):
				0:
					set_cell(1, tile, 0, Vector2(3, 0))
				1:
					set_cell(1, tile, 0, Vector2(3, 1))
				_:
					set_cell(1, tile, 0, Vector2(3, 2))
