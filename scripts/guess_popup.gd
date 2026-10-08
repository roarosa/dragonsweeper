class_name GuessPopup
extends PopupPanel

const BUTTON_SCENE := preload("res://guess_button.tscn")

const GUESS_LABELS = {
  CellData.GuessValue.ONE: "1",
  CellData.GuessValue.TWO: "2",
  CellData.GuessValue.THREE: "3",
  CellData.GuessValue.FOUR: "4",
  CellData.GuessValue.FIVE: "5",
  CellData.GuessValue.SIX: "6",
  CellData.GuessValue.SEVEN: "7",
  CellData.GuessValue.EIGHT: "8",
  CellData.GuessValue.NINE: "9",
  CellData.GuessValue.TEN: "10",
}
const GUESS_ICONS = {
  CellData.GuessValue.CHEST: "guess_chest",
  CellData.GuessValue.GREEN: "guess_green",
  CellData.GuessValue.BLUE: "guess_blue",
  CellData.GuessValue.RED: "guess_red",
  CellData.GuessValue.MINE: "guess_mine",
  CellData.GuessValue.NONE: "guess_trash",
}

signal guess_selected(location: Vector2i, value: CellData.GuessValue)

var cell_location: Vector2i

func _ready() -> void:
  var grid_container: GridContainer = GridContainer.new()
  grid_container.add_theme_constant_override("h_separation", 0)
  grid_container.add_theme_constant_override("v_separation", 0)
  grid_container.columns = 4
  for i in range(16):
    grid_container.add_child(_make_button(i))
  add_child(grid_container)


func _make_button(value: CellData.GuessValue) -> Node:
  var button: Control = BUTTON_SCENE.instantiate()
  var label_node = button.get_node("Label")
  var icon_node = button.get_node("Icon")
  if value in GUESS_LABELS:
    label_node.text = GUESS_LABELS[value]
    label_node.visible = true
    icon_node.visible = false
  elif value in GUESS_ICONS:
    icon_node.texture = Sprites.get_sprite(GUESS_ICONS[value])
    icon_node.visible = true
    label_node.visible = false
  else:
    print("Unknown guess value: ", value)
    label_node.text = "?"
    label_node.visible = true
    icon_node.visible = false
  button.gui_input.connect(_on_button_gui_input.bind(value))
  return button


func _on_button_gui_input(event: InputEvent, value: CellData.GuessValue) -> void:
  if event.is_action_pressed("left_click"):
    guess_selected.emit(cell_location, value)
    hide()
