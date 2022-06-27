extends RigidBody

var shot = false

const DAMAGE = 20
const MOVE_SPD = 2

func _ready() -> void:
	set_as_toplevel(true)

func _physics_process(delta: float) -> void:
	if shot:
		apply_impulse(transform.basis.z, -transform.basis.z * MOVE_SPD)




func _on_Area_body_entered(body: Node):
	if body.is_in_group("Player"):
		body.hp -= DAMAGE
		queue_free()
	else:
		queue_free()


