extends Node
enum {
	MOVE,
	ATTACK,
	EXTRACT,
	CONSTRUCT,
	IDLE,
	DYING,
	DEAD
}

func get_all():
	return [
		MOVE,
		ATTACK,
		EXTRACT,
		CONSTRUCT,
		IDLE,
		DYING,
		DEAD
	]
