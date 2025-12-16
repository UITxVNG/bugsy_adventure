extends InteractiveArea2D

const MANA_POTION_PRICE: int = 5

func _ready() -> void:
	super._ready()
	interacted.connect(_on_interacted)
	interaction_available.connect(_on_interaction_available)
	print("[Mana Shop] Ready - waiting for player")

func _on_interaction_available() -> void:
	print("[Mana Shop] Player entered area! Press F to buy Mana potion (", MANA_POTION_PRICE, " coins)")

func _on_interacted() -> void:
	print("[Mana Shop] F pressed! Trying to purchase...")
	_try_purchase()

func _try_purchase() -> void:
	# Check if player has enough coins
	if GameManager.inventory_system.spend_coins(MANA_POTION_PRICE):
		# Add mana potion to inventory
		GameManager.inventory_system.add_mana_potion(1)
		print("[Mana Shop] Đã mua bình mana với giá ", MANA_POTION_PRICE, " coins!")
	else:
		print("[Mana Shop] Không đủ tiền! Cần ", MANA_POTION_PRICE, " coins.")
