extends Control

@onready var popup_node: Popup = %GuessPopup

func _ready() -> void:
  popup_node.popup_hide.connect(_on_popup_hide)
  popup_node.about_to_popup.connect(_on_popup_about_to_popup)

func _on_popup_hide() -> void:
  visible = false

func _on_popup_about_to_popup() -> void:
  visible = true
