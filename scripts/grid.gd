extends Node2D

# Grid variables
@export var width: int
@export var height: int
@export var xStart: int
@export var yStart: int
@export var offset: int

var allPieces = []

var possiblePieces = [
	preload("res://scenes/bluePiece.tscn"),
	preload("res://scenes/greenPiece.tscn"),
	preload("res://scenes/lightGreenPiece.tscn"),
	preload("res://scenes/orangePiece.tscn"),
	preload("res://scenes/pinkPiece.tscn"),
	preload("res://scenes/yellowPiece.tscn"),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	allPieces = make2Darray(width, height)
	spawnPieces(width, height)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func make2Darray(width, height):
	var array = [];
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
	
func gridToPixel(column, row):
	var x = xStart + offset * column
	var y = yStart + (-offset) * row
	return Vector2(x, y)
	
func spawnPieces(width, height):
	for i in width:
		for j in height:
			# choose a random int
			var randInt: int = randi_range(0, possiblePieces.size()-1)
			# instantiate a new piece
			var piece = possiblePieces[randInt].instantiate()
			add_child(piece)
			piece.position = gridToPixel(i, j)
