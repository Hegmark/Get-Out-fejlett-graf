extends ColorRect


@onready var animplayer = $AnimationPlayer

signal fade_finished

func _ready():
	animplayer.connect("animation_finished", on_anim_finished)

func fade_in():
	animplayer.play("fade_in")
	
func fade_out():
	animplayer.play("fade_out")

func on_anim_finished(name):
	emit_signal("fade_finished")
