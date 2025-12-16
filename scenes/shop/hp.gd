extends InteractiveArea2D

const HP_POTION_PRICE: int = 3

func _ready() -> void:
	super._ready()
	interacted.connect(_on_interacted)
	interaction_available.connect(_on_interaction_available)
	print("[HP Shop] Ready - waiting for player")

func _on_interaction_available() -> void:
	print("[HP Shop] Player entered area! Press F to buy HP potion (", HP_POTION_PRICE, " coins)")

func _on_interacted() -> void:
	print("[HP Shop] F pressed! Trying to purchase...")
	_try_purchase()

func _try_purchase() -> void:
	# Check if player has enough coins
	if GameManager.inventory_system.spend_coins(HP_POTION_PRICE):
		# Add health potion to inventory
		GameManager.inventory_system.add_health_potion(1)
		print("[HP Shop] Đã mua bình HP với giá ", HP_POTION_PRICE, " coins!")
	else:
		print("[HP Shop] Không đủ tiền! Cần ", HP_POTION_PRICE, " coins.")
