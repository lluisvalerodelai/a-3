extends CanvasLayer

const Sketch := preload("res://scripts/presentation/sketch.gd")
const PaperPanel := preload("res://scripts/presentation/paper_panel.gd")

var main: Node2D
var footer: Label
var modal: PanelContainer
var modal_title: Label
var modal_body: Label
var action: Button
var chamber_menu: MenuButton
var elapsed := 0.0
var paused := false
var was_cleared := false
var notebook_theme: Theme


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	main = get_parent()
	notebook_theme = Sketch.theme()
	var chrome := Node2D.new()
	chrome.set_script(preload("res://scripts/presentation/notebook_chrome.gd"))
	add_child(chrome)
	chamber_menu = MenuButton.new()
	chamber_menu.flat = false
	chamber_menu.text = "Chambers  /  20"
	chamber_menu.position = Vector2(714, 28)
	chamber_menu.size = Vector2(176, 58)
	chamber_menu.theme = notebook_theme
	chamber_menu.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	chamber_menu.tooltip_text = "Choose a chamber. Changing chambers clears your recordings."
	add_child(chamber_menu)
	var chamber_popup := chamber_menu.get_popup()
	chamber_popup.theme = notebook_theme
	for index in main.LEVEL_SCENES.size():
		chamber_popup.add_item(main.get_chamber_title(index), index)
	chamber_popup.id_pressed.connect(_choose_chamber)
	chamber_popup.about_to_popup.connect(func(): get_tree().paused = true)
	chamber_popup.popup_hide.connect(func(): get_tree().paused = paused)
	_footer_labels()
	_build_modal()


func _footer_labels() -> void:
	var controls := [["move", 80], ["jump", 222], ["carry", 316], ["shoot", 436], ["throw", 567], ["save echo", 683], ["erase", 820], ["retry", 933], ["pause", 1048]]
	for control in controls:
		_label(control[0], Vector2(control[1], 680), 14, Sketch.INK)
	footer = _label("", Vector2(1142, 680), 13, Sketch.PENCIL)


func _build_modal() -> void:
	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.color = Color(0.24, 0.25, 0.21, 0.48)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.hide()
	add_child(shade)
	modal = PanelContainer.new()
	modal.set_script(PaperPanel)
	modal.taped = true
	modal.ink = Sketch.PENCIL
	modal.position = Vector2(370, 190)
	modal.custom_minimum_size = Vector2(540, 330)
	modal.theme = notebook_theme
	add_child(modal)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	modal.add_child(column)
	var illustration := Control.new()
	illustration.set_script(preload("res://scripts/presentation/modal_art.gd"))
	column.add_child(illustration)
	modal_title = Label.new()
	modal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_title.add_theme_font_override("font", Sketch.HAND)
	modal_title.add_theme_font_size_override("font_size", 46)
	modal_title.add_theme_color_override("font_color", Sketch.INK)
	column.add_child(modal_title)
	modal_body = Label.new()
	modal_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_body.add_theme_font_size_override("font_size", 15)
	modal_body.add_theme_color_override("font_color", Sketch.PENCIL)
	column.add_child(modal_body)
	action = Button.new()
	action.custom_minimum_size = Vector2(290, 46)
	action.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	action.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	action.pressed.connect(_activate)
	column.add_child(action)
	modal.hide()


func _label(value: String, point: Vector2, font_size: int, colour: Color, font: Font = Sketch.BOOK) -> Label:
	var label := Label.new()
	label.text = value
	label.position = point
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", colour)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _process(delta: float) -> void:
	if not get_tree().paused and not main.cleared:
		elapsed += delta
	footer.text = "M  sound %s" % ("off" if get_node("/root/Sound").muted else "on")
	if main.cleared != was_cleared:
		was_cleared = main.cleared
		_refresh_modal()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.physical_keycode == KEY_M:
		get_node("/root/Sound").toggle_mute()
		get_viewport().set_input_as_handled()
	if event.physical_keycode == KEY_ESCAPE and not main.cleared:
		paused = not paused
		get_tree().paused = paused
		_refresh_modal()
		get_viewport().set_input_as_handled()


func _refresh_modal() -> void:
	var show_modal: bool = paused or main.cleared
	main.memory_overlay.visible = not show_modal
	modal.visible = show_modal
	$Shade.visible = show_modal
	if not show_modal:
		action.release_focus()
		return
	var final_chamber: bool = main.current_level_index == main.LEVEL_SCENES.size() - 1
	modal_title.text = "A moment to breathe." if paused else ("Every echo made it home." if final_chamber else "A little closer.")
	modal_body.text = "Your echoes can wait.\nPress Escape when you're ready." if paused else ("Twenty chambers. Many selves. One escape.\nThank you for finding the way." if final_chamber else "Another page, another possibility.\nThe next chamber is waiting.")
	action.text = "Keep going  /  Esc" if paused else ("PLAY AGAIN  /  Enter" if final_chamber else "Next chamber  /  Enter")


func _activate() -> void:
	if paused:
		paused = false
		get_tree().paused = false
		_refresh_modal()
	else:
		main._advance_chamber()


func _choose_chamber(index: int) -> void:
	paused = false
	get_tree().paused = false
	main.start_chamber(index)
	was_cleared = false
	_refresh_modal()
