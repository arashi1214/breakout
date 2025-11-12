extends Resource
class_name RandomTable

# 出現率由小到大排列
@export var items: Array[Dictionary] = [
	{"name": "A", "weight": 1},
	{"name": "B", "weight": 2},
	{"name": "C", "weight": 3},
	{"name": "D", "weight": 4},
]

func get_random() -> String:
	# 確認機率不為空
	if items.is_empty():
		return ""

	var total = 0
	for item in items:
		total += item.get("weight", 0)

	if total <= 0:
		return ""

	# 隨機抽取
	var r = randi() % total
	var cumulative = 0
	for item in items:
		cumulative += item.get("weight", 0)
		if r < cumulative:
			return str(item.get("name", ""))
	return str(items[-1].get("name", ""))
