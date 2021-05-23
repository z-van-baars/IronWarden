tool
extends Control
signal button_down
signal button_up
signal button_pressed

export var button_text = "Default Button" setget change_button_text
export var font_size = 18 setget change_font_size

func change_button_text(new_text):
	$Button.text = new_text
	$Button.rect_size.x = (1 + font_size) + (new_text.length() - 1) * 0.4
	rect_size.x = (1 + font_size) + (new_text.length() - 1) * 0.4

func change_font_size(new_size):
	$Button.custom_fonts.font.size = new_size
	$Button.rect_size.y = font_size + 10
	rect_size.y = font_size + 10
