
extends Control

var inventory

onready var player = Global_vars.player

const capacity_default = Color(1, 1, 1)
const capacity_mid = Color(1, 1, 0)
const capacity_danger = Color(1, 0.15, 0.15)

var curr_inv_page = 0
const items_per_page = 4

const layout_amount = 4

func _ready():
	inventory = get_node("inventory")
	set_process_input(true)
	get_node("inventory/items/left").connect("pressed", self, "_inv_page_down")
	get_node("inventory/items/right").connect("pressed", self, "_inv_page_up")
	
	var layouts = inventory.get_node("layout-panel/layouts")
	for i in range(layout_amount):
		var b = Button.new()
		b.set_text(str(i + 1))
		b.set_custom_minimum_size(Vector2(0, layouts.get_size().y/layout_amount - 5))
		layouts.add_child(b)
		
	
func _input(event):
	if event.is_action_released("inventory_toggle"):
		if inventory.is_visible():
			inventory.hide()
		else:
			update_inventory()
			inventory.popup()
			
func update_inventory():
	var capacity = inventory.get_node("items/capacity-label")
	var curr_w = player.inventory.get_weight()
	var max_w = player.inventory.weight_capacity
	var percentage = curr_w * 1.0 / max_w
	capacity.clear()
	capacity.push_align(capacity.ALIGN_RIGHT)
	if percentage < 0.5:
		capacity.push_color(capacity_default)
	elif percentage < 0.75:
		capacity.push_color(capacity_mid)
	else:
		capacity.push_color(capacity_danger)
	capacity.add_text(str(curr_w))
	capacity.push_color(capacity_default)
	capacity.add_text("/" + str(max_w) + "kg")
	
	var box = inventory.get_node("items/items-box")
	for node in box.get_children():
		box.remove_child(node)
		
	var page_amount = ((player.inventory.items.size()-1)/items_per_page) + 1
	curr_inv_page = min(max(0, curr_inv_page), page_amount-1)
	var left = inventory.get_node("items/left")
	var right = inventory.get_node("items/right")
	left.set_disabled(curr_inv_page <= 0)
	right.set_disabled(curr_inv_page >= page_amount-1)
	
	inventory.get_node("items/page-label").set_text(str(curr_inv_page + 1) + "/" + str(page_amount))
	
		
	for idx in range(4):
		var previous = curr_inv_page * items_per_page
		if player.inventory.items.size() - 1 < previous + idx:
			break
		var item = player.inventory.items[previous + idx]
		var button = Button.new()
		button.set_v_size_flags(SIZE_FILL)
		button.set_h_size_flags(SIZE_EXPAND_FILL)
		button.set_custom_minimum_size(Vector2(0, box.get_size().y/items_per_page-5))
		button.set_text(item.name + ", " + str(item.weight) + "kg")
		box.add_child(button)
		button.connect("pressed", self, "_inventory_button_pressed", [idx + previous])

func _inventory_button_pressed(index):
	player.inventory.items.remove(index)
	update_inventory()
	
func _inv_page_up():
	curr_inv_page += 1
	update_inventory()
	
func _inv_page_down():
	curr_inv_page -= 1
	update_inventory()