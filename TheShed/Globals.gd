extends Node
########################################################################3
######## Steps to change to new epoch
#	1 - change the game_version to a new version to delete previous scoreboard (for that, open addons/silent_wolf/SilentWolf.gd and edit the config - version thing
#	2 - input epoch_startline data, remembering to increase EST time by 4
#	3 - input epoch_startline_as_string, which is just the start line as it will be shown in letters.
#	4 - input epoch_deadline data, remembering to increase EST time by 4
#	5 - input epoch_deadline_as_string, which is just the deadline line as it will be shown in letters.
#	6 - double check that startline and deadline are correct in terms of data format and visualized formant (compare epoch_startline data with epoch_startline_as_string, and same for deadline)
#	7 - done! Upload and enjoy profits.
var epoch_startline={
	"year":2022,
	"month":05,
	"day":14, 
#	"day":10, 
	"hour":13, #this is to convert to EST from UTC (NYC is UTC -4 with DST)
	"minute":00
}
var epoch_startline_as_string="2022/5/14 Saturday 9 AM - EST"
var epoch_deadline={
	"year":2022,
	"month":05,
	"day":21, 
#	"day":11, 
	"hour":13, #this is to convert to EST from UTC (NYC is UTC -4 with DST)
	"minute":00
#	"minute":12
}
var epoch_deadline_as_string="2022/5/21 Saturday 9 AM - EST"
###############################################################################

var score:= 0
var timer_tot:= 0
const max_hearts:=10
var hearts_halfs:=20
var next_stage:=1
var game_version=SilentWolf.config.game_version
var time_left:={}
var time_left_as_string:=""
var competition_state:="" # can be incoming, active, finished

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
	var startline=OS.get_unix_time_from_datetime(epoch_startline)
	var timestamp = OS.get_unix_time()
	var time : Dictionary = OS.get_datetime_from_unix_time(timestamp);
#	var display_string : String = "%d/%02d/%02d %02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute];
#	print("time: ", display_string)
	var deadline_difference_in_unixtime=deadline-timestamp
	var startline_difference_in_unixtime=startline-timestamp

	# check if time now is before startline
	if startline_difference_in_unixtime >0:
		competition_state="incoming"
#		time_left_as_string="EPOCH ENDED"
#	print("difference: ",difference_in_unixtime)
		var startline_sum = startline-timestamp
		var startline_days = floor(float(startline_sum) / 86400)
		var startline_day_string = "day" if startline_days == 1 else "days"
		var startline_hours = (startline_sum / 3600) % 24
		var startline_minutes = (startline_sum / 60) % 60
		var startline_seconds = startline_sum % 60
#	print(str(days, " ", day_string, ", ", "%02d hours, " % hours, "", "%02d minutes " % minutes, "and %02d seconds" % seconds, " to go!"))
		time_left_as_string=str(startline_days, "d ", "%02dh " % startline_hours, "", "%02dm " % startline_minutes, "%02ds" % startline_seconds)
		return
	else:
	#no check that time is before deadline
#		if deadline_difference_in_unixtime <=0:
#			#too late!
#			competition_state="finished"
#			time_left_as_string="EPOCH ENDED"

		var deadline_sum = deadline-timestamp
		var deadline_days = floor(float(deadline_sum) / 86400)
		var deadline_day_string = "day" if deadline_days == 1 else "days"
		var deadline_hours = (deadline_sum / 3600) % 24
		var deadline_minutes = (deadline_sum / 60) % 60
		var deadline_seconds = deadline_sum % 60
	#	print(str(days, " ", day_string, ", ", "%02d hours, " % hours, "", "%02d minutes " % minutes, "and %02d seconds" % seconds, " to go!"))
		time_left_as_string=str(deadline_days, "d ", "%02dh " % deadline_hours, "", "%02dm " % deadline_minutes, "%02ds" % deadline_seconds)
		competition_state="active"
		if deadline_difference_in_unixtime <=0:
			competition_state="finished"
			time_left_as_string="EPOCH ENDED"
#	time_left_as_long_string=str(days, " ", day_string, ", ", "%02d hours, " % hours, "", "%02d minutes " % minutes, "and %02d seconds" % seconds, " to go!")
	
#	time_left.day=deadline.day-time.day
#	time_left.hour=deadline.hour-time.hour
#	time_left.minutes=deadline.hour-time.hour
#	time=OS.get_datetime_from_unix_time(difference)
#	display_string = "%d/%02d/%02d %02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute];
#	print("time difference: ", display_string)
	
