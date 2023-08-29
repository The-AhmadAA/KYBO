extends Label

var score = 0


func _on_boxer1_die():
	score += int(rand_range(5000, 1000000000))
	text = "Score: %s \nBleep! You deleted your opponent!" % score

func _on_boxer1_hit():
	score += int(rand_range(1, 500))
	text = "Score: %s \nKeep Your Block On!" % score
