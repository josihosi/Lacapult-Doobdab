extends Node
# This node stores donor messages of the day and picks one at random when asked.
# Each entry is a personal message from a donor — these are not translated.


const _DONORS = [
	"[i]\"Thank you to the Dabdoob and Catapult developers for the launcher this project builds on.\"[/i]\n    — [color=#f5c842][b]Lacapult Doobdab[/b][/color]",
]


func get_message() -> String:

	var index = OS.get_system_time_msecs() % len(_DONORS)
	return _DONORS[index]
