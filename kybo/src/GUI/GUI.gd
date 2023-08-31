extends Control

onready var player_1_health: ProgressBar = $TopBar/HealthBars/Player1
onready var player_2_health: ProgressBar = $TopBar/HealthBars/Player2
onready var player_1_score: Label = $TopBar/Score1
onready var player_2_score: Label = $TopBar/Score2


func _ready() -> void:
	$Reconnect.hide()

func _on_connect_pressed() -> void:
	get_tree().call_group("player", "reset_retry")

func update_health(player: String, health: int) -> void:
	match player:
		"Player1":
			player_1_health.value = health
		"Player2":
			player_2_health.value = health

func update_score(player: String, score: int) -> void:
	match player:
		"Player1":
			player_1_score.text = "Score: " + str(score)
		"Player2":
			player_2_score.text = "Score: " + str(score)
