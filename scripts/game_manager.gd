extends Node

var score = 0 # player's score
var level = 1 #player's current level

# add points to score (called from elsewhere)
func addPoints(points):
	score += points
func _process(_delta: float) -> void:
	# update GUI with new score
	$CanvasLayer/ScoreLabel.text = str(score)
	$CanvasLayer/LevelLabel.text = "Level: "+str(level)
