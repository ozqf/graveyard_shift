extends Node


func get_interactable_info() -> Dictionary:
	return {
		"type" = "card_table"
	}

func interactable_used() -> void:
	self.queue_free()
	pass
