class_name WizardViewSelector
extends Control


signal views_selected(views_dict: Dictionary)

@onready var cancel_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var submit_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/SubmitButton

# Up
@onready var high_front: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/UpAngleContainer/HighFront
@onready var high_profile_front: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/UpAngleContainer/HighProfileFront
@onready var high_side: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/UpAngleContainer/HighSide
@onready var high_profile_back: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/UpAngleContainer/HighProfileBack
@onready var high_back: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/UpAngleContainer/HighBack

# Normal
@onready var normal_front: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/FrontAngleContainer/NormalFront
@onready var normal_profile_front: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/FrontAngleContainer/NormalProfileFront
@onready var normal_side: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/FrontAngleContainer/NormalSide
@onready var normal_profile_back: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/FrontAngleContainer/NormalProfileBack
@onready var normal_back: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/FrontAngleContainer/NormalBack

# Low
@onready var low_front: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/LowAngleContainer/LowFront
@onready var low_profile_front: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/LowAngleContainer/LowProfileFront
@onready var low_side: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/LowAngleContainer/LowSide
@onready var low_profile_back: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/LowAngleContainer/LowProfileBack
@onready var low_back: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/LowAngleContainer/LowBack

# Extra
@onready var bird_view: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/ExtraAngleContainer/BirdView
@onready var worm_view: AngleViewContainer = $PanelContainer/MarginContainer/VBoxContainer/ExtraAngleContainer/WormView


func _ready():
	submit_button.pressed.connect(on_submit_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)


func on_cancel_pressed() -> void:
	queue_free()


func on_submit_pressed() -> void:
	var low: bool = low_front.is_checked() or\
			low_back.is_checked() or\
			low_profile_back.is_checked() or\
			low_profile_front.is_checked() or\
			low_side.is_checked()
	
	var high: bool = high_back.is_checked() or\
			high_front.is_checked() or\
			high_profile_back.is_checked() or\
			high_profile_front.is_checked() or\
			high_side.is_checked()
	
	var front: bool = low_front.is_checked() or\
			high_front.is_checked() or\
			normal_front.is_checked()
	
	var profile: bool = low_profile_back.is_checked() or\
			low_profile_front.is_checked() or\
			high_profile_back.is_checked() or\
			high_profile_front.is_checked() or\
			normal_profile_back.is_checked() or\
			normal_profile_front.is_checked()
	
	var side: bool = low_side.is_checked() or\
			high_side.is_checked() or\
			normal_side.is_checked()
	
	var rear: bool = low_back.is_checked() or\
			high_profile_back.is_checked() or \
			normal_back.is_checked() or\
			low_profile_back.is_checked() or\
			high_profile_back.is_checked() or\
			normal_profile_back.is_checked()

	views_selected.emit({
		"worm": worm_view.is_checked(),
		"bird": bird_view.is_checked(),
		"low": low,
		"high": high,
		"front": front,
		"profile": profile,
		"side": side,
		"rear": rear
	})
