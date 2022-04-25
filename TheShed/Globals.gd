extends Node

var score:= 0
var timer_tot:= 0
const max_hearts:=10
var hearts_halfs:=20
var next_stage:=1

var game_version=SilentWolf.config.game_version

var epoch_deadline={
	"year":2022,
	"month":04,
	"day":25, #this is to convert to EST from UTC
#	"day":18,
	"hour":3, #this is to convert to EST from UTC
#	"hour":17, 
	"minute":59
#	"minute":12
}
var time_left:={}
var time_left_as_string:=""
var competition_active=true

func _ready():
	reset_score()
	compare_current_time_to_epoch()
#	SilentWolf.Scores.wipe_leaderboard()

func reset_score():
	score = 0
	timer_tot= 0
	hearts_halfs = max_hearts*2
#	hearts_halfs = 100000

func compare_current_time_to_epoch():
	var deadline=OS.get_unix_time_from_datetime(epoch_deadline)
	var timestamp = OS.get_unix_time()
	var time : Dictionary = OS.get_datetime_from_unix_time(timestamp);
	var display_string : String = "%d/%02d/%02d %02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute];
#	print("time: ", display_string)
	var difference_in_unixtime=deadline-timestamp
#	print("difference: ",difference_in_unixtime)

		
		
	var sum = deadline-timestamp
	var days = floor(float(sum) / 86400)
	var day_string = "day" if days == 1 else "days"
	var hours = (sum / 3600) % 24
	var minutes = (sum / 60) % 60
	var seconds = sum % 60
#	print(str(days, " ", day_string, ", ", "%02d hours, " % hours, "", "%02d minutes " % minutes, "and %02d seconds" % seconds, " to go!"))
	time_left_as_string=str(days, "d ", "%02dh " % hours, "", "%02dm " % minutes, "%02ds" % seconds)
	if difference_in_unixtime <=0:
		competition_active=false
		time_left_as_string="EPOCH ENDED"
#	time_left_as_long_string=str(days, " ", day_string, ", ", "%02d hours, " % hours, "", "%02d minutes " % minutes, "and %02d seconds" % seconds, " to go!")
	
#	time_left.day=deadline.day-time.day
#	time_left.hour=deadline.hour-time.hour
#	time_left.minutes=deadline.hour-time.hour
#	time=OS.get_datetime_from_unix_time(difference)
#	display_string = "%d/%02d/%02d %02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute];
#	print("time difference: ", display_string)
	
