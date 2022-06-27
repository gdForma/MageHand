extends KinematicBody

const gravity = 35
const knockback_speed = 30
const speed = 20
export var hp = 100

var mouse_sensitivity = 0.05
var h_accel = 6
var jump_speed = 17
var mana = 100
var mana_regen = 0.5
var damage = 50
var air_accel = 1
var normal_accel = 6
var full_contact = false
var sprinting = false
var sfmagic_playback = false

var h_vel = Vector3()
var movement = Vector3()
var dir = Vector3()
var gravity_vector = Vector3()

onready var muzzle = $Head/Muzzle
onready var bullet_path = preload("res://Scenes/PlayerBullet.tscn")
onready var main_camera = $Head/Camera
onready var stamina_bar = $Head/Camera/Control/StaminaBar
onready var aim = $Head/Camera/Aim
onready var head = $Head
onready var grounded = $GroundCheck
onready var animation_player = $Head/zahando/AnimationPlayer
onready var state_machine = $Head/zahando/AnimationPlayer/AnimationTree.get("parameters/playback")
onready var mana_bar = $Head/Camera/Control/ManaBar
onready var hp_bar = $Head/Camera/Control/HPBar
onready var camera_animation = $Head/Camera/AnimationPlayer


func _ready() -> void:
	camera_animation.play("default")
	animation_player.play("Wiggle")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-70), deg2rad(70))
		
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	mana_bar.value = mana
	hp_bar.value = hp
	
	if Input.is_action_pressed("fire") and mana > 0:
		mana -= 0.5
		state_machine.travel("Shoot")
		if aim.is_colliding():
			var b = bullet_path.instance()
			muzzle.add_child(b)
			b.look_at(aim.get_collision_point(), Vector3.UP)
			b.shoot = true
	
	if not Input.is_action_pressed("fire") and mana < 100:
		mana += mana_regen
	
	if Input.is_action_just_released("fire"):
		state_machine.travel("Retaliate")
	
	#Debug
	
	if Input.is_action_pressed("optifinezoom"):
		main_camera.fov = 20
	else:
		main_camera.fov = 70

func _physics_process(delta: float) -> void:
	
	dir = Vector3()
	
	if grounded.is_colliding():
		full_contact = true
	else:
		full_contact = false
	
	if not is_on_floor():
		gravity_vector += Vector3.DOWN * gravity * delta
		h_accel = air_accel
	elif is_on_floor() and full_contact:
		gravity_vector = -get_floor_normal() * gravity
		h_accel = normal_accel
	else:
		gravity_vector = -get_floor_normal()
		h_accel = normal_accel
	
	if Input.is_action_pressed("jump") and (is_on_floor() or grounded.is_colliding()):
		gravity_vector = Vector3.UP * jump_speed
	
	if Input.is_action_pressed("move_forward"):
		dir -= transform.basis.z
	elif Input.is_action_pressed("move_back"):
		dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		dir += transform.basis.x
	
	
	dir = dir.normalized()
	
	h_vel = h_vel.linear_interpolate(dir * speed, h_accel * delta)
	movement.z = h_vel.z + gravity_vector.z
	movement.x = h_vel.x + gravity_vector.x
	movement.y = gravity_vector.y
	
	move_and_slide(movement, Vector3.UP)


func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("Att"):
		camera_animation.play("shake")
		$SFDamaged.play()


func _on_Lava_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		camera_animation.play("shake")
		$SFDamaged.play()
		body.hp = 0
