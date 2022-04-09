extends Sprite

export(float)  var expected_time
export(Color)  var color setget set_color
#var early_buffer=0.01
#var late_buffer=0.001
var delay=700 # it was 600 then 660 the higher, the more you tend to hit early and arrows go faster
var buffer=0.15
var state_ := ""

func _ready():
	if Globals.next_stage==2:
		delay=700
		buffer=0.17
	if Globals.next_stage==3:
		buffer=0.19
		delay=750 # was 1000

func set_color(value:Color) -> void:
	color = value
	self_modulate = color

func test_hit(time:float) -> bool:
	#late
#	if (time-expected_time)>0 and (time-expected_time) < late_buffer:
#		return true
#	else:
#		#early
#		if (time-expected_time) <= -early_buffer:
#			return true
		
	if abs(expected_time - time) < buffer:
		return true
	return false

func test_miss(time:float) -> bool:
	if time > expected_time + buffer:
		return true
	return false

func hit(position_to_freeze:Vector2) -> void:
	state_ = "hit"
	global_position = position_to_freeze
	
func miss() -> void:
	state_ = "miss"

func _process(delta):
	if state_ == "hit":
		queue_free()
		return

	global_position.y += delta * delay
		
	if state_ == "miss":
		if global_position.y > delay:
			queue_free()
