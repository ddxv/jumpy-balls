# GlobalFunctions.gd
extends Node


func add_to_group_recursive(node, group_name):
	node.add_to_group(group_name)
	for child in node.get_children():
		add_to_group_recursive(child, group_name)
