extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player_raycast: RayCast3D = $"../../Player/TwistPivot/PitchPivot/Camera3D/Flashlight/RayCast3D"
@onready var pause_timer := $Timer
@onready var footsteps = $footsteps
@onready var anim = $"vampire/AnimationPlayer"

 
var speed := 1.5

@export var player: Node3D 

func _ready():
	navigation_agent_3d.set_target_position(Vector3(player.global_position.x, 0, player.global_position.z))
	anim.play("walk")

func _physics_process(_delta: float) -> void:
	if !pause_timer.is_stopped():
		footsteps.stop()
		anim.play("idle")
		return
	if !footsteps.playing:
		footsteps.play()
		anim.play("walk")
	isCaught()
	move_along_path() 


func move_along_path():
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()

	if pause_timer.is_stopped() and player_caught():
		Global.victory = false
		get_tree().change_scene_to_file("res://src/end.tscn")

	navigation_agent_3d.set_target_position(Vector3(player.global_position.x, 0, player.global_position.z))

	if direction.length() > 0:
		var flat_direction = Vector3(direction.x, 0, direction.z).normalized()
		look_at(global_position + flat_direction, Vector3.UP)
		velocity = direction * speed
		move_and_slide()
		
	if velocity.length() < 0.1 and not navigation_agent_3d.is_navigation_finished():
		navigation_agent_3d.set_target_position(navigation_agent_3d.target_position)

func isCaught():
	if player_raycast.is_colliding():
		var seen_object = player_raycast.get_collider()
		if seen_object == self and player.get("flashlight_on"):
			_start_pause()
			
func player_caught():
	var distance_x = abs(player.global_transform.origin.x - global_transform.origin.x)
	var distance_z = abs(player.global_transform.origin.z - global_transform.origin.z)
	return distance_x <= 1.2 and distance_z <= 1.2
	
func _start_pause():
	if pause_timer.is_stopped():
		pause_timer.start(7)
