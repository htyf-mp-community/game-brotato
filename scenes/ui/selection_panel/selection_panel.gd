extends Panel
class_name SelectionPanel

signal on_selection_completed

@export var players: Array[UnitStats]
@export var start_weapons: Array[ItemWeapon]

@onready var player_container: HBoxContainer = %PlayerContainer
@onready var weapon_container: HBoxContainer = %WeaponContainer

@onready var player_icon: TextureRect = %PlayerIcon
@onready var player_name: Label = %PlayerName
@onready var player_title: Label = %PlayerTitle
@onready var player_description: RichTextLabel = %PlayerDescription
@onready var continue_button: Button = $MarginContainer/VBoxContainer/Control/ContinueButtom

func _ready() -> void:
	for child in player_container.get_children(): child.queue_free()
	for child in weapon_container.get_children(): child.queue_free()
	
	show_player_info(false)
	load_players()
	load_weapons()
	_update_continue_button()


func load_players() -> void:
	if players.is_empty():
		return
	
	for player: UnitStats in players:
		var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		card.pressed.connect(_on_player_selected.bind(player))
		player_container.add_child(card)
		card.set_icon(player.icon)


func load_weapons() -> void:
	if start_weapons.is_empty():
		return
	
	for weapon: ItemWeapon in start_weapons:
		var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		card.pressed.connect(_on_weapon_selected.bind(weapon))
		weapon_container.add_child(card)
		card.icon = weapon.item_icon


func show_player_info(value: bool) -> void:
	player_icon.visible = value
	player_name.visible = value
	player_title.visible = value
	player_description.visible = value


func _on_player_selected(player: UnitStats) -> void:
	Global.main_player_selected = player
	show_player_info(true)
	
	player_icon.texture = player.icon
	player_name.text = player.name
	player_description.text = "[code]生命: [color=green]%s[/color]\n伤害: [color=green]%s[/color]\n移速: [color=green]%s[/color]\n幸运: [color=green]%s[/color]\n格挡几率: [color=green]%s%%[/color][/code]" % [player.health, player.damage, player.speed, player.luck, player.block_chance]
	_update_continue_button()


func _on_weapon_selected(weapon: ItemWeapon) -> void:
	Global.main_weapon_selected = weapon
	_update_continue_button()


func _update_continue_button() -> void:
	continue_button.disabled = Global.main_player_selected == null or Global.main_weapon_selected == null


func _on_continue_buttom_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	
	if Global.main_player_selected == null or Global.main_weapon_selected == null:
		return
	
	on_selection_completed.emit()
	hide()


func prepare_for_new_run() -> void:
	show_player_info(false)
	_update_continue_button()
	show()
