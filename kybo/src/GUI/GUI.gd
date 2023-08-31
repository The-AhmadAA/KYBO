extends Control

onready var player_1_health: ProgressBar = $TopBar/HealthBars/Player1
onready var player_2_health: ProgressBar = $TopBar/HealthBars/Player2


func _ready() -> void:
	$Reconnect.hide()

func _on_connect_pressed() -> void:
	get_tree().call_group("player", "reset_retry")

func update_health(player: String, health: int) -> void:
	match player:
		"Musk":
			player_1_health.value = health
		"Zuck":
			player_2_health.value = health
