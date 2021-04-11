
extends Node2D

onready var nav_map = get_tree().root.get_node("Main/Nav2D")
onready var resource_scn = preload("res://Scenes/Resource.tscn")
onready var tiles = []

onready var gem_deposit = {
	"Minerals": 50}
onready var ore_deposit = {
	"Alloy": 100}
onready var tree = {
	"Biomass": 100}
onready var space_chicken = {
	"Biomass": 50}

onready var deposits = {
	"Gem Deposit": gem_deposit,
	"Ore Deposit": ore_deposit,
	"Tree": tree,
	"Space Chicken": space_chicken}

onready var tile_ids = {
	"Gem Deposit": 0,
	"Ore Deposit": 1,
	"Tree": 2,
	"Space Chicken": 4}

onready var icons = {
	"Gem Deposit": [
		load("res://Assets/Art/Resources/gem/gem_1.png"),
		load("res://Assets/Art/Resources/gem/gem_2.png"),
		load("res://Assets/Art/Resources/gem/gem_3.png"),
		load("res://Assets/Art/Resources/gem/gem_4.png"),
		load("res://Assets/Art/Resources/gem/gem_5.png"),
		load("res://Assets/Art/Resources/gem/gem_6.png")],
	"Ore Deposit": [
		load("res://Assets/Art/Resources/ore/deposit_1.png"),
		load("res://Assets/Art/Resources/ore/deposit_2.png"),
		load("res://Assets/Art/Resources/ore/deposit_3.png")],
	"Tree": [
		load("res://Assets/Art/Resources/tree/pine_1.png"),
		load("res://Assets/Art/Resources/tree/pine_2.png"),
		load("res://Assets/Art/Resources/tree/pine_3.png"),
		load("res://Assets/Art/Resources/tree/pine_4.png"),
		load("res://Assets/Art/Resources/tree/pine_5.png"),
		load("res://Assets/Art/Resources/tree/pine_6.png"),
		load("res://Assets/Art/Resources/tree/pine_7.png"),
		load("res://Assets/Art/Resources/tree/pine_8.png")],
	"Vent": [
		load("res://Assets/Art/Resources/vent/vent_1.png")],
	"Space Chicken": [
		load("res://Assets/Art/Creatures/space_chicken.png")]}


func add_deposit(deposit_type, coordinates):
	var new_deposit = resource_scn.instance()
	$Deposits.add_child(new_deposit)
	new_deposit.load_type(deposit_type, coordinates)
	new_deposit.position = $ResourceMap.map_to_world(coordinates)
	nav_map.update_nav_tile(coordinates, -1)



