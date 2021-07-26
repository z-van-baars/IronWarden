extends KinematicBody2D

# Signal Declarations
signal left_clicked
signal right_clicked
signal credit_resources
signal debit_resources
signal update
signal shield_damage
signal kill

enum Sounds {
	SELECT,
	CONFIRM,
	MOVE_CONFIRM,
	ATTACK_CONFIRM,
	GATHER_CONFIRM,
	EXTRACT,
	CONSTRUCT,
	ATTACK,
	DEATH,
	SET_RALLY_POINT,
	UNIT_BUILT
}

enum WeaponTypes {
	PROJECTILE,
	HITSCAN,
	BEAM,
	MELEE
}
enum DamageType {
	KINETIC,
	ENERGY
}
enum AttackStats {
	PROJ_TYPE,
	SPEED,
	LIFESPAN,
	DAMAGE_TYPE,
	DAMAGE
}
var boltershell_data = {
	AttackStats.PROJ_TYPE: Types.PROJECTILE.BULLET,
	AttackStats.SPEED: 800,
	AttackStats.LIFESPAN: 0.5,
	AttackStats.DAMAGE_TYPE: Types.DAMAGE.KINETIC,
	AttackStats.DAMAGE: 10
}
var lasbolt_data = {
	AttackStats.PROJ_TYPE: Types.PROJECTILE.LASBOLT,
	AttackStats.SPEED: 1000,
	AttackStats.LIFESPAN: 0.5,
	AttackStats.DAMAGE_TYPE: Types.DAMAGE.ENERGY,
	AttackStats.DAMAGE: 3
}
var lasbeam_data = {
	AttackStats.PROJ_TYPE: Types.PROJECTILE.LASBEAM,
	AttackStats.SPEED: 0,
	AttackStats.LIFESPAN: 0.5,
	AttackStats.DAMAGE_TYPE: Types.DAMAGE.ENERGY,
	AttackStats.DAMAGE: 1
}
onready var sound_players = {
	Sounds.SELECT: [],
	Sounds.CONFIRM: [],
	Sounds.MOVE_CONFIRM: [],
	Sounds.ATTACK_CONFIRM: [],
	Sounds.GATHER_CONFIRM: [],
	Sounds.EXTRACT: {},
	Sounds.CONSTRUCT: [],
	Sounds.ATTACK: [],
	Sounds.DEATH: [],
	Sounds.SET_RALLY_POINT: [],
	Sounds.UNIT_BUILT: []
}

var barrel_length = {
	UnitTypes.UTYPE.CHICKEN: 12,
	UnitTypes.UTYPE.CONSCRIPT: 16,
	UnitTypes.UTYPE.MARINE: 20,
	UnitTypes.UTYPE.TECHPRIEST: 22,
	UnitTypes.UTYPE.PREDATOR: 50,
	UnitTypes.UTYPE.LASCANNON: 50,
	UnitTypes.UTYPE.JOHNNY: 50,
}

var barrel_height = {
	UnitTypes.UTYPE.CHICKEN: 18,
	UnitTypes.UTYPE.CONSCRIPT: 33,
	UnitTypes.UTYPE.MARINE: 43,
	UnitTypes.UTYPE.TECHPRIEST: 33,
	UnitTypes.UTYPE.PREDATOR: 50,
	UnitTypes.UTYPE.LASCANNON: 25,
	UnitTypes.UTYPE.JOHNNY: 43,
}

var player_colors = {
	0: Color.blue,
	1: Color.red,
	2: Color.yellow,
	3: Color.green
}

# Module References
var tools
var nav
var nav2d
var _player_owner
var dis
var st
var units
var res
var proj
var map_grid

# Internal node references
onready var health_bar = get_node("HealthBar")
onready var shield_bar = get_node("ShieldBar")
onready var bump_timer = get_node("Path2D/BumpTimer")
onready var sound_container = get_node("Sounds")



# variable statline properties, filled out for different units programmatically
onready var weapon_type
onready var weapon
onready var build_options = []
onready var tech_options = []

onready var _faction
onready var _utype
onready var _stype
onready var _stats = {}

