class_name BookEntry
extends Node

@export var icon_name: String
@export var monster_name: String
@export var health: int
@export var count: int: set = set_count

func set_count(value: int) -> void:
  count = value
  %Count.text = "??" if count == -1 else str(count)
  var style := %Count.get_theme_stylebox("normal") as StyleBoxFlat
  style.bg_color = Color("#777777") if count == 0 else Color("#66219c")


func _ready() -> void:
  %Icon.texture = Sprites.get_sprite(icon_name)
  %Name.text = monster_name
  %Health.text = str(health)

  %Count.text = "??" if count == -1 else str(count)
  var style := %Count.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
  style.bg_color = Color("#777777") if count == 0 else Color("#66219c")
  %Count.add_theme_stylebox_override("normal", style)
