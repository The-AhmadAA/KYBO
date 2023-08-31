extends KinematicBody
class_name Boxer

export var health : int = 100
var score : int = 0

# Lerping movements for smoothing
const HISTORY_SIZE : int = 5
const LERP_SPEED : float = 0.2

# Hand control
const MAX_HAND_DISTANCE_FROM_FACE : int = 10
const HAND_LEFT_BASE_POSITION : Vector3= Vector3(-1.0, 0, 0) # adjust to your desired base position
const HAND_RIGHT_BASE_POSITION : Vector3 = Vector3(1.0, 0, 0) # adjust to your desired base position

var head : KinematicBody
var hand_right : KinematicBody
var hand_left : KinematicBody

var position_history = {
	"Face": [],
	"Hand_Left": [],
	"Hand_Right": []
}

var last_update = {
	"Face" : 0,
	"Hand_Left" : 0,
	"Hand_Right" : 0
}


func _on_hitbox_entered(body: Node) -> void:
	lose_health()
	body.get_parent().receive_score(health > 0)
	get_tree().call_group("DEBUG", "debug_message", name + " hit by " + body.get_parent().name)

func lose_health() -> void:
	health -= 10
	$AnimationPlayer.play("hit")
	get_tree().call_group("GUI", "update_health", name, health)
	
	if health <= 0:
		die()

func die() -> void:
	$AnimationPlayer.play("die")

func receive_score(opponent_alive: bool) -> void:
	if opponent_alive:
		# Got a hit in!
		score += int(rand_range(1, 500))
		get_tree().call_group("DEBUG", "debug_message", "Keep Your Block On!")
	else:
		# Deleted the opponent!
		score += int(rand_range(5000, 100000000))
		get_tree().call_group("GUI", "game_over", "Win")
		get_tree().call_group("DEBUG", "debug_message", "Bleep! You deleted your opponent!")
	
	get_tree().call_group("GUI", "update_score", name, score)
