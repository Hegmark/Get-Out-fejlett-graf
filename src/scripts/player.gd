extends RigidBody3D

@onready var flashlight = $TwistPivot/PitchPivot/Camera3D/Flashlight
@onready var battery_bar = $"../TextureProgressBar"


var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
@export var flashlight_on = false
var battery = 100.0  
var battery_drain_rate = 0.5  
var battery_low_threshold = 30.0  
var flicker_chance = 0.1

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	flashlight.visible = flashlight_on
	
func _process(delta: float) -> void:
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
	
	apply_central_force($TwistPivot.basis * input * 1500.0 * delta)
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
			
