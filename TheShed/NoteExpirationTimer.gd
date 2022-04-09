extends Timer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var MainNode
var LoopNode
export var note_nr=1
export var exp_time=0.4

# Called when the node enters the scene tree for the first time.
func _ready():
	MainNode=get_parent().get_parent()
	LoopNode=MainNode.get_node("Sample"+str(note_nr))
#	set_note_nr(note_nr)
	pass # Replace with function body.

#func set_note_nr(nr=1):
#	LoopNode=MainNode.get_node("Sample"+str(nr))
	
func start_expiration():
	LoopNode.volume_db=0
	wait_time=exp_time
	start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NoteExpirationTimer_timeout():
	LoopNode.volume_db=-80
	pass # Replace with function body.
