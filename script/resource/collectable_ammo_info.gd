extends CollectableInfo
class_name CollectableAmmoInfo

@export var ammo: int = 13

func collect(player: Player):
	#player.add_money(worth)
	player.add_ammo(ammo)
	pass
