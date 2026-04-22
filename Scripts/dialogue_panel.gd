extends CanvasLayer

var dialogue_lines = []
var current_line = 0

@onready var panel = $Panel
@onready var label = $Panel/RichTextLabel
@onready var continue_label = $Panel/ContinueLabel

signal dialogue_finished

func _ready():
	panel.hide()

func start_dialogue(lines: Array):
	dialogue_lines = lines
	current_line = 0
	if dialogue_lines.size() > 0:
		get_tree().paused = true
		panel.show()
		show_current_line()

func show_current_line():
	label.text = "[center]" + dialogue_lines[current_line] + "[/center]"
	continue_label.text = "Press SPACE to continue"

func _process(delta):
	if panel.visible and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack")):
		current_line += 1
		if current_line < dialogue_lines.size():
			show_current_line()
		else:
			end_dialogue()

func end_dialogue():
	panel.hide()
	get_tree().paused = false
	emit_signal("dialogue_finished")
	queue_free()
