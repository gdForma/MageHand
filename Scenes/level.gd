extends Spatial

onready var door = $WorldObjects/Active/ActiveDoor/AnimationPlayer
onready var DoorCheck = $WorldObjects/Active/DoorCheck

var doorawait = 5

func _ready() -> void:
	door.stop()

func _process(delta: float) -> void:
	if $Player.hp <= 0:
		get_tree().reload_current_scene()
	
	if doorawait == 0:
		door.play("doormove")


func _on_DoorCheck_body_exited(body: Node) -> void:
	if body.is_in_group("Enemy"):
		doorawait -= 1


func _on_AnimationPlayer_animation_finished(doormove) -> void:
	doorawait = 1
