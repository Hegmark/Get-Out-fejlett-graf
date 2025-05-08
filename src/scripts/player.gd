extends RigidBody3D

@onready var flashlight = $TwistPivot/PitchPivot/Camera3D/Flashlight
@onready var battery_bar = $"../TextureProgressBar"
@onready var player_cam =  $TwistPivot/PitchPivot/Camera3D
@onready var cheat_cam = $"../Camera3D"
@onready var key = $"../key"
@onready var exit = $"../wall_doorway"
@onready var footsteps = $footsteps
@onready var sky = $"../WorldEnvironment"

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var battery = 100.0  
var battery_drain_rate = 0.8  
var battery_low_threshold = 30.0  
var flicker_chance = 0.1
var is_mouse_unlocked = false
var walking = false

@export var key_found = false
@export var flashlight_on = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	flashlight.visible = flashlight_on
	player_cam.current = true
	cheat_cam.current = false
	
func _process(delta: float) -> void:
	if check_key_dist():
		key_found = true
		key.hide()
		
	if key_found and check_exit_dist():
		print("you won")
		
	if battery <= 0:
		flashlight_on = false
		flashlight.visible = false
	
	if flashlight_on:
		battery_bar.value = battery 
		flashlight.visible = true
		battery -= battery_drain_rate * delta
		battery = max(battery, 0)
		
		if battery <= battery_low_threshold:
			if randf() < flicker_chance:
				flashlight.visible = false
				flicker_chance = min(1, flicker_chance * 1.000001)
	
	var input := Vector3.ZERO
	input.x = Input.get_axis("movement_left", "movement_right")
	input.z = Input.get_axis("movement_forward", "movement_backward")
	apply_central_force($TwistPivot.basis * input * 1000.0 * delta)
	if input.x != 0 or input.z != 0:
		walking = true
	else:
		walking = false
	
	if walking and !footsteps.playing:
		footsteps.play()
	if not walking and footsteps.playing:
		footsteps.stop()
	
	
	$TwistPivot.rotate_y(twist_input)
	$TwistPivot/PitchPivot.rotate_x(pitch_input)
	$TwistPivot/PitchPivot.rotation.x = clamp($TwistPivot/PitchPivot.rotation.x, 
		deg_to_rad(-60), 
		deg_to_rad(60)
	)
	twist_input = 0.0
	pitch_input = 0.0
	
func _input(event):
	if event.is_action_pressed("toggle_flashlight"):  
		if battery > 0:
			flashlight_on = !flashlight_on
			flashlight.visible = flashlight_on
	if event.is_action_pressed("ui_cancel"):
		if is_mouse_unlocked:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_mouse_unlocked = !is_mouse_unlocked
	if event.is_action_pressed("cam_change"):
		toggle_camera()
	if event.is_action_pressed("get_coordinates"):
		print(self.global_position.x, "   ",  self.global_position.z)

func toggle_camera():
	if player_cam.current:
		player_cam.current = false
		cheat_cam.current = true
		sky.environment.set_volumetric_fog_enabled(false)
		key.toggleBeacon()
	else:
		player_cam.current = true
		cheat_cam.current = false
		sky.environment.set_volumetric_fog_enabled(true)
		key.toggleBeacon()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
			
func check_key_dist():
	var distance_x = abs(key.global_transform.origin.x - global_transform.origin.x)
	var distance_z = abs(key.global_transform.origin.z - global_transform.origin.z)
	return distance_x <= 0.8 and distance_z <= 0.8
	
func check_exit_dist():
	var distance_x = abs(exit.global_transform.origin.x - global_transform.origin.x)
	var distance_z = abs(exit.global_transform.origin.z - global_transform.origin.z)
	return distance_x <= 1.2 and distance_z <= 1.2
