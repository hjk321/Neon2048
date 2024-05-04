class_name Tile
extends Sprite2D

const FADE_SECONDS := 0.3

enum STATE {
	IDLE,
	APPEAR,
	DISAPPEAR,
	SLIDE,
}

const TEXTURES = {
	2: preload("res://2.png"),
	4: preload("res://4.png"),
	8: preload("res://8.png"),
	16: preload("res://16.png"),
	32: preload("res://32.png"),
	64: preload("res://64.png"),
	128: preload("res://128.png"),
	256: preload("res://256.png"),
	512: preload("res://512.png"),
	1024: preload("res://1024.png"),
	2048: preload("res://2048.png"),
}

@export var value := 2;
@export var state: STATE = STATE.APPEAR:
	set(value):
		if value != state:
			state = value
			state_data = null
var state_data : Variant = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not TEXTURES.has(value):
		value = 2
	texture = TEXTURES[value]
	do_state(0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	do_state(delta)

func do_state(delta: float) -> void:
	match state:
		STATE.IDLE: return
		STATE.APPEAR: state_appear(delta)
		STATE.DISAPPEAR: state_disappear(delta)
		STATE.SLIDE: state_slide(delta)

func state_appear(delta: float) -> void:
	if not (state_data is float): state_data = 0.0
	state_data += (delta / FADE_SECONDS)
	modulate.a = state_data
	if state_data >= 1.0: state = STATE.IDLE

func state_disappear(delta: float) -> void:
	z_index = -10
	if not (state_data is float): state_data = 1.0
	state_data -= (delta / FADE_SECONDS)
	modulate.a = state_data
	if state_data <= 0.0: queue_free()

func state_slide(_delta: float) -> void:
	pass
