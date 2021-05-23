extends Control
export onready var message_timeout = 3 setget set_message_timeout
onready var events = []
onready var chat_log = []
onready var event_label = $Panel/Label

onready var event_scn = preload("res://Scripts/Event.gd")



func _ready():
	$EventUpdateTimer.start()
	update_onscreen_display()


func _on_EventUpdateTimer_timeout():
	update_onscreen_display()

func _on_Dispatcher_add_new_event(event_text):
	add_event(event_text)


func add_event(text):
	var new_event = event_scn.new()
	new_event.setup(OS.get_unix_time(), text)
	events.append(new_event)


func get_recent_events(log_to_search):
	var recent_events = []
	for event in log_to_search.slice(max(0, log_to_search.size()-10), log_to_search.size()-1):
		var event_age = OS.get_unix_time() - event.get_time()
		if event_age < message_timeout: recent_events.append(event)
	return recent_events
	

func update_onscreen_display():
	var recent_events = get_recent_events(events)
	var recent_chats = get_recent_events(chat_log)
	event_label.text = ""
	event_label.rect_size.y = 20
	
	var recent_by_time = recent_events + recent_chats
	if recent_by_time.empty():
		$Panel.hide()
		return
	$Panel.show()

	for recent_event in recent_by_time.slice(
		-min(recent_by_time.size(), 24),
		recent_by_time.size()-1):
		if event_label.text != "": event_label.text += "\n"
		
		event_label.text += recent_event.text
	$Panel.rect_size.y = event_label.rect_size.y + 26

func set_message_timeout(new_time):
	message_timeout = new_time
	
	
		






