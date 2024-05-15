extends CollectableInfo
class_name CollectableMoneyInfo

@export var worth = 10.00

func collect(player: Player):
	player.add_money(worth)
