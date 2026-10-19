extends Node2D

var coins := 0
var keys := 0
var trophy := false
var sword := false
var oil := false
var lantern := false
var gold_key := false
var key_bought := false
var won_race := false
var stats_increased := false
var removed_lock_cave := false
var removed_lock_gold := false
var skeleton_hit := false

func update_screen():
	$Coins/Label.text = str(coins)
	
	$Keys.visible = keys > 0
	$Keys/Label.visible = keys > 0
	$Keys/Label.text = str(keys)
	
	$Trophy.visible = trophy
	$Lantern.visible = lantern
	$Oil.visible = oil
	$Sword.visible = sword
	$GoldKey.visible = gold_key

func set_inventory(inventory):
	coins = inventory.coins
	keys = inventory.keys
	trophy = inventory.trophy
	sword = inventory.sword
	oil = inventory.oil
	lantern = inventory.lantern
	key_bought = inventory.key_bought
	won_race =  inventory.won_race
	stats_increased = inventory.stats_increased
	removed_lock_cave = inventory.removed_lock_cave
	gold_key = inventory.gold_key
	removed_lock_gold = inventory.removed_lock_gold
	skeleton_hit = inventory.skeleton_hit
	
	update_screen()
	

func get_inventory():
	return {"coins": coins, "keys": keys, "trophy": trophy, "sword": sword, "oil": oil, "lantern": lantern, "gold_key": gold_key, "key_bought": key_bought, "won_race": won_race, "stats_increased": stats_increased, "removed_lock_cave": removed_lock_cave, "removed_lock_gold": removed_lock_gold, "skeleton_hit": skeleton_hit}
