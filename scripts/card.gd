extends Area2D

var value = 0
var suit = 0
var flipped:bool = false
var is_dragging:bool = false

var pile_id = null # Keep track on what pile is the card
var stock:bool = false # Keep track if the card is in stockpile
var is_mouse_entered:bool = false

@onready var sprite:Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_sprite()

func _input(event):
	if not is_mouse_entered:
		return
		
	if Input.is_action_just_pressed("left_click") and flipped:
		is_dragging = true
	elif event is  InputEventMouse and is_dragging:
		move_cards()
	elif Input.is_action_just_released("left_click") and is_dragging:
		is_dragging = false
		if !drop_card():
			reset_cards()

func update_sprite():
	if sprite:
		sprite.texture = get_texture()
	
func get_texture():
	if not flipped:
		return preload("res://card_assets/Back1.png")
		
	var res_path = "res://card_assets/{value}.{suit}.png".format({
			"value" : str(value + 1),
			"suit" : str(suit + 1)
	})
	
	return load(res_path)
	
func flip():
	flipped = !flipped
	update_sprite()

func move_cards():
	var pile = GameManager.piles[pile_id]
	var current_card_index = pile.find(self)
	if len(pile) > current_card_index:
		var cards_to_move = pile.slice(current_card_index,len(pile))
		for i in range(len(cards_to_move)):
			var card = cards_to_move[i]
			card.position = get_global_mouse_position()
	pass

func drop_card():
	pass

func reset_cards():
	pass

func _on_mouse_entered() -> void:
	is_mouse_entered = true;

func _on_mouse_exited() -> void:
	is_mouse_entered = false;
