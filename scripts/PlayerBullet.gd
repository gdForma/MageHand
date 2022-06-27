extends RigidBody

var shoot = false

const DAMAGE = 3
const MOVE_SPD = 10

func _ready() -> void:
	set_as_toplevel(true)

func _physics_process(delta: float) -> void:
	if shoot:
		apply_impulse(transform.basis.z, -transform.basis.z * MOVE_SPD)




func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):
		body.hp -= DAMAGE
		queue_free()
	else:
		queue_free()
