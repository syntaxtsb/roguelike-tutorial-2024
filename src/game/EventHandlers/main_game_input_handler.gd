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

func get_action(player: Entity) -> Action:
	var action: Action = null
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			var offset: Vector2i = directions[direction]
			action = BumpAction.new(player, offset.x, offset.y)
	
	if Input.is_action_just_pressed("Wait"):
		action = WaitAction.new(player)
		
	if Input.is_action_just_pressed("Quit"):
		action = EscapeAction.new(player)
	
	return action
