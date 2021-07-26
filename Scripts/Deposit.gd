extends "res://Scripts/GameUnit.gd"
signal hovered
signal unhovered
signal exhausted

onready var starting = {}
onready var remaining = {}
onready var _r_type
onready var _d_type
onready var border_flashes = 3

var gatherers = []
onready var partially_mined = false

func sub_connect():
	self.connect("hovered", dis, "_on_Deposit_hovered")
	self.connect("unhovered", dis, "_on_Deposit_unhovered")
	self.connect("exhausted", dis, "_on_Deposit_exhausted")
	
func setup(deposit_type, location, player_number):
	connect_signals()
	starting = {
		ResourceTypes.RES.BIOMASS: 0,
		ResourceTypes.RES.ALLOY: 0,
		ResourceTypes.RES.WARPSTONE: 0,
		ResourceTypes.RES.ENERGY: 0}

	remaining = {
		ResourceTypes.RES.BIOMASS: 0,
		ResourceTypes.RES.ALLOY: 0,
		ResourceTypes.RES.WARPSTONE: 0,
		ResourceTypes.RES.ENERGY: 0}
	load_stats(deposit_type)
	set_spriteframes("-", deposit_type)
	$Range.queue_free()
	set_detection_polygon()
	set_footprint_polygon()
	set_selection_border()
	position = location
	pos = map_grid.get_tile(position)

	assert(res.deposits[deposit_type][_r_type] != 0)


func load_stats(deposit_type):
	_r_type = res.get_r_type(deposit_type)
	_d_type = deposit_type
	_stats[Stats.STAT.DISPLAY_NAME] = res.get_display_name(deposit_type)
	_stats[Stats.STAT.MAXHEALTH] = 100
	_stats[Stats.STAT.HEALTH] = 100
	starting[_r_type] = res.deposits[deposit_type][_r_type]
	remaining[_r_type] = res.deposits[deposit_type][_r_type]
	$ProgressBar.min_value = 0
	$ProgressBar.max_value = starting[_r_type]

func set_spriteframes(_faction_name, deposit_type):
	var name_string = get_display_name().to_lower().replace(" ", "_")
	var anim_path = "res://Assets/SpriteFrames/Deposits/" + name_string
	# $AnimatedSprite.frames = load(anim_path + "/SpriteFrame.tres")
	#$AnimatedSprite.frames = res.spriteframe_ref[deposit_type]
	$Sprite.texture = tools.r_choice(res.deposit_icons[deposit_type])
	# $Sprite.position.y -= max(0, $Sprite.texture.get_height() - 128) / 2
func get_coordinates(): return pos
func set_detection_polygon():
	$BBox/Border.polygon = $DetectionArea.polygon
func get_footprint(): return $TileFootprint
func set_footprint_polygon():
	$Footprint.queue_free()

func set_selection_border():
	$SelectionBorder.texture = load("res://Assets/Art/UI/selection_border_1x1.png")
	$SelectionBorder.position = Vector2(0, -42)

func build_sounds():
	var sound_dir = (
		"res://Assets/Sound/Deposits/" +
		get_display_name().to_lower().replace(" ", "_") + "/"
		)
	for sound_category in [
		["select/", Sounds.SELECT],
		["death/", Sounds.DEATH]
	]:
		import_sound_subdir(
			sound_dir,
			sound_category[0],
			sound_category[1])



func is_boxable():
	return false

func get_id(): return _d_type
func get_r_type(): return _r_type

func update_bars():
	$ProgressBar.show()
	$ProgressBar.value = remaining[_r_type]

func increment(resource_type, quantity):
	partially_mined = true
	update_bars()
	if remaining[resource_type] > quantity:
		remaining[resource_type] -= quantity
		return
	remaining[resource_type] = 0
	exhaust()


func get_center():
	return position + Vector2(0, 26)

func get_thumbnail():
	return res.thumbnail[_d_type]

func kill():
	emit_signal("kill", self, gatherers)

func exhaust():
	emit_signal("exhausted", self, gatherers)
	deselect()
	hide()

func select():
	selected = true
	$SelectionBorder.show()
	$ProgressBar.show()

func deselect():
	selected = false
	$SelectionBorder.hide()
	$ProgressBar.hide()

func gather_target_set(gatherer):
	$SelectionBorder.modulate = Color(255, 0, 0)
	$SelectionBorder.show()
	gatherers.append(gatherer)

func gather_target_unset(gatherer):
	if not selected:
		$SelectionBorder.hide()
	if not partially_mined: $ProgressBar.hide()
	gatherers.erase(gatherer)

func hover():
	$ProgressBar.show()
	$SelectionBorder.show()
	emit_signal("hovered", self)

func unhover():
	if not selected:
		$ProgressBar.hide()
		$SelectionBorder.hide()
	emit_signal("unhovered")


func _on_FlashTimer_timeout():
	border_flashes -= 1
	if border_flashes == 0:
		$SelectionBorder.modulate = Color(255, 255, 255)
		if not selected:
			$SelectionBorder.hide()
		border_flashes = 3
	else:
		$SelectionBorder.modulate = Color(0, 255, 0)
		$FlashTimer.start()
