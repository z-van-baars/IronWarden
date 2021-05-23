tool
extends Node2D
signal clicked
export var alloy_cost = 0 setget set_cost_alloy
export var biomass_cost = 0 setget set_cost_biomass
export var warpstone_cost = 0 setget set_cost_warpstone
export var energy_cost = 0 setget set_cost_energy
export var command_cost = 0 setget set_cost_command

export var display_name = "Default" setget set_display_name
export var armor = 0 setget set_armor
export var max_health = 10 setget set_health
export var max_shields = 0 setget set_shields
export var attack = 0 setget set_attack
export var attack_range = 0 setget set_range

enum ConnectorEdges {
	TOP,
	LEFT,
	RIGHT,
	BOTTOM
}

export var outgoing_connector_edge = ConnectorEdges.BOTTOM setget set_outgoing_edge
export var incoming_connector_edge = ConnectorEdges.TOP setget set_incoming_edge

export var outgoing_connector_size = 10
export var incoming_connector_size = 10

export var outgoing_connector_offset = 0
export var incoming_connector_offset = 0

var parent_node = null



enum Resources {
	ALLOY,
	BIOMASS,
	WARPSTONE,
	ENERGY,
	COMMAND
}
var resource_to_string = {
	Resources.ALLOY: "Alloy",
	Resources.BIOMASS: "Biomass",
	Resources.WARPSTONE: "Warpstone",
	Resources.ENERGY: "Energy",
	Resources.COMMAND: "Command"
}
enum Stats {
	DISPLAY_NAME,
	MAXHEALTH,
	MAXSHIELDS,
	ARMOR,
	ATTACK,
	RANGE,
	COST
}

var cost = {}
var stats = {}

var stats_to_string = {
	Stats.DISPLAY_NAME: "Name",
	Stats.MAXHEALTH: "Health",
	Stats.MAXSHIELDS: "Shields",
	Stats.ARMOR: "Armor",
	Stats.ATTACK: "Attack",
	Stats.RANGE: "Range",
	Stats.COST: "Cost"
}

func update_data():
	cost = {
		Resources.ALLOY: alloy_cost,
		Resources.BIOMASS: biomass_cost,
		Resources.WARPSTONE: warpstone_cost,
		Resources.ENERGY: energy_cost,
		Resources.COMMAND: command_cost
	}
	stats = {
		Stats.DISPLAY_NAME: display_name,
		Stats.MAXHEALTH: max_health,
		Stats.MAXSHIELDS: max_shields,
		Stats.ARMOR: armor,
		Stats.ATTACK: attack,
		Stats.RANGE: attack_range,
		Stats.COST: cost
	}

func _ready():
	var tech_tree = get_tree().root.get_node("Main/UILayer/TechTree")
	connect("clicked", tech_tree, "_on_Box_clicked")

func _process(_delta):
	update_data()
	update_graphics()



func update_graphics():
	$Panel/Title.text = display_name
	$Panel.hint_tooltip = get_tooltip_text()
	update_connector()
	

func get_tooltip_text():
	return get_cost_string(false) + get_stats_string(false)

func get_cost_string(oneline=true):
	var cost_string = "Cost: "
	if oneline != true: cost_string += "\n"
	for resource in stats[Stats.COST].keys():
		if stats[Stats.COST][resource] != 0:
			var costline = str(stats[Stats.COST][resource]) + "   " + resource_to_string[resource]
			if !oneline: costline += "\n"
			else: costline += ", "
			cost_string += costline
	return cost_string

func get_stats_string(oneline=true):
	var stats_string = ""

	for stat in stats.keys():
		if stat != Stats.DISPLAY_NAME and stat != Stats.COST:
			var statline = stats_to_string[stat] + "   " + str(stats[stat])
			if oneline != true: statline += "\n"
			else: statline += " | "
			stats_string += statline
	return stats_string



