extends Area2D

var value = 0
var suit = 0
var flipped:bool = false
var is_dragging:bool = false

var pile_id = null # Keep track on what pile is the card
var stock:bool = false # Keep track if the card is in stockpile
var is_mouse_entered:bool = false
var previous_position = []

@onready var sprite:Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_sprite()

func _input(event):
	if not is_mouse_entered or (suit == -1 and value == -1):
		return
		
	if Input.is_action_just_pressed("left_click") and stock:
		update_stock_top()
		return
		
	if Input.is_action_just_pressed("left_click") and flipped:
		is_dragging = true
		remember_card_positions()
	elif event is  InputEventMouseMotion and is_dragging:
		move_cards()
	elif Input.is_action_just_released("left_click") and is_dragging:
		is_dragging = false
		if !drop_card():
			reset_cards()

func update_sprite():
	if sprite:
		sprite.texture = get_texture()
		if suit == -1 and value == -1:
			sprite.hide()
	
func get_texture():
	if not flipped or (suit == -1 and value == -1):
		return preload("res://card_assets/Back1.png")
		
	var res_path = "res://card_assets/{value}.{suit}.png".format({
			"value" : str(value + 1),
			"suit" : str(suit + 1)
	})
	
	return load(res_path)
	
func flip():
	flipped = !flipped
	update_sprite()

func check_valid_move(card):
	if card.pile_id == null or card.pile_id == pile_id:
		return false
	
	var pile = GameManager.piles[card.pile_id]
	
	if len(pile) == 1 and card.suit == -1 and card.value == -1 :
		return true
		
	if not card.flipped:
		return false
	
	if value == pile[-1].value - 1 and suit % 2 != pile[-1].suit % 2 :
		return true
	 
	return false
	
func move_to_new_pile(new_card):
	if pile_id != null:
		var current_pile = GameManager.piles[pile_id]
		var current_card_index = current_pile.find(self)
		
		var new_pile = GameManager.piles[new_card.pile_id]
		
		# Move cards from current_pile to new_pile
		var cards_to_move = current_pile.slice(current_card_index, len(current_pile))
		for i in range(len(cards_to_move)):
			var card = cards_to_move[i]
			card.position = GameManager.get_pile_position(
				new_card.pile_id, len(new_pile) - 1,
				GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET
			)
			card.z_index = new_pile[-1].z_index + 1
			card.pile_id = new_card.pile_id
			new_pile.append(card)
		
		# Remove the top cards from old pile
		for i in range(len(cards_to_move)):
			current_pile.pop_back()
		
		# Flip the top-most card of previous pile after moving
		if len(current_pile) > 1:
			current_pile.back().flip()
		
	elif pile_id == null:
		var new_pile = GameManager.piles[new_card.pile_id]
		var card = GameManager.deck.pop_back()
		
		card.stock = false
		card.position = GameManager.get_pile_position(new_card.pile_id, len(new_pile) - 1, GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET)
		card.z_index = new_pile[-1].z_index + 1
		card.pile_id = new_card.pile_id
		new_pile.append(card)
		
		if len(GameManager.deck) > 1:
			var card_on_stock = GameManager.deck[-1]
			card_on_stock.stock = false
			card_on_stock.flip()
			card_on_stock.position = GameManager.get_pile_position(0,0, GameManager.PILE_X_OFFSET - 200, GameManager.PILE_Y_OFFSET + 200)
		
	previous_position = []
	if check_win():
		print("YOU WON!!!")
		
func update_stock_top():
	var current_stock_top = GameManager.deck.pop_back()
	current_stock_top.flip()
	current_stock_top.stock = true
	var pos = current_stock_top.position
	current_stock_top.position = GameManager.deck[0].position
	
	GameManager.deck.insert(0,current_stock_top)
	
	if len(GameManager.deck) > 1:
		var new_card = GameManager.deck[-1]
		new_card.stock = false
		new_card.flip()
		new_card.position = pos
		
func check_win():
	if len(GameManager.deck) > 0:
		return false
	for pile in GameManager.piles:
		for card in pile:
			if not card.flipped:
				return false
	return true

func move_cards():
	if pile_id == null :
		position = get_global_mouse_position()
		z_index = 100
		return
	
	var pile = GameManager.piles[pile_id]
	var current_card_index = pile.find(self)
	if len(pile) > current_card_index:
		var cards_to_move = pile.slice(current_card_index,len(pile))
		for i in range(len(cards_to_move)):
			var card = cards_to_move[i]
			card.position = get_global_mouse_position()			
			card.position.y += 30 * i
			card.z_index = 100 + i
	
func drop_card():
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("card"):
			if check_valid_move(area):
				move_to_new_pile(area)
				return true
	return false 

func remember_card_positions():
	previous_position = []
	if pile_id == null:
		previous_position.append({
			"position" : position
		})
		z_index = 100
		return
		
	var pile = GameManager.piles[pile_id]
	var current_card_index = pile.find(self)
	if len(pile) > current_card_index:
		var cards_to_move = pile.slice(current_card_index,len(pile))
		for card in cards_to_move :
			previous_position.append({
				"position" : card.position
			})
	
func reset_cards():
	# stock card
	if pile_id == null:
		position = previous_position[0]["position"]
		z_index = 1
	else:		
		var pile = GameManager.piles[pile_id]
		var current_card_index = pile.find(self)
		if len(pile) > current_card_index:
			var cards_to_move = pile.slice(current_card_index, len(pile))
			for i in range(len(previous_position)):
				var card = cards_to_move[i]
				card.position = previous_position[i]["position"]
				card.z_index = pile[current_card_index - 1].z_index + i + 1
			
	previous_position = []

func _on_mouse_entered() -> void:
	is_mouse_entered = true;

func _on_mouse_exited() -> void:
	is_mouse_entered = false;