# pause duration before attempting a repath, allows both objects to 'reset' instead
# of spamming each game tick with re-path or move-along-path attempts
onready var bump_cooldown = 1.0

# default value - assumes "base to base" contact w/adjacent object
onready var contact_radius = 18


# mutable internal properties
var selected = false
var pos
var state
var task
var last_direction = Vector2(0, 1)
var direction : Vector2
var animation_direction = "down"
var step_target : Vector2
var final_target : Vector2
var path = []
var waypoints = []
var task_queue = []
var carrying = {}
var target_unit = null
var target_dropoff = null
var target_deposit = null
var target_construction = null
var gather_type = null # Resource ID, ints
var extraction_type = null # Deposit ID, int
var targeted_by = []

onready var selection_border_size = {
	"human": preload("res://Assets/Art/UI/selection_border_small.png"),
	"vehicle": preload("res://Assets/Art/UI/selection_border_large.png")}

func _ready():
	set_module_refs()
	for stat in Stats.STAT:
		_stats[Stats.STAT[stat]] = null
	$GatherShape.shape.radius = contact_radius

func set_module_refs() -> void:
	tools = get_tree().root.get_node("Main/Tools")
	nav = get_tree().root.get_node("Main/Nav2D/NavMap")
	nav2d = get_tree().root.get_node("Main/Nav2D")
	dis = get_tree().root.get_node("Main/Dispatcher")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	res = get_tree().root.get_node("Main/GameObjects/Resources")
	proj = get_tree().root.get_node("Main/GameObjects/Projectiles")
	map_grid = get_tree().root.get_node("Main/GameMap/Grid")

func connect_signals() -> void:
	self.connect("left_clicked", dis, "_on_Unit_left_clicked")
	self.connect("right_clicked", dis, "_on_Unit_right_clicked")
	self.connect("update", dis, "_on_Unit_update")
	self.connect("kill", dis, "_on_Unit_kill")
	self.connect("credit_resources", dis, "_on_Unit_credit_resources")
	self.connect("debit_resources", dis, "_on_Unit_debit_resources")
	sub_connect()

func sub_connect() -> void:
	pass

func setup(unit_type, location, player_owner) -> void:
	set_module_refs()
	connect_signals()
	load_stats(unit_type)
	_player_owner = player_owner
	position = location
	last_direction = Vector2(
		tools.rng.randf_range(0.0, 1.0),
		tools.rng.randf_range(0.0, 1.0)).normalized()
	
	set_spriteframes(units.get_faction(unit_type), unit_type)
	build_sounds()
	zero_target()

func load_stats(unit_type) -> void:
	for stat in units.statlines[unit_type].keys():
		_stats[stat] = units.statlines[unit_type][stat]

func set_spriteframes(faction_name, _unit_type) -> void:
	pass

# Sound shit
func build_sounds() -> void:
	pass

func import_sound_subdir(sound_dir_str, subdir_str, sound_type_index, subtype_str="", subtype_index=null):
	var directory_string = sound_dir_str + subdir_str + subtype_str
	for sound_file in tools.list_files_in_directory(directory_string):
		if not sound_file.substr(sound_file.length() - 4) == ".ogg": continue
		var new_audioplayer = AudioStreamPlayer2D.new()
		sound_container.add_child(new_audioplayer)
		
		if subtype_str == "":
			new_audioplayer.stream = load(sound_dir_str + subdir_str + sound_file)
			sound_players[sound_type_index].append(new_audioplayer)
		else:
			new_audioplayer.stream = load(sound_dir_str + subdir_str + subtype_str + sound_file)
			sound_players[sound_type_index][subtype_index].append(new_audioplayer)

func play_sound(sound_index, gather_id=null) -> void:
	if sound_players[sound_index].empty(): return
	if gather_id == null: tools.r_choice(sound_players[sound_index]).play()
	else: tools.r_choice(sound_players[sound_index][gather_id]).play()


func play_confirm() -> void: play_sound(Sounds.CONFIRM)
func play_move_confirm() -> void: play_sound(Sounds.MOVE_CONFIRM)
func play_attack_sound() -> void: play_sound(Sounds.ATTACK)
func play_attack_confirm() -> void: play_sound(Sounds.ATTACK_CONFIRM)
func play_greeting() -> void: play_sound(Sounds.SELECT)


