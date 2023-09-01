extends Control

onready var player_1_health: ProgressBar = $TopBar/HealthBars/Player1
onready var player_2_health: ProgressBar = $TopBar/HealthBars/Player2
onready var player_1_score: Label = $TopBar/Score1
onready var player_2_score: Label = $TopBar/Score2

onready var match_over: ColorRect = $MatchOver
onready var condition_label: Label = $MatchOver/Labels/Condition
onready var instruction_label: Label = $MatchOver/Labels/Instruction

func _ready() -> void:
	$Reconnect.hide()
	$MatchOver.hide()
	$ConnectScreen.show()
	$DEBUG.visible = Global.DEBUG

func _on_reconnect_pressed() -> void:
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

func game_over(condition: String) -> void:
	var display_condition : String
	var display_instruction : String
	
	match condition:
		"Win":
			condition_label.text = "Victory"
			instruction_label.text = "Press any key to Delete another person!"
		"Lose":
			condition_label.text = "Defeat"
			instruction_label.text = "Press any key to get deleted again!"
		_:
			condition_label.text = "ERROR"
			instruction_label.text = "Incorrect condition " + condition
	
	match_over.show()
