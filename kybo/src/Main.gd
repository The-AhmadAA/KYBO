extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$UserInterface/Retry.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_boxer1_die():
	$UserInterface/Retry.show()


func _input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		# Restart the scene
		get_tree().reload_current_scene()


func _on_boxer2_die2():
	pass # Replace with function body.


func _on_boxer2_hit2():
	pass # Replace with function body.
