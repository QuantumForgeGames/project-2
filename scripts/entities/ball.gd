

class_name Ball
extends CharacterBody2D

var NARROW_BOUNCE = (Vector2.UP * 8 + Vector2.RIGHT).normalized()
var WIDE_BOUNCE = (Vector2.UP + Vector2.RIGHT * 5).normalized()
var KICK_TIMEOUT_DURATION := 10.

@export var speed :float = 500
@export var MAX_SPEED :float = 600
@export var MIN_SPEED :float = 400

var can_kick: bool = true

func _ready () -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	randomize()
	var trajectory := Vector2(randf_range(-1., 1.), [randf_range(-1., -0.25), randf_range(0.25, 1.)].pick_random()).normalized()
	velocity = trajectory * speed


func _process (_delta :float) -> void:
	if Input.is_action_just_pressed("random_kick") and can_kick:
		_on_kick()
	else:
		_bounce(move_and_collide(velocity * _delta))


func _bounce (collision_ :KinematicCollision2D) -> void:
	if collision_ == null: return
	velocity = velocity.bounce(collision_.get_normal())
	var collider = collision_.get_collider()
	if collider is Paddle:
		var dist = global_position - collider.global_position
		dist = dist.project(Vector2.RIGHT)
		var ratio = abs(dist.x / collider.half_paddle_width)
		var trajectory = lerp(NARROW_BOUNCE, WIDE_BOUNCE, ratio).normalized()
		trajectory = lerp(trajectory, velocity.normalized(), 0.2).normalized()
		trajectory.x *= sign(velocity.x)
		velocity = trajectory * velocity.length() + collider.velocity 
		velocity = velocity.normalized() * clampf(MIN_SPEED, MAX_SPEED, velocity.length())
	else:
		var dir := int(signf(velocity.y))
		if abs(velocity.y) < 0.1:
			match dir:
				0, 1: velocity.y += 0.1
				-1: velocity.y -= 0.1
			velocity.normalized()

	$HitHandlerSystem.on_collision(collider)
		
func change_sprite() -> void:
	var duration := 0.5
	var tween := get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($Sprites/Filled, "modulate:a", 1 - $Sprites/Filled.modulate.a, duration)
	tween.tween_property($Sprites/Empty, "modulate:a", 1 - $Sprites/Empty.modulate.a, duration)

func _on_kick() -> void:
	can_kick = false
	#get_tree().create_timer(KICK_TIMEOUT_DURATION).timeout.connect(func(): can_kick = true)
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.25)
	tween.tween_property(self, "scale", Vector2(1., 1.), 0.25)
	
	# var angle: float = randf_range(PI/2, 3 * PI/2) + velocity.angle()
	# velocity = 1.25 * speed * Vector2(cos(angle), sin(angle))
	match int(signf(velocity.x)):
		0, 1: 
			print("right")
			velocity = velocity.orthogonal()
		-1: 
			print("left")
			velocity = velocity.orthogonal() * -1
