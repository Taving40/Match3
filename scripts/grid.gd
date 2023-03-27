extends Node2D

# Grid variables
@export var width: int
@export var height: int
@export var xStart: int
@export var yStart: int
@export var offset: int

var allPieces = []

#PackedScenes of the pieces (needs to be instantiated to further work with)
var possiblePieces = [
	preload("res://scenes/bluePiece.tscn"),
	preload("res://scenes/greenPiece.tscn"),
	preload("res://scenes/lightGreenPiece.tscn"),
	preload("res://scenes/orangePiece.tscn"),
	preload("res://scenes/pinkPiece.tscn"),
	preload("res://scenes/yellowPiece.tscn"),
]

#variables for moving pieces logic
var firstTouch = null #mouse click down
var lastTouch = null #mouse click up
var isAttemptingMove = false 

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	allPieces = make2Darray(width, height)
	spawnPieces(width, height)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	touchInput()
	
func make2Darray(width: int, height: int):
	var array = [];
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
	
func gridToPixel(column: int, row: int) -> Vector2i:
	var x = xStart + offset * column
	var y = yStart + offset * row
	return Vector2i(x, y)
	
# Takes a vec2 of pixel coords and returns the position of the 
# piece that contains that point in the grid. Returns null if out of bounds
func pixelToGrid(vec: Vector2):
	var column = roundi((vec.x - xStart) / offset)
	var row = roundi((vec.y - yStart) / offset)
	if ( #if out of bounds of grid
		column > allPieces.size()-1 || 
		column < 0 || 
		row > allPieces[0].size()-1 ||
		row < 0
	):
		return null
	return Vector2i(column, row)
	
func spawnPieces(width: int, height: int):
	for i in width:
		for j in height:
			# choose a random int
			var randInt: int = randi_range(0, possiblePieces.size()-1)
			# instantiate a new piece
			var piece = possiblePieces[randInt].instantiate()
			# add it to the grid
			allPieces[i][j] = piece
			# while it'd make a match, pick another
			while getChainLength(i, j, piece.color) >= 3:
				randInt = randi_range(0, possiblePieces.size()-1)
				piece = possiblePieces[randInt].instantiate()
			add_child(piece)
			piece.position = gridToPixel(i, j)
			
# Determines the length of a chain of pieces of the same color
# While the color matches, looks recursively to the left and up
# Summing up all matches found at the end
func getChainLength(
	column: int,
	row: int,
	color: String,
):
	var current = 1
	if column > 0 && allPieces[column-1][row].color == color:
		current += getChainLength(column-1, row, color)
	if row > 0 && allPieces[column][row-1].color == color:
		current += getChainLength(column, row-1, color)
	return current
		
# Gets mouse down and mouse up (x,y) coords and stores them
# in order to detect swiping of pieces
func touchInput():
	if Input.is_action_just_pressed("ui_touch"):
		firstTouch = pixelToGrid(get_global_mouse_position())
		#if position is inside grid, player is attempting move
		if(firstTouch != null):
			isAttemptingMove = true
		else:
			isAttemptingMove = false
	elif Input.is_action_just_released("ui_touch"):
		lastTouch = pixelToGrid(get_global_mouse_position())
		#if position is inside grid and player is attempting move
		if lastTouch != null && isAttemptingMove :
			var direction: Vector2i = getDirection(firstTouch, lastTouch)
			print(firstTouch, lastTouch, direction)
			if direction != Vector2i.ZERO:
				swapPieces(firstTouch, direction)
				isAttemptingMove = false
				
enum Axis {X, Y}
# Calculates user intended direction of swapping pieces within following constraints:
# Can only return (-1,0), (1,0), (0,1), (0,-1) (LEFT, RIGHT, UP, DOWN)
func getDirection(point1: Vector2i, point2: Vector2i) -> Vector2i:
	# assume X most significant axis first
	var mostSignificantAxis: Axis = Axis.X
	# check if Y is more significant actually
	if abs(point2.y - point1.y) > abs(point2.x - point1.x):
		mostSignificantAxis = Axis.Y
	if mostSignificantAxis == Axis.X:
		return Vector2i(sign(point2.x - point1.x), 0)
	else:
		return Vector2i(0, sign(point2.y - point1.y))
		

func swapPieces(firstPieceCoords: Vector2, direction: Vector2):
	var firstPiece: Node2D = allPieces[firstPieceCoords.x][firstPieceCoords.y]
	#figure out grid coords of other piece
	var otherPieceCoords: Vector2 = Vector2(
		firstPieceCoords.x + direction.x,
		firstPieceCoords.y + direction.y
	)
	var otherPiece: Node2D = allPieces[otherPieceCoords.x][otherPieceCoords.y]
	#change in grid
	allPieces[firstPieceCoords.x][firstPieceCoords.y] = otherPiece
	allPieces[otherPieceCoords.x][otherPieceCoords.y] = firstPiece
	#change in game
	firstPiece.position = gridToPixel(otherPieceCoords.x, otherPieceCoords.y)
	otherPiece.position = gridToPixel(firstPieceCoords.x, firstPieceCoords.y)
	
	
	
	
