extends KinematicBody

var hp = 200
var target

const speed = 10

signal score

enum {
	IDLE,
	ALERT,
	CHASING
}

var inrange = false
var state = IDLE
var space_state = PhysicsDirectSpaceState
var path = []
var path_index = 0

onready var HPBar = $Viewport/HPBar
onready var bullet_path = preload("res://Scenes/EnemyBullet.tscn")
onready var eyes = $Eyes
onready var aimcast = $Eyes/aimcast
onready var firetimer = $FireTimer
onready var player_path = preload("res://Scenes/player/player.tscn")

const TURN_SPD = 3
const BULLET_MOVE_SPD = 10

func _ready() -> void:
	pass

func _process(delta):
	HPBar.value = hp
	if hp <= 0:
		emit_signal("score")
		queue_free()
	
	match state:
		IDLE:
			firetimer.stop()
		ALERT:
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(eyes.rotation.y * TURN_SPD))

func _physics_process(delta: float) -> void:
	if path_index < path.size() and not inrange:
		var direction = path[path_index] - global_transform.origin
		if direction.length() < 1:
			path_index += 1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func _on_Range_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		state = ALERT
		target = body
		firetimer.start()
		inrange = true

func _on_Range_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		firetimer.stop()
		state = IDLE
		inrange = false

func _on_FireTimer_timeout() -> void:
	if aimcast.is_colliding():
		print("shooting")
		var bullet = bullet_path.instance()
		eyes.add_child(bullet)
		bullet.global_transform = eyes.get_global_transform()
		bullet.look_at(aimcast.get_collision_point(), Vector3.UP)
		bullet.shot = true


func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("Bullet"):
		$SFHurt.play()


