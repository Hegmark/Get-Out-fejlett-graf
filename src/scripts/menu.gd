extends Node3D


@onready var maze = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/maze
@onready var forest = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/forest
@onready var castle = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/castle
@onready var quit = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/quit
@onready var fader = $CanvasLayer/Fader

@export var mazescene: PackedScene
@export var forestscene: PackedScene

var chosen_scene = null

func _ready():
	fader.fade_in()
	maze.connect("pressed", on_maze_pressed)
	forest.connect("pressed", on_forest_pressed)
	castle.connect("pressed", on_castle_pressed)
	quit.connect("pressed", on_quit_pressed)
	fader.connect("fade_finished", on_fade_finished)
	
func on_maze_pressed():
	chosen_scene = mazescene
	fader.fade_out()
	#animation_player.play("fade_out")
	
func on_forest_pressed():
	fader.fade_out()
	chosen_scene = forestscene
	#animation_player.play("fade_out")

func on_castle_pressed():
	fader.fade_out()
	#animation_player.play("fade_out")

func on_quit_pressed():
	get_tree().quit()
	
func on_fade_finished():
	if chosen_scene == null:
		pass
	else:
		get_tree().change_scene_to_packed(chosen_scene)
