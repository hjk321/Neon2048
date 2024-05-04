extends Node2D

const TILE_SIZE := 128
const GRID_SIZE := 4

enum STATE {
	WAITING_FOR_INPUT,
	ANIMATING_TILES,
	GAME_OVER,
}

var state := STATE.WAITING_FOR_INPUT
var grid : Array[Array] = [] # Should be Array[Array[Tile]] but is currently unsupported

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(GRID_SIZE): 
		grid.append([])
		for y in range(GRID_SIZE): 
			grid[x].append(null)
	# Spawn initial two tiles
	var tile1_pos := Vector2i(randi_range(0,3), randi_range(0,3))
	var tile2_pos := tile1_pos
	while tile1_pos == tile2_pos: # ensure the two tile positions are different
		tile2_pos = Vector2i(randi_range(0,3), randi_range(0,3))
	add_tile_at((randi_range(1,2)*2), tile1_pos)
	add_tile_at((randi_range(1,2)*2), tile2_pos)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Does not update the grid array, just adds the Tile to the scene and returns it
func add_tile_at(value: int, pos: Vector2i) -> Tile:
	print("Adding tile valued " + str(value) + " at " + str(pos))
	return null # todo
