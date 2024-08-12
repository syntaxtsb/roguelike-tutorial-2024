class_name HistoryViewerInputHandler
extends BaseInputHandler

const scroll_step = 16

@export_node_path("PanelContainer") var messages_panel_path
@export_node_path("MessageLog") var message_log_path

@onready var message_panel: PanelContainer = get_node(messages_panel_path)
@onready var message_log: MessageLog = get_node(message_log_path)


func enter() -> void:
	message_panel.self_modulate = Color.RED


func exit() -> void:
	message_panel.self_modulate = Color.WHITE


func get_action(_player: Entity) -> Action:
	var action: Action
	
	if Input.is_action_just_pressed("Move up"):
		message_log.scroll_vertical -= scroll_step
	elif Input.is_action_just_pressed("Move down"):
		message_log.scroll_vertical += scroll_step
	elif Input.is_action_just_pressed("Move left"):
		message_log.scroll_vertical = 0
	elif Input.is_action_just_pressed("Move right"):
		message_log.scroll_vertical = message_log.get_v_scroll_bar().max_value
	
	if Input.is_action_just_pressed("View history") or Input.is_action_just_pressed("UI back"):
		get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME)
	
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	
	return action
