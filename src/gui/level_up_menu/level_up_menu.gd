class_name LevelUpMenu
extends CanvasLayer

signal level_up_completed

var player: Entity

@onready var health_upgrade_button: Button = %HealthUpgradeButton
@onready var power_upgrade_button: Button = %PowerUpgradeButton
@onready var defense_upgrade_button: Button = %DefenseUpgradeButton


func setup(player: Entity) -> void:
	self.player = player
	var fighter: FighterComponent = player.fighter_component
	health_upgrade_button.text = "(a) Health (%d + 20 HP)" % fighter.max_hp
	power_upgrade_button.text = "(a) Strength (%d + 1 attack)" % fighter.power
	defense_upgrade_button.text = "(a) Agility (%d + 1 defense)" % fighter.defense
	health_upgrade_button.grab_focus()


func _on_health_upgrade_button_pressed() -> void:
	player.level_component.increase_max_hp()
	queue_free()
	level_up_completed.emit()

func _on_power_upgrade_button_pressed() -> void:
	player.level_component.increase_power()
	queue_free()
	level_up_completed.emit()

func _on_defense_upgrade_button_pressed() -> void:
	player.level_component.increase_defense()
	queue_free()
	level_up_completed.emit()
