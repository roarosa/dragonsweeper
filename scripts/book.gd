extends Node

const MONSTER_ENTRIES: Array[String] = ["rat", "bat", "skeleton", "gargoyle", "slime", "minotaur", "guardian", "purple_slime", "lover", "engineer", "rat_king", "gazer", "slime_witch", "mimic", "dragon", "mine"]
var _book_entries: Dictionary = {}

func _ready() -> void:
  var book_entries: Array[BookEntry] = []
  for node in find_children("*", "", true, false):
      if node is BookEntry:
          book_entries.append(node)
  if book_entries.size() != MONSTER_ENTRIES.size():
    print("Book entries and monster entries size mismatch")
    return
  for i in range(book_entries.size()):
    _book_entries[MONSTER_ENTRIES[i]] = book_entries[i]


func update_monster_counts(_monster_counts: Dictionary) -> void:
  for monster_name in MONSTER_ENTRIES:
    if monster_name != "gazer" and _monster_counts.has(monster_name):
      var entry: BookEntry = _book_entries[monster_name]
      entry.count = _monster_counts[monster_name]
