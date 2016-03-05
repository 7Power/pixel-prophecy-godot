
extends KinematicBody

var direction = Vector3(0, 0, 0)
var speed = 25

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	move(direction * delta * speed)
	
func set_direction(dir):
	direction = dir