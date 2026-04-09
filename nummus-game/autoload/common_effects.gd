extends Node

class PlayerModifier: #temporary brah hehehehe OHAHHAH
	static func heal_health(hp: int):
		Globals.change_player_health(true, hp)
	static func give_money(money: int):
		Globals.change_money(true, money)
	static func give_shield(shield: int):
		Globals.change_shield(true, shield)
	static func multiply_stat(stats: Dictionary, stat_name: String, factor: float) -> Dictionary:
		if stats.find_key(stat_name) != null:
			stats[stat_name] *= factor
		return stats

class EnemyModifier:
	static func do_damage(dmg: int):
		Signalbus.change_enemy_health.emit(true, -dmg)
