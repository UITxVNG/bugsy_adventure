extends Node

var triggered_dialogs: Dictionary = {}

func has_dialog_triggered(key: String) -> bool:
	return triggered_dialogs.get(key, false)

func set_dialog_triggered(key: String, value: bool) -> void:
	triggered_dialogs[key] = value

func reset_all_dialogs() -> void:
	triggered_dialogs.clear()

func reset_dialog(key: String) -> void:
	triggered_dialogs.erase(key)
