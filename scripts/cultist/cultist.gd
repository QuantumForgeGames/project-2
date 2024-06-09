extends CharacterBody2D
class_name Cultist

@export var speed: float = 400.
@onready var doubt_timer := $DoubtTimer
@onready var dissent_timer := $DissentTimer
@onready var area_of_influence := $AreaOfInfluence

enum STATES {BASE, DOUBT, DISSENT}

func on_hit():
	$StateMachine.on_hit()

func exit_scene():
	$CollisionShape2D.set_deferred("disabled", true)
	
	var ytarget := 600.
	var dir := int(global_position.x > get_viewport_rect().size.x / 2)
	var xtarget := dir * get_viewport_rect().size.x + (2 * dir - 1) * 50.
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.25)
	tween.tween_property(self, "scale", Vector2(1., 1.), 0.25)
	tween.tween_property(self, "position:y", ytarget, abs(global_position.y - ytarget)/speed)
	tween.tween_property(self, "position:x", xtarget, abs(global_position.x - xtarget)/speed)
	tween.tween_callback(func(): queue_free())

func change_sprite(state: STATES):
	var sprites = $Sprites.get_children()
	sprites[state].visible = true
	sprites[(state + 1) % 3].visible = false
	sprites[(state + 2) % 3].visible = false

func set_state(state: STATES):
	$StateMachine.on_child_transitioned($StateMachine.get_child(state).name)

func on_captured():
	velocity = Vector2.ZERO
	set_collision_layer_value(3, false)
