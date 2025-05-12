extends Control

@export var main_menu_scene := preload("res://src/menu.tscn")

@onready var message_label : Label  = $VBoxContainer/Label
@onready var back_button   : Button = $VBoxContainer/Button

func _ready() -> void:
	message_label.text = "YOU SURVIVED" if Global.victory else "YOU DIED"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
