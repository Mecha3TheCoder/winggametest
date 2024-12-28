extends Control


@onready var start_menu: Control = $"Start Menu"
@onready var wait_screen: Control = $"Wait Screen"
@onready var select_menu: Control = $"Select Menu"
@onready var box_master: HBoxContainer = $"Select Menu/VBoxContainer/HBoxMaster"
@onready var box_player: HBoxContainer = $"Select Menu/VBoxContainer/HBoxPlayer"

@onready var btn_confirm: TextureButton = $"Select Menu/TextureButton"

@onready var master_child_array = box_master.get_children()
@onready var player_child_array = box_player.get_children()

@onready var sprite1: Sprite2D = $"Select Menu/Sprite2D"
@onready var sprite2: Sprite2D = $"Select Menu/Sprite2D2"


@onready var address_entry = $"%address_entry"


const CONFIRM_TOOLTIP = "You must have one of each."
const BLUE_BOX = preload("res://AsepriteTextures/BlueBox.aseprite")
const GREEN_BOX = preload("res://AsepriteTextures/GreenBox.aseprite")
const RED_BOX = preload("res://AsepriteTextures/RedBox.aseprite")
const YELLOW_BOX = preload("res://AsepriteTextures/YellowBox.aseprite")
const PORT = 63036
#const PORT = 25568


var enet_peer = ENetMultiplayerPeer.new()
var ready_count = 0


#useing side to mark master/player, 0 nether, 1 master, 2 player
#var side = 0


#make sure everything is set right
func _ready() -> void:
	#start_menu.show()
	#select_menu.hide()
	#wait_screen.hide()
	change_menu("START")
	#btn_confirm.disabled = true
	#btn_confirm.tooltip_text = CONFIRM_TOOLTIP


func _add_player():
	#player.name = str(id)
	#call_deferred("add_child", player)
	#if id == 1:
		#p1_id = self.multiplayer.get_unique_id()
		#print(p1_id)
	#elif id == 2:
		#p2_id = self.multiplayer.get_unique_id()
		#print(p2_id)
	#else:
		#print("Error in _add_player, main_menu")
	
	pass


#RPC change scene, best way I found to sync it
@rpc("any_peer","call_local")
func change_menu(set_to):
	match set_to:
		"START":
			start_menu.show()
			wait_screen.hide()
			select_menu.hide()
		
		"WAIT":
			start_menu.hide()
			wait_screen.show()
			select_menu.hide()
		
		"SELECT":
			start_menu.hide()
			wait_screen.hide()
			select_menu.show()


#jank 2 player logic, two functions two players, p1 is server, p2 is not server
@rpc("any_peer","call_local")
func select_char1(set_to):
	sprite1.frame = set_to


@rpc("any_peer","call_local")
func select_char2(set_to):
	sprite2.frame = set_to


#ready up check and move on
@rpc("any_peer","call_local")
func ready_up():
	ready_count = ready_count + 1
	if ready_count >= 2:
		#all_ready.emit()
		get_tree().change_scene_to_file("res://game.tscn")


#start server and stall for p2, set p1 to a wait screen
func _on_btn_host_pressed() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	#multiplayer.peer_connected.connect(start)
	change_menu("WAIT")
	#sprite_window = sprite1


#join server, set both players to selection
func _on_btn_join_pressed() -> void:
	print(address_entry.text)
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	await multiplayer.connected_to_server
	change_menu.rpc("SELECT")
	#sprite_window = sprite2


func _on_btn_join_local_pressed() -> void:
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	await multiplayer.connected_to_server
	change_menu.rpc("SELECT")
	#sprite_window = sprite2


#func change_side(side):
	##side = change_to
	#if side == 2:
		#for i in master_child_array:
			#i.disabled = false
		#for i in player_child_array:
			#i.disabled = true
			#
	#elif side == 1:
		#for i in master_child_array:
			#i.disabled = true
		#for i in player_child_array:
			#i.disabled = false
	#elif side == 0:
		#pass
	#else:
		#print("error in func change_side")


#top selection
func _on_texture_button_t_pressed() -> void:
	#change_side(1)
	#sprite1.texture = RED_BOX
	#sprite_window.frame = 0
	if multiplayer.is_server():
		select_char1.rpc(1)
	elif not multiplayer.is_server():
		select_char2.rpc(1)
	Autoloader.selection = "Red"


#bottom selection
func _on_texture_button_b_pressed() -> void:
	#change_side(2)
	#sprite_window.frame = 1
	if multiplayer.is_server():
		select_char1.rpc(0)
	elif not multiplayer.is_server():
		select_char2.rpc(0)
	Autoloader.selection = "Blue"


#ready butten
func _on_texture_button_pressed() -> void:
	if sprite1.frame == sprite2.frame:
		$"Select Menu/RichTextLabel".show()
	elif sprite1.frame != sprite2.frame:
		ready_up.rpc()
		$"Select Menu/TextureButton".disabled = true
		$"Select Menu/RichTextLabel".text = "Waiting..."
		$"Select Menu/RichTextLabel".show()
