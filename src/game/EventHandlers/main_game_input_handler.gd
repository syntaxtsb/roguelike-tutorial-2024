class_name MainGameInputHandler
extends BaseInputHandler

const directions = {
	"Move up": Vector2i.UP,
	"Move down": Vector2i.DOWN,
	"Move left": Vector2i.LEFT,
	"Move right": Vector2i.RIGHT,
	"Move up left": Vector2i.UP + Vector2i.LEFT,
	"Move up right": Vector2i.UP + Vector2i.RIGHT,
	"Move down left": Vector2i.DOWN + Vector2i.LEFT,
	"Move down right": Vector2i.DOWN + Vector2i.RIGHT,
}

const inventory_menu_scene = preload("res://src/gui/inventory_menu/inventory_menu.tscn")

func get_action(player: Entity) -> Action:
	var action: Action = null
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			var offset: Vector2i = directions[direction]
			action = BumpAction.new(player, offset.x, offset.y)
	
	if Input.is_action_just_pressed("Wait"):
		action = WaitAction.new(player)
	
	if Input.is_action_just_pressed("View history"):
		get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)
	
	if Input.is_action_just_pressed("Pickup"):
		action = PickupAction.new(player)
	
	if Input.is_action_just_pressed("Drop"):
		var selected_item: Entity = await get_item("Select an item to drop", player.inventory_component)
		action = DropItemAction.new(player, selected_item)
	
	if Input.is_action_just_pressed("Activate"):
		var selected_item: Entity = await get_item("Select an item to use", player.inventory_component)
		action = ItemAction.new(player, selected_item)
	
	if Input.is_action_just_pressed("Quit") or Input.is_action_just_pressed("UI back"):
		action = EscapeAction.new(player)
	
	return action


func get_item(window_title: String, inventory: InventoryComponent) -> Entity:
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()
	add_child(inventory_menu)
	inventory_menu.build(window_title, inventory)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_item: Entity = await inventory_menu.item_selected
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_item
