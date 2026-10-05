class_name GuessPopup
extends PopupPanel

const BUTTON_SCENE := preload("res://guess_button.tscn")
# TODO: replace with assets
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
  CellData.GuessValue.ELEVEN: "11",
  CellData.GuessValue.TWELVE: "12",
  CellData.GuessValue.BLUE: "?B",
  CellData.GuessValue.GREEN: "?G",
  CellData.GuessValue.MINE: "*",
  CellData.GuessValue.NONE: "",
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
  button.get_node("Label").text = GUESS_LABELS[value]
  button.gui_input.connect(_on_button_gui_input.bind(value))
  return button


func _on_button_gui_input(event: InputEvent, value: CellData.GuessValue) -> void:
  if event.is_action_pressed("left_click"):
    guess_selected.emit(cell_location, value)
    hide()
