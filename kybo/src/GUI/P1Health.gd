extends Label

var health = 100


func _on_boxer2_die2():
	text = "Bleep! You ate floor!"

func _on_boxer2_hit2():
	health -= 10
	text = "HP: %s" % health
