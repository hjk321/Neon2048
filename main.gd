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
	if Input.is_action_just_pressed("restart"):
		var _state := get_tree().reload_current_scene()
		return
	match state: 
		STATE.WAITING_FOR_INPUT: state_input()
		STATE.ANIMATING_TILES: state_animate()
		STATE.GAME_OVER: pass

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

# Spawns a 2 or a 4 at a random empty spot, if possible
func add_random_tile() -> void:
	var empty: Array[Vector2i] = []
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if grid[x][y] == null: empty.append(Vector2i(x,y))
	if empty.is_empty(): return
	var new_pos := empty[randi_range(0, empty.size() - 1)]
	var value := 2
	if randi_range(1, 10) == 10:
		value = 4
	add_tile_at(value, new_pos)

# Checks for user input
func state_input() -> void:
	var direction := Vector2i.ZERO
	if Input.is_action_just_pressed("up"): direction = Vector2i.UP
	elif Input.is_action_just_pressed("down"): direction = Vector2i.DOWN
	elif Input.is_action_just_pressed("left"): direction = Vector2i.LEFT
	elif Input.is_action_just_pressed("right"): direction = Vector2i.RIGHT
	if direction == Vector2i.ZERO: return
	print("Shifting grid in direction " + str(direction))
	do_shift_grid(direction)
	add_random_tile()
	state = STATE.ANIMATING_TILES

# shifts the grid in a direction, applying tile animations as we go.
func do_shift_grid(dir: Vector2i) -> void:
	match dir:
		Vector2i.UP:
			for x in range(GRID_SIZE):
				var row := []
				for y in range(GRID_SIZE): row.append(grid[x][y])
				row = do_row(row, dir)
				for y in range(GRID_SIZE): grid[x][y] = row[y]
		Vector2i.DOWN:
			for x in range(GRID_SIZE):
				var row := []
				for y in range(GRID_SIZE - 1, -1, -1): row.append(grid[x][y])
				row = do_row(row, dir)
				for y in range(GRID_SIZE): grid[x][y] = row[GRID_SIZE - 1 - y]
		Vector2i.LEFT:
			for y in range(GRID_SIZE):
				var row := []
				for x in range(GRID_SIZE): row.append(grid[x][y])
				row = do_row(row, dir)
				for x in range(GRID_SIZE): grid[x][y] = row[x]
		Vector2i.RIGHT:
			for y in range(GRID_SIZE):
				var row := []
				for x in range(GRID_SIZE - 1, -1, -1): row.append(grid[x][y])
				row = do_row(row, dir)
				for x in range(GRID_SIZE): grid[x][y] = row[GRID_SIZE - 1 - x]

# Proccesses a single row during a shift.
# Abstracted to one-dimensional array where element 0 is at the "bottom" of current gravity
func do_row(row: Array, shift_direction: Vector2i) -> Array:
	# recursively condenses the row so there are no nulls except at the end
	var condense := func condense(r: Array, n: int, dir: Vector2i, c: Callable) -> Array:
		if n >= (GRID_SIZE - 1): return r
		if r[n] == null:
			for i in range(n + 1, GRID_SIZE):
				var tile: Variant = r[i]
				if tile is Tile:
					(tile as Tile).slide_tile((TILE_SIZE * (i - n)) * dir)
					r[n] = tile
					r[i] = null
					break
		return c.call(r, n + 1, dir, c)
	
	if row.size() != GRID_SIZE: return row
	row = condense.call(row, 0, shift_direction, condense)
	
	# Merge tiles non-recursively
	for i in range(GRID_SIZE - 1):
		if not (row[i] is Tile) or not (row[i + 1] is Tile): break # we condensed the row already
		var tile1: Tile = row[i]
		var tile2: Tile = row[i + 1]
		if tile1.value != tile2.value: continue
		tile1.state = Tile.STATE.DISAPPEAR
		tile2.value *= 2
		tile2.slide_tile(TILE_SIZE * shift_direction)
		row[i] = row[i + 1]
		row[i + 1] = null
		row = condense.call(row, 0, shift_direction, condense)
	return row
	
func state_animate() -> void:
	for child in $Tiles.get_children():
		if child is Tile and (child as Tile).state != Tile.STATE.IDLE: return
	if check_game_over(): state = STATE.GAME_OVER
	else: state = STATE.WAITING_FOR_INPUT

func check_game_over() -> bool:
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var tile: Tile = grid[x][y]
			if not (tile is Tile): return false # a blank space exists 
			if tile.value == 2048:
				($YouWin as CanvasItem).visible = true
				return true
			if (x - 1 >= 0) and (grid[x - 1][y] is Tile) and (tile.value == grid[x - 1][y].value):
				return false
			if (x + 1 < GRID_SIZE) and (grid[x + 1][y] is Tile) and (tile.value == grid[x + 1][y].value):
				return false
			if (y - 1 >= 0) and (grid[x][y - 1] is Tile) and (tile.value == grid[x][y - 1].value):
				return false
			if (y + 1 < GRID_SIZE) and (grid[x][y + 1] is Tile) and (tile.value == grid[x][y + 1].value):
				return false
	($GameOver as CanvasItem).visible = true
	return true
