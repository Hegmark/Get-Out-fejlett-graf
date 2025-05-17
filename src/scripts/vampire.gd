extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player_raycast: RayCast3D = $"../../Player/TwistPivot/PitchPivot/Camera3D/Flashlight/RayCast3D"
@onready var pause_timer: Timer = $Timer
@onready var footsteps: AudioStreamPlayer3D = $footsteps
@onready var anim: AnimationPlayer = $"vampire/AnimationPlayer"

@export var player: Node3D

var speed := 3.5
var last_target: Vector3

func _ready():
	last_target = player.global_position
	_update_agent_target()
	anim.play("walk")

func _physics_process(_delta: float) -> void:
	if player.global_position.distance_to(last_target) > 0.1:
		last_target = player.global_position
		_update_agent_target()

	if not pause_timer.is_stopped():
		velocity = Vector3.ZERO
		move_and_slide()
		footsteps.stop()
		anim.play("idle")
		return
	elif not footsteps.playing:
		footsteps.play()
		anim.play("walk")

	_move_along_path()

	if player_raycast.is_colliding() and player_raycast.get_collider() == self and player.get("flashlight_on"):
		if pause_timer.is_stopped():
			pause_timer.start(7)


	if global_position.distance_to(player.global_position) <= 1.2:
		Global.victory = false
		get_tree().change_scene_to_file("res://src/end.tscn")

func _update_agent_target():
	var tgt = player.global_position
	tgt.y = global_position.y
	navigation_agent_3d.set_target_position(tgt)

func _move_along_path():
	var next_pos = navigation_agent_3d.get_next_path_position()
	next_pos.y = global_position.y

	var raw = next_pos - global_position
	if raw.length() < 0.1:
		return

	raw.y = 0
	var dir = raw.normalized()

	look_at(global_position + dir, Vector3.UP)
	velocity = dir * speed
	move_and_slide()
