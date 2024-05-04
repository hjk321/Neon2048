extends Node2D

const TILE_SIZE := 128
const GRID_SIZE := 4

const INVALID_POSITION := Vector2(-1, -1)

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
	if grid[tile1_pos.x][tile1_pos.y] is Tile: grid[tile1_pos.x][tile1_pos.y].state = Tile.STATE.IDLE
	if grid[tile2_pos.x][tile2_pos.y] is Tile: grid[tile2_pos.x][tile2_pos.y].state = Tile.STATE.IDLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# get the scene-space coords of a grid posiiton
func grid_to_position(pos: Vector2i) -> Vector2:
	var node := $Background.find_child(str(pos.x) + "_" + str(pos.y))
	if not (node is Node2D): return INVALID_POSITION
	return (node as Node2D).position

# Adds a tile to the scene and the internal grid
func add_tile_at(value: int, pos: Vector2i) -> void:
	if pos.x < 0 or pos.x >= GRID_SIZE or pos.y < 0 or pos.y >= GRID_SIZE:
		print("Can't add a tile at " + str(pos) + " because that is an invalid position")
		return
	if grid[pos.x][pos.y] != null:
		print("Can't add a tile at " + str(pos) + " because something is already there")
		return
	var new_tile := Tile.new()
	new_tile.value = value
	new_tile.position = grid_to_position(pos)
	if new_tile.position == INVALID_POSITION:
		print("Can't add a tile at " + str(pos) + " because we couldn't find the position for it")
		return
	print("Adding tile with value " + str(value) + " at " + str(pos))
	grid[pos.x][pos.y] = new_tile
	$Tiles.add_child(new_tile)
