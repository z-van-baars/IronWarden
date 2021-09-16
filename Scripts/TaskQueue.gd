extends Node

enum Type {
	MoveTo,
	Construct,
	Repair,
	Extract
}

class TQ:
	var queue = []

	func get_next():
		if queue.empty():
			return null
		return queue[0]
	
	func pull_next():
		if queue.empty():
			return null
		return queue.pop_front()
	
	func add_task(task_type, task_target):
		queue.append([task_type, task_target])

