class_name EventHandler
extends Node


func get_action() -> Action:
	var action: Action = null
	
	
	if Input.is_action_just_pressed("Move up"):
		action = BumpAction.new(0, -1)
	elif Input.is_action_just_pressed("Move down"):
		action = BumpAction.new(0, 1)
	elif Input.is_action_just_pressed("Move left"):
		action = BumpAction.new(-1, 0)
	elif Input.is_action_just_pressed("Move right"):
		action = BumpAction.new(1, 0)
	
	if Input.is_action_just_pressed("Quit"):
		action = EscapeAction.new()
	
	return action
