extends Node2D

const PILE_X_OFFSET = 35
const PILE_Y_OFFSET = 20
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_deck()
	deal_cards()
	place_stock_pile()

func init_deck():
	for suit in range(0,4):
		for value in range(0,13):
			var card = preload("res://scenes/Card.tscn").instantiate()
			card.value = value
			card.suit = suit
			GameManager.deck.append(card)
	seed(1)
	GameManager.deck.shuffle()

func deal_cards():
	for i in range(GameManager.NO_OF_PILES):
		var pile = GameManager.piles[i]
		for j in range(0 , i + 1):
			var card = GameManager.deck.pop_back()
			card.z_index = j
			if j == i:
				# flip the top-most card
				card.flip()
			card.position = GameManager.get_pile_position(i, j, PILE_X_OFFSET, PILE_Y_OFFSET)
			card.pile_id = i
			pile.append(card)
			add_child(card)

func place_stock_pile():
	for i in range(len(GameManager.deck) - 1):
		var card = GameManager.deck[i]
		card.stock = true
		card.position = GameManager.get_pile_position(0,0,PILE_X_OFFSET - 200, PILE_Y_OFFSET)
		add_child(card)
	
	#place the last card from set below for use
	var card = GameManager.deck[-1]
	card.stock = false
	card.flip()
	card.position = GameManager.get_pile_position(0,0,PILE_X_OFFSET - 200, PILE_Y_OFFSET + 200)
	add_child(card)
