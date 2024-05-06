class_name Tile
extends Sprite2D

const APPEAR_SECONDS := 0.13
const DISAPPEAR_SECONDS := 0.07
const SLIDE_SECONDS := 0.1

enum STATE {
	IDLE,
	APPEAR,
	DISAPPEAR,
	SLIDE,
}

const TILES = {
	0: [preload("res://2.png")],
	1: [preload("res://4.png")],
	2: [preload("res://8.png")],
	3: [preload("res://16.png")],
	4: [preload("res://32.png")],
	5: [preload("res://64.png")],
	6: [preload("res://128.png")],
	7: [preload("res://256.png")],
	8: [preload("res://512.png")],
	9: [preload("res://1024.png")],
	10: [preload("res://2048.png")],
}

@export var value := 0:
	# set the texture when the value changes
	set(val):
		if not TILES.has(val):
			value = 0
		value = val
		texture = TILES[value][0]
@export var state: STATE = STATE.APPEAR:
	# set the state data to null when the state changes
	set(value):
		if value != state:
			state = value
			state_data = null
			state_data_2 = null
			state_data_3 = null

# TODO clean this up
var state_data : Variant = null
var state_data_2 : Variant = null
var state_data_3: Variant = null

func _ready() -> void:
	do_state(0.0)

func _process(delta: float) -> void:
	do_state(delta)

func do_state(delta: float) -> void:
	match state:
		STATE.IDLE: state_idle()
		STATE.APPEAR: state_appear(delta)
		STATE.DISAPPEAR: state_disappear(delta)
		STATE.SLIDE: state_slide(delta)

# do nothing except make sure the tile is visible
func state_idle() -> void:
	z_index = 0
	modulate.a = 1.0

# fade in over time, then become idle
func state_appear(delta: float) -> void:
	z_index = -10
	if not (state_data is float): state_data = 0.0
	state_data += (delta / APPEAR_SECONDS)
	modulate.a = state_data
	if state_data >= 1.0: state = STATE.IDLE

# fade out over time, then delete the tile
func state_disappear(delta: float) -> void: #
	z_index = -10
	if not (state_data is float): state_data = 1.0
	state_data -= (delta / DISAPPEAR_SECONDS)
	modulate.a = state_data
	if state_data <= 0.0: queue_free()

# Lerps the tile
func state_slide(delta: float) -> void:
	z_index = 10
	if not (state_data is Vector2):
		state = STATE.IDLE
		return
	if not (state_data_2 is float): state_data_2 = 0.0
	if not (state_data_3 is Vector2): state_data_3 = state_data
	state_data_2 += delta
	if state_data_2 >= SLIDE_SECONDS:
		state_data_2 = SLIDE_SECONDS
	position = (state_data_3 as Vector2).lerp(state_data as Vector2, state_data_2 as float / SLIDE_SECONDS)
	if state_data_2 == SLIDE_SECONDS: state = STATE.IDLE

# Applies the sliding animation. Stacks with additional calls to slide_tile
func slide_tile(diff: Vector2) -> void:
	state = STATE.SLIDE
	if state_data is Vector2: state_data += diff
	else: 
		state_data = position + diff
		state_data_3 = position

static func true_value_of(val: int) -> int:
	return 2 ** (val + 1)
	
func true_value() -> int:
	return Tile.true_value_of(value)
