extends Label

var health = 100
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_boxer2_die2():
	text = "Bleep! You ate floor!"



func _on_boxer2_hit2():
	health -= 10
	text = "HP: %s" % health
