extends Node
class_name ThirdPersonControl

#const SPEED = 2.5
#const JUMP_VELOCITY = 4.5

@export var SPEED_WALK : float = 1
@export var SPEED_WALK_ANIMATION : float = 1.6
@export var SPEED_RUN : float = 3
@export var SPEED_RUN_ANIMATION : float = 3.3
@export var SPEED_UP : float = 10.0
@export var SPEED_DOWN_MULTIPLIER : float = 3.0
@export var SPEED_DOWN_IN_AIR_MULTIPLIER : float = 0.1
@export var MIN_ANIMATION_SPEED : float = 0.1
@export var JUMP_VELOCITY : float = 5.0

@export var f_control_sensetivity : Vector2 = Vector2( 0.5, 0.5 )
@export var f_control_bound : Vector2 = Vector2( -1.0, 1.5 )
@export var f_player_character : CharacterBody3D
@export var f_camera_heading : Node3D
@export var f_camera_incline : Node3D
@export var f_animation : AnimationPlayer
@export var f_body : Node3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = ProjectSettings.get_setting( "physics/3d/default_gravity" )

func _ready() -> void :
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not f_player_character :
		f_player_character = $'..'
	if not f_camera_heading :
		f_camera_heading = $'../CameraHeading'
	if not f_camera_incline :
		f_camera_incline = $'../CameraHeading/CameraIncline'
	if not f_animation :
		f_animation = $'../Body/AnimationPlayer'
	if not f_body :
		f_body = $'../Body'

func _input( event : InputEvent ) -> void :
	if event is InputEventMouseMotion :
		f_camera_incline.rotate_x( deg_to_rad( event.relative.y * f_control_sensetivity.y ) )
		f_camera_incline.rotation.x = clamp( f_camera_incline.rotation.x, - f_control_bound.y, - f_control_bound.x )
		f_camera_heading.rotate_y( deg_to_rad( - event.relative.x * f_control_sensetivity.x ) )

func _physics_process( delta : float ) -> void :

	var is_on_floor = f_player_character.is_on_floor()

	# Add the gravity.
	if not is_on_floor :
		f_player_character.velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed( 'jump' ) and is_on_floor:
		f_player_character.velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector( 'left', 'right', 'up', 'down' )
	if input_dir && is_on_floor :

		f_player_character.rotate_y( f_camera_heading.rotation.y )
		f_camera_heading.rotation.y = 0
		var direction := ( f_player_character.transform.basis * Vector3( input_dir.x, 0, input_dir.y ) ).normalized()

		f_body.look_at( f_player_character.position + direction )

		var velocity_normalized = f_player_character.velocity.normalized()
		var dot = velocity_normalized.x * direction.x + velocity_normalized.z * direction.z
		var speed_factor : float = ( dot + SPEED_DOWN_MULTIPLIER * ( 1 - dot ) ) * SPEED_UP * delta
		
		f_player_character.velocity.x += speed_factor * direction.x
		f_player_character.velocity.z += speed_factor * direction.z

	else :

		# print( 'f_animation.speed_scale : ', f_animation.speed_scale )
		var speed_factor : float
		if is_on_floor :
			speed_factor = SPEED_UP * SPEED_DOWN_MULTIPLIER * delta
		else :
			speed_factor = SPEED_UP * SPEED_DOWN_IN_AIR_MULTIPLIER * delta

		f_player_character.velocity.x = move_toward( f_player_character.velocity.x, 0, speed_factor )
		f_player_character.velocity.z = move_toward( f_player_character.velocity.z, 0, speed_factor )

	var speed_mag = sqrt( f_player_character.velocity.x * f_player_character.velocity.x + f_player_character.velocity.z * f_player_character.velocity.z )
	var speed_cap : float
	if Input.is_action_pressed( 'run' ) : 
		speed_cap = SPEED_RUN 
	else : 
		speed_cap = SPEED_WALK

	if speed_mag > speed_cap :
		f_player_character.velocity *= speed_cap / speed_mag
		speed_mag = speed_cap

	#print( 'speed_mag : ', speed_mag )
	#print( 'SPEED_WALK * delta : ', SPEED_WALK )

	if speed_mag > 0 :
		# f_animation.speed_scale = max( MIN_ANIMATION_SPEED, speed_mag / ( SPEED_WALK_ANIMATION * delta ) )
		# print( 'speed_scale : ', f_animation.speed_scale )
		var animation
		var normal_for_animation_speed : float
		if speed_mag > SPEED_WALK :
			animation = 'running'
			normal_for_animation_speed = SPEED_RUN_ANIMATION
		else :
			animation = 'walking'
			normal_for_animation_speed = SPEED_WALK_ANIMATION
		f_animation.speed_scale = max( MIN_ANIMATION_SPEED, speed_mag / normal_for_animation_speed )
		if f_animation.current_animation != animation :
			f_animation.play( animation )
		# print( 'animation : ', animation )
	else  :
		f_animation.speed_scale = 1
		if is_on_floor && f_animation.current_animation != 'idle' :
			f_animation.play( 'idle' )

	f_player_character.move_and_slide()