func get_world_pos() -> Vector2: return position
func get_tile_coords() -> Vector2: return map_grid.get_tile(position)
func get_player_number() -> int: return _player_owner
func set_faction(faction_name): _faction = faction_name
func get_faction() -> String: return _faction
func get_id() -> void: pass
func get_display_name() -> String: return _stats[Stats.STAT.DISPLAY_NAME]
func get_speed() -> int: return _stats[Stats.STAT.SPEED]
func get_armor() -> int: return _stats[Stats.STAT.ARMOR]
func set_health(new_health) -> void: _stats[Stats.STAT.HEALTH] = new_health
func get_health() -> int: return _stats[Stats.STAT.HEALTH]
func get_maxhealth() -> int: return _stats[Stats.STAT.MAXHEALTH]
func set_shields(new_shields): _stats[Stats.STAT.SHIELDS] = new_shields
func get_shields() -> int: return _stats[Stats.STAT.SHIELDS]
func get_maxshields() -> int: return _stats[Stats.STAT.MAXSHIELDS]
func get_attack() -> int: return _stats[Stats.STAT.ATTACK]
func get_range() -> int: return _stats[Stats.STAT.RANGE]
func get_build_time() -> int: return _stats[Stats.STAT.BUILD_TIME]
func get_gather_time() -> int: return _stats[Stats.STAT.GATHER_TIME]
func get_carry_cap() -> int: return _stats[Stats.STAT.CARRY_CAP]
func get_sight() -> int: return _stats[Stats.STAT.SIGHT]
func get_cost() -> int: return _stats[Stats.STAT.COST]

func get_footprint(): return $Footprint

func is_boxable() -> bool: return true
func get_thumbnail(): return units.thumbnail[_utype]
func can_path() -> bool: return true
func can_gather() -> bool: return false
func empty_lading() -> void: pass
func can_construct() -> bool: return false

func get_attack_windup() -> int: return 1
func get_attack_speed() -> int: return 1
func get_construction_time() -> int: return 1
func get_center() -> Vector2: return Vector2(position.x, position.y)

func state_changed():
	pass

func task_changed():
	pass

func _draw():
	$Target.hide()
	pass

func update_bars():
	if get_maxshields() != 0:
		shield_bar.max_value = get_maxshields()
		shield_bar.value = get_shields()
	$BumpBar.hide()
	$BumpLabel.hide()
	if not bump_timer.is_stopped():
		$BumpBar.show()
		$BumpBar.value = bump_timer.time_left
		$BumpLabel.show()
	health_bar.max_value = get_maxhealth()
	health_bar.value = get_health()


func get_target():
	if not target_unit == null:
		return target_unit
	if not target_dropoff == null:
		return target_dropoff
	if not target_deposit == null:
		return target_deposit
	if not target_construction == null:
		return target_construction
	return null

func get_target_name():
	return get_target().get_display_name()

func get_target_coordinates():
	return get_target().get_tile_coords()

func zero_target():
	final_target = position
	path = []
	step_target = position

func set_target_deposit(t_deposit):
	if target_deposit: target_deposit.get_node("SelectionBorder").hide()
	target_deposit = t_deposit
	gather_type = t_deposit.get_r_type()
	extraction_type = t_deposit.get_id()
	path_to(t_deposit.get_center())

func clear_target_deposit():
	if not target_deposit: return
	target_deposit.gather_target_unset(self)
	target_deposit = null

func clear_extraction_type():
	extraction_type = null

func set_targeted(new_unit):
	targeted_by.append(new_unit)

func set_untargeted(new_unit):
	targeted_by.erase(new_unit)


func set_target_unit(new_target_unit):
	target_unit = new_target_unit
	target_unit.set_targeted(self)
	direction = (target_unit.position - position).normalized()

func clear_target_unit():
	if not target_unit: return
	target_unit.set_untargeted(self)
	target_unit = null
	$AttackTimer.stop()

func set_target_construction(tile):
	target_construction = map_grid.get_structure_at(tile)
	path_to(target_construction.get_center())

