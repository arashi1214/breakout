extends Control

@export var player : CharacterBody2D
@export var GameController : Node


func _on_player_speed_value_changed(value: float) -> void:
	player.speed = value
	print(value)

func _on_ball_speed_value_changed(value: float) -> void:
	GameController.ball_speed = value


func _on_level_value_changed(value: float) -> void:
	GameController.level = value
	GameController.reset_game()
