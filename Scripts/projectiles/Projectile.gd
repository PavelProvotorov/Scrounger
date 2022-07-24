extends Area2D

var speed = 250
var direction
var hit_player:bool

func _physics_process(delta):
	position += direction * speed * delta
	pass

func _on_Projectile_body_entered(body):
	if body.is_in_group(Global.GROUPS.PLAYER) == hit_player:
		self.queue_free()
