extends Control

func update_display(display_name, cost_string, stats_string):
	$Panel/NameLabel.rect_size.x = 20
	$Panel/NameLabel.text = display_name

	$Panel/CostLabel.rect_size.x = 20
	$Panel/CostLabel.text = cost_string
	
	$Panel/StatsLabel.rect_size.x = 20
	$Panel/StatsLabel.text = stats_string
	
	
	rect_size.x = $Panel/StatsLabel.rect_size.x + 14


func _on_TechTree_box_clicked(click_loc, display_name, cost_string, stats_string):
	rect_position = click_loc
	update_display(display_name, cost_string, stats_string)
	show()
