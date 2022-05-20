extends Node2D


var limit_x_min := 0
var limit_x_max := 256*3
var limit_y_min := 0
var limit_y_max := 128
var margin := 8

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var node = $Player
	
	if node.position.x > limit_x_max+margin:
		node.position.x = limit_x_min
	
	if node.position.x < limit_x_min-margin:
		node.position.x = limit_x_max
	
	if node.position.y > limit_y_max+margin:
		node.position.y = limit_y_min
	
	if node.position.y < limit_y_min-margin:
		node.position.y = limit_y_max

