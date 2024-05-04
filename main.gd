extends Node2D

const GRID_SIZE := 4

enum STATE {
	WAITING_FOR_INPUT,
	ANIMATING_TILES,
	GAME_OVER,
}

var state := STATE.WAITING_FOR_INPUT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
