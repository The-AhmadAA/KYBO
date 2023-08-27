extends Label

var score = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_boxer1_die():
	score += int(rand_range(5000, 1000000000))
	text = "Score: %s \nBleep! You deleted your opponent!" % score

func _on_boxer1_hit():
	score += int(rand_range(1, 500))
	text = "Score: %s \nKeep Your Block On!" % score
