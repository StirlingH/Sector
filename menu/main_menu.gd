extends Control

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://combat/ship_player.tscn")