func clear_target_construction():
	if not target_construction: return
	target_construction = null


func check_contact(queried_object, alternative_radius=null):
	var space = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	var contact_zone = CircleShape2D.new()
	contact_zone.radius = contact_radius
	if alternative_radius:
		contact_zone.radius = alternative_radius
	query.set_shape(contact_zone)
	query.transform = Transform2D(0, get_center())
	query.transform.x *= 1.75

	var collisions = space.intersect_shape(query)
	for entry in collisions:
		if entry.collider.get_footprint() == queried_object.get_footprint():
			return true
	return false

func get_step_target():
	var new_step_target = nav.map_to_world(path[0])
	path.remove(0)
	step_target = Vector2(new_step_target.x, new_step_target.y)
	direction = (step_target - position).normalized()

func path_to(target_world_pos):
	var nav_path = nav2d.get_simple_path(position, target_world_pos, true)
	if nav_path.size() < 1:
		return
	final_target = nav_path[nav_path.size()-1]
	set_path(nav_path)


func set_path(new_path):
	path = new_path
	step_target = path[0]
	path.remove(0)

func player_right_clicked(player_id, target_world_pos, shift):
	if player_id != get_player_number():
		return

func add_waypoint(waypoint):
	pass

func get_next_waypoint(): return waypoints.pop_front()

func get_next_task(): return task_queue.pop_front()

func clear_waypoints(): waypoints = []

func get_action_string():
	return null

func get_sprite_direction(dir: Vector2):
	return "down"

func select():
	selected = true
	$SelectionBorder.show()
	health_bar.show()
	if target_unit: target_unit.hover()
	if target_deposit:
		target_deposit.get_node("SelectionBorder").show()
		target_deposit.get_node("SelectionBorder").modulate = Color.green

func deselect():
	selected = false
	$SelectionBorder.hide()
	health_bar.hide()
	if target_unit: target_unit.unhover()
	if target_deposit:
		target_deposit.get_node("SelectionBorder").hide()
		target_deposit.get_node("SelectionBorder").modulate = Color.white




func take_damage(damage_type, damage_amt, attacker=null):
	var shield_carryover = damage_amt
	if not get_shields() == 0:
		shield_carryover = max(0, get_shields() - damage_amt)
		emit_signal("shield_damage")
	var armor_carryover = shield_carryover
	if not get_armor() == 0:
		armor_carryover = max(1, shield_carryover - get_armor())
	armor_carryover = damage_amt
	set_health(max(0, get_health() - armor_carryover))
	if get_health() == 0:
		kill()

	emit_signal("update", self)

func set_aggressive(new_target):
	pass


func kill():
	# emit_signal("kill", self, targeted_by)
	$KillTimer.start()

func health_changed():
	health_bar.value = get_health()

func shields_changed():
	shield_bar.value = get_shields()

func hover():
	$SelectionBorder.show()
	health_bar.show()

func unhover():
	if selected: return
	$SelectionBorder.hide()
	health_bar.hide()

func _on_BBox_mouse_entered():
	hover()

func _on_BBox_mouse_exited():
	unhover()

func _on_BBox_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		emit_signal("left_clicked", self)
	elif event.is_action_pressed("right_click"):
		emit_signal("right_clicked", self)

func _on_GatherTimer_timeout():
	pass

func _on_ConstructionTimer_timeout():
	pass

func get_weapon_offset():
	return (
		Vector2(0, -barrel_height[_utype]) + 
		Vector2(0, -barrel_length[_utype]).rotated(position.angle_to(-last_direction)))

func get_weapon_data():
	if get_id() == Types.UTYPE.PREDATOR or get_id() == Types.UTYPE.LASCANNON:
		return lasbeam_data
	elif get_id() == Types.UTYPE.MARINE:
		return boltershell_data
	else:
		return lasbolt_data

func _on_AttackTimer_timeout():
	pass

func _on_KillTimer_timeout():
	queue_free()

func _on_AnimationTimer_timeout():
	$AnimatedSprite.set_frame(0)
	$AnimatedSprite.play()

func _on_AnimatedSprite_animation_finished():
	pass