func get_incoming_connector_transforms():
	match incoming_connector_edge:
		ConnectorEdges.TOP:
			return [
				Vector2(
					$Panel.rect_size.x / 2 + incoming_connector_offset,
					0),
				Vector2(
					$Panel.rect_size.x / 2 + incoming_connector_offset,
					-incoming_connector_size)]
		ConnectorEdges.LEFT:
			return [
				Vector2(
					0,
					$Panel.rect_size.y / 2 + incoming_connector_offset),
				Vector2(
					-incoming_connector_size,
					$Panel.rect_size.y / 2 + incoming_connector_offset)]
		ConnectorEdges.RIGHT:
			return [
				Vector2(
					$Panel.rect_size.x,
					$Panel.rect_size.y / 2 + incoming_connector_offset),
				Vector2(
					$Panel.rect_size.x + incoming_connector_size,
					$Panel.rect_size.y / 2 + incoming_connector_offset)]
		ConnectorEdges.BOTTOM:
			return [
				Vector2(
					$Panel.rect_size.x / 2 + incoming_connector_offset,
					$Panel.rect_size.y),
				Vector2(
					$Panel.rect_size.x / 2 + incoming_connector_offset,
					$Panel.rect_size.y + incoming_connector_size)]


func get_outgoing_connector_loc(o_edge, o_offset, o_size):
	match o_edge:
		ConnectorEdges.TOP:
			return [
				Vector2(
					$Panel.rect_size.x / 2 + o_offset,
					-o_size),
				Vector2(
					$Panel.rect_size.x / 2 + o_offset,
					0)]
		ConnectorEdges.LEFT:
			return [
				Vector2(
					-o_size,
					$Panel.rect_size.y / 2 + o_offset),
				Vector2(
					0,
					$Panel.rect_size.y / 2 + o_offset)]
		ConnectorEdges.RIGHT:
			return [
				Vector2(
					$Panel.rect_size.x + o_size,
					$Panel.rect_size.y / 2 + o_offset),
				Vector2(
					$Panel.rect_size.x,
					$Panel.rect_size.y / 2 + o_offset)]
		ConnectorEdges.BOTTOM:
			return [
				Vector2(
					$Panel.rect_size.x / 2 + o_offset,
					$Panel.rect_size.y + o_size),
				Vector2(
					$Panel.rect_size.x / 2 + o_offset,
					$Panel.rect_size.y)]

func get_parent_node():
	if get_parent() == null: return null
	if get_parent().has_method("is_box") and get_parent().is_box() == true: return get_parent()
	return null


func update_connector():
	parent_node = get_parent_node()
	if parent_node == null: return
	var incoming_connector_transforms = get_incoming_connector_transforms()
	var outgoing_connector_transforms = parent_node.get_outgoing_connector_loc(
		outgoing_connector_edge,
		outgoing_connector_offset,
		outgoing_connector_size)
	$Connector.points[0] = incoming_connector_transforms[0]
	$Connector.points[1] = incoming_connector_transforms[1]
	$Connector.points[2] = outgoing_connector_transforms[0] - position
	$Connector.points[3] = outgoing_connector_transforms[1] - position




func is_box(): return true

# Setters 'n Getters
func set_incoming_edge(new_edge):
	if new_edge >= 0 and new_edge < 4: incoming_connector_edge = new_edge
func set_outgoing_edge(new_edge):
	if new_edge >= 0 and new_edge < 4: outgoing_connector_edge = new_edge
func set_cost_alloy(new_cost): alloy_cost = new_cost
func set_cost_biomass(new_cost): biomass_cost = new_cost
func set_cost_warpstone(new_cost): warpstone_cost = new_cost
func set_cost_energy(new_cost): energy_cost = new_cost
func set_cost_command(new_cost): command_cost = new_cost
func set_display_name(new_name): display_name = new_name
func set_health(new_health): max_health = new_health
func set_shields(new_shields): max_shields = new_shields
func set_armor(new_armor): armor = new_armor
func set_attack(new_attack): attack = new_attack
func set_range(new_range): attack_range = new_range




func _on_Box_item_rect_changed():
	update_data()
	update_graphics()


func _on_Box_script_changed():
	update_data()
	update_graphics()

func _on_Button_pressed():
	emit_signal("clicked", display_name, get_cost_string(), get_stats_string())

