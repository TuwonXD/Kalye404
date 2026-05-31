class_name PatinteroGame
extends Node2D
## Root state machine controller for the Patintero Kalye Challenge.
## Attach to: PatinteroGame (root Node2D of patintero.tscn)

# ── Result Signal ─────────────────────────────────────────────────────────────

## Emitted when the match ends. Connect from overworld in Session E.
signal match_ended(result: String)

## Emitted when the tutorial overlay is clicked.
signal tutorial_clicked

var tutorial_overlay: CanvasLayer
var tutorial_root: Control
var tutorial_label: Label

# ── State Enum ────────────────────────────────────────────────────────────────

enum State { INTRO, PRE_DUEL, OBSERVATION, EXECUTION, TAGGED, FADE_OUT, ADVANCING, VICTORY, GAME_OVER }
var _state: State = State.INTRO

# ── Config ────────────────────────────────────────────────────────────────────

## Assign a .tres preset here in the Inspector for F6 testing.
@export var difficulty: PatinteroDifficulty

# ── Progress Tracking ─────────────────────────────────────────────────────────

var _current_line: int = 0   # 0-indexed. 0 = Line 1, 1 = Line 2, 2 = Line 3.
var _current_round: int = 0  # 0-indexed within current line.
var _current_sequence: Array[String] = []

# ── Timing Constants ──────────────────────────────────────────────────────────

const FADE_DURATION := 0.4
const RESULT_PAUSE := 0.8
const INTRO_DURATION := 2.0
const PRE_DUEL_PAUSE := 1.0

## Center position of the guard Sprite2D at rest.
## (ColorRect was offset 476,120 → 676,370 — center = 576,245)
const GUARD_START_POS := Vector2(576.0, 200.0)

# ── Node References ───────────────────────────────────────────────────────────

@onready var current_guard: Sprite2D        = $GameView/CurrentGuard
@onready var totoy: Sprite2D               = $GameView/TotoySprite
#@onready var totoy: ColorRect               = $GameView/Totoy
@onready var progress_label: Label          = $UI/UIRoot/ProgressLabel
@onready var stamina_display: HBoxContainer = $UI/UIRoot/StaminaDisplay
@onready var seq_display: SequenceDisplay   = $UI/UIRoot/SequenceDisplay
@onready var input_feedback: HBoxContainer  = $UI/UIRoot/InputFeedback
@onready var timer_bar: ProgressBar         = $GameView/TimerBar
@onready var result_label: Label            = $UI/UIRoot/ResultLabel
@onready var game_over_screen: PanelContainer = $UI/UIRoot/GameOverScreen
@onready var victory_screen: PanelContainer   = $UI/UIRoot/VictoryScreen
@onready var fade_rect: ColorRect           = $FadeOverlay/FadeRoot/FadeRect
@onready var stamina_mgr: StaminaManager    = $StaminaManager
@onready var input_hdlr: InputHandler       = $InputHandler

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Connect signals from child systems.
	input_hdlr.sequence_completed.connect(_on_sequence_completed)
	input_hdlr.input_failed.connect(_on_input_failed)
	input_hdlr.time_expired.connect(_on_time_expired)
	input_hdlr.key_pressed.connect(_on_key_pressed)
	stamina_mgr.life_lost.connect(_on_life_lost)
	stamina_mgr.game_over.connect(_on_game_over_signal)

	# Initial UI state.
	result_label.visible = false
	game_over_screen.visible = false
	victory_screen.visible = false
	timer_bar.value = 1.0
	fade_rect.modulate.a = 0.0

	_setup_tutorial_overlay()

	# Fallback if no difficulty assigned in Inspector.
	if difficulty == null:
		push_warning("PatinteroGame: No difficulty assigned. Using default values.")
		difficulty = PatinteroDifficulty.new()

	stamina_mgr.setup(difficulty.max_lives)
	_update_stamina_display()
	_change_state(State.INTRO)

func _process(_delta: float) -> void:
	# Poll timer fraction every frame to drive the TimerBar.
	if _state == State.EXECUTION and input_hdlr._active:
		timer_bar.value = input_hdlr.get_time_fraction()
		# Timer Pulse: flash red when under 2 seconds
		if input_hdlr._time_remaining < 2.0 and input_hdlr._time_remaining > 0.0:
			timer_bar.modulate = Color.RED if int(Engine.get_frames_drawn() / 10) % 2 == 0 else Color.WHITE
		else:
			timer_bar.modulate = Color.BLACK
	elif _state != State.EXECUTION:
		timer_bar.modulate = Color.BLACK

# ── Tutorial System ───────────────────────────────────────────────────────────

func _setup_tutorial_overlay() -> void:
	tutorial_overlay = CanvasLayer.new()
	tutorial_overlay.layer = 100 # Ensure it's on top of everything
	tutorial_overlay.visible = false
	add_child(tutorial_overlay)
	
	tutorial_root = Control.new()
	tutorial_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.add_child(tutorial_root)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_root.add_child(bg)
	
	tutorial_label = Label.new()
	tutorial_label.add_theme_font_size_override("font_size", 32)
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.custom_minimum_size = Vector2(800, 0)
	tutorial_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tutorial_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	tutorial_label.set_anchors_preset(Control.PRESET_CENTER)
	tutorial_root.add_child(tutorial_label)
	
	var click_hint = Label.new()
	click_hint.text = "Press Space/Enter or Click to continue..."
	click_hint.add_theme_font_size_override("font_size", 24)
	click_hint.modulate = Color.GRAY
	click_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	click_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	click_hint.grow_vertical = Control.GROW_DIRECTION_BOTH
	click_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	click_hint.position.y -= 50
	tutorial_root.add_child(click_hint)

func _play_tutorial_message(text: String) -> void:
	if difficulty.tier_name != "Tutorial Grunt":
		return
	
	tutorial_label.text = text
	tutorial_root.modulate.a = 0.0 # Start completely transparent
	tutorial_overlay.visible = true
	
	# Fade In
	var tween_in := create_tween()
	tween_in.tween_property(tutorial_root, "modulate:a", 1.0, FADE_DURATION).set_trans(Tween.TRANS_SINE)
	await tween_in.finished
	
	# Wait for the player to click anywhere
	await self.tutorial_clicked
	
	# Fade Out
	var tween_out := create_tween()
	tween_out.tween_property(tutorial_root, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_SINE)
	await tween_out.finished
	
	tutorial_overlay.visible = false

func _input(event: InputEvent) -> void:
	if tutorial_overlay != null and tutorial_overlay.visible:
		var clicked = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
		var pressed = event.is_action_pressed("ui_accept")
		if clicked or pressed:
			tutorial_clicked.emit()
			get_viewport().set_input_as_handled()

# ── State Machine ─────────────────────────────────────────────────────────────

func _change_state(new_state: State) -> void:
	_state = new_state
	match new_state:
		State.INTRO:        _enter_intro()
		State.PRE_DUEL:     _enter_pre_duel()
		State.OBSERVATION:  _enter_observation()
		State.EXECUTION:    _enter_execution()
		State.TAGGED:       _enter_tagged()
		State.FADE_OUT:     _enter_fade_out()
		State.ADVANCING:    _enter_advancing()
		State.VICTORY:      _enter_victory()
		State.GAME_OVER:    _enter_game_over()

# ── INTRO ─────────────────────────────────────────────────────────────────────

func _enter_intro() -> void:
	_current_line = 0
	_current_round = 0
	_clear_input_feedback()
	_update_guard_visual()
	progress_label.text = ""
	result_label.visible = false
	game_over_screen.visible = false
	victory_screen.visible = false
	
	# Theatrical Intro Splash
	var intro_label := Label.new()
	intro_label.text = difficulty.tier_name
	intro_label.add_theme_font_size_override("font_size", 64)
	intro_label.add_theme_color_override("font_color", difficulty.tier_color)
	intro_label.add_theme_constant_override("outline_size", 6)
	intro_label.add_theme_color_override("font_outline_color", Color.BLACK)
	intro_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_label.size = Vector2(1152, 100)
	intro_label.position.y = 250
	intro_label.position.x = 1152 # Start offscreen right
	$UI/UIRoot.add_child(intro_label)
	
	var tween := create_tween()
	tween.tween_property(intro_label, "position:x", 0.0, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_interval(1.0)
	tween.tween_property(intro_label, "position:x", -1152.0, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await tween.finished
	intro_label.queue_free()
	
	_change_state(State.PRE_DUEL)

# ── PRE_DUEL ──────────────────────────────────────────────────────────────────

func _enter_pre_duel() -> void:
	_clear_input_feedback()
	result_label.visible = false
	timer_bar.value = 1.0

	var line_num := _current_line + 1
	var round_num := _current_round + 1
	var total_rounds: int = difficulty.rounds_per_line[_current_line]
	progress_label.text = "Line %d/3 — Round %d/%d" % [line_num, round_num, total_rounds]

	await get_tree().create_timer(PRE_DUEL_PAUSE).timeout
	
	if difficulty.tier_name == "Tutorial Grunt" and _current_line == 0 and _current_round == 0:
		await _play_tutorial_message("Welcome to Patintero!\n\nYou must pass the guard to advance to the next line.")
		
	_current_sequence = SequenceGenerator.generate(difficulty.sequence_length)
	_change_state(State.OBSERVATION)

# ── OBSERVATION ───────────────────────────────────────────────────────────────

func _enter_observation() -> void:
	# Pre-Observation Alert ("Ready...")
	var hop_tween := create_tween()
	var g_y = current_guard.position.y
	# Slower hop so it doesn't feel too fast
	hop_tween.tween_property(current_guard, "position:y", g_y - 30.0, 0.3).set_trans(Tween.TRANS_SINE)
	hop_tween.tween_property(current_guard, "position:y", g_y, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	var alert := Label.new()
	alert.text = "Ready..."
	alert.add_theme_font_size_override("font_size", 48)
	alert.add_theme_constant_override("outline_size", 6)
	alert.add_theme_color_override("font_outline_color", Color.BLACK)
	alert.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert.size = Vector2(1152, 100)
	alert.position.y = 280
	$UI/UIRoot.add_child(alert)
	
	var a_tween := create_tween()
	a_tween.tween_property(alert, "modulate:a", 1.0, 0.2)
	a_tween.tween_interval(0.6)
	a_tween.tween_property(alert, "modulate:a", 0.0, 0.2)
	await a_tween.finished
	alert.queue_free()

	if difficulty.tier_name == "Tutorial Grunt" and _current_line == 0 and _current_round == 0:
		await _play_tutorial_message("Watch the guard's pattern carefully...\n\nMemorize the sequence of arrows!")

	# show_sequence is a coroutine — awaiting it waits for reveal + hold to finish.
	await seq_display.show_sequence(
		_current_sequence,
		difficulty.reveal_time_per_arrow,
		difficulty.hold_time
	)
	_change_state(State.EXECUTION)

# ── EXECUTION ─────────────────────────────────────────────────────────────────

func _enter_execution() -> void:
	if difficulty.tier_name == "Tutorial Grunt" and _current_line == 0 and _current_round == 0:
		await _play_tutorial_message("Now it's your turn!\n\nPress the arrow keys in the exact order before the chalk line disappears!")

	# Pre-Execution Alert ("GO!")
	var go_label := Label.new()
	go_label.text = "GO!"
	go_label.add_theme_font_size_override("font_size", 80)
	go_label.add_theme_constant_override("outline_size", 6)
	go_label.add_theme_color_override("font_outline_color", Color.BLACK)
	go_label.modulate = Color.GREEN
	go_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_label.size = Vector2(1152, 100)
	go_label.position.y = 260
	go_label.scale = Vector2.ZERO
	go_label.pivot_offset = Vector2(1152/2.0, 50)
	$UI/UIRoot.add_child(go_label)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(go_label, "scale", Vector2.ONE, 0.3)
	tween.tween_property(go_label, "modulate:a", 0.0, 0.3).set_delay(0.2)
	await tween.finished
	go_label.queue_free()

	# Transitions happen via signal callbacks below.
	input_hdlr.start(_current_sequence, difficulty.get_execution_time())

func _on_sequence_completed() -> void:
	if _state != State.EXECUTION:
		return
	_current_round += 1
	var total_rounds: int = difficulty.rounds_per_line[_current_line]
	if _current_round < total_rounds:
		_show_result("✓ Round cleared!", true)
		await get_tree().create_timer(RESULT_PAUSE).timeout
		_change_state(State.PRE_DUEL)
	else:
		_show_result("✓ Line cleared!", true)
		await get_tree().create_timer(RESULT_PAUSE).timeout
		_change_state(State.ADVANCING)

func _on_input_failed(_wrong: String) -> void:
	if _state != State.EXECUTION:
		return
	_change_state(State.TAGGED)

func _on_time_expired() -> void:
	if _state != State.EXECUTION:
		return
	_change_state(State.TAGGED)

func _on_key_pressed(direction: String, was_correct: bool) -> void:
	# Add a ✓/✗ label to InputFeedback for each key press.
	var label := Label.new()
	
	label.text = "✓" if was_correct else "✗"
	label.add_theme_font_size_override("font_size", 40)
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_color", Color.GREEN if was_correct else Color.RED)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	input_feedback.add_child(label)

	# Juice: Advanced Character reactions
	var totoy_start_x = 575.0
	var totoy_start_y = 470.0
	var shift_x = 30.0 if direction == "right" else (-30.0 if direction == "left" else 0.0)
	var shift_y = 30.0 if direction == "down" else (-30.0 if direction == "up" else 0.0)
	
	# Omni-directional Twitch for Totoy
	var tween := create_tween()
	tween.tween_property(totoy, "position", Vector2(totoy_start_x + shift_x, totoy_start_y + shift_y), 0.1)
	tween.tween_property(totoy, "position", Vector2(totoy_start_x, totoy_start_y), 0.1)
	
	# Delayed, wider guard reaction
	if shift_x != 0.0 or shift_y != 0.0:
		var g_tween := create_tween()
		if shift_x != 0.0:
			var guard_shift = shift_x * 1.5 # Wider sweep
			g_tween.tween_property(current_guard, "position:x", GUARD_START_POS.x + guard_shift, 0.1).set_delay(0.05)
			g_tween.tween_property(current_guard, "position:x", GUARD_START_POS.x, 0.15)
		else:
			# Flinch opposite to Totoy's Y movement (e.g. Totoy moves Up, Guard flinches Down/Forward)
			var guard_shift_y = shift_y * -0.6
			g_tween.tween_property(current_guard, "position:y", GUARD_START_POS.y + guard_shift_y, 0.1).set_delay(0.05)
			g_tween.tween_property(current_guard, "position:y", GUARD_START_POS.y, 0.15)

# ── TAGGED ────────────────────────────────────────────────────────────────────

func _enter_tagged() -> void:
	_show_result("✗ Tagged!", false)
	stamina_mgr.take_damage()
	
	# Tagged Evasion Animation (Guard physically intercepts Totoy)
	var last_dir = _current_sequence.back() if _current_sequence.size() > 0 else "right"
	var dodge_x = -150.0 if (last_dir == "left" or last_dir == "down") else 150.0
	
	var t_tween := create_tween()
	t_tween.tween_property(totoy, "position:x", totoy.position.x + dodge_x, 0.4).set_trans(Tween.TRANS_SINE)
	t_tween.parallel().tween_property(totoy, "position:y", totoy.position.y - 150.0, 0.4).set_trans(Tween.TRANS_SINE)
	
	var g_tween := create_tween()
	var tag_x = (totoy.position.x + dodge_x) - 25.0 # Center guard on Totoy's intended dodge path
	# Guard only moves horizontally to block, maintaining Y position
	g_tween.tween_property(current_guard, "position:x", tag_x, 0.3).set_trans(Tween.TRANS_EXPO)
	
	# Screen Shake
	var shake_tween := create_tween()
	for i in range(6):
		var offset = Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
		shake_tween.tween_property($GameView, "position", offset, 0.05)
	shake_tween.tween_property($GameView, "position", Vector2.ZERO, 0.05)
	# Transitions handled by _on_life_lost and _on_game_over_signal.

func _on_life_lost(_remaining: int) -> void:
	_update_stamina_display()
	# Only transition if still alive — game over is handled separately.
	if _state == State.TAGGED and stamina_mgr.is_alive():
		await get_tree().create_timer(RESULT_PAUSE).timeout
		_change_state(State.FADE_OUT)

func _on_game_over_signal() -> void:
	if _state != State.TAGGED:
		return
	_update_stamina_display()
	await get_tree().create_timer(RESULT_PAUSE).timeout
	_change_state(State.GAME_OVER)

# ── FADE_OUT (tagged, retry same line) ───────────────────────────────────────

func _enter_fade_out() -> void:
	await _fade(0.0, 1.0)      # Fade to black.
	_current_round = 0         # Reset this line's rounds.
	_clear_input_feedback()
	result_label.visible = false
	
	# Fix: Reset timer visually while screen is black
	timer_bar.value = 1.0
	timer_bar.modulate = Color.BLACK
	
	# Reset characters from the Tagged Evasion animation
	current_guard.position = GUARD_START_POS
	totoy.position = Vector2(575.0, 470.0)
	
	await _fade(1.0, 0.0)      # Fade back in.
	_change_state(State.PRE_DUEL)

# ── ADVANCING (line cleared, move to next) ────────────────────────────────────

func _enter_advancing() -> void:
	# Evasion Animation: Totoy dodges diagonally past the guard.
	var last_dir = _current_sequence.back() if _current_sequence.size() > 0 else "right"
	var dodge_x = -250.0 if (last_dir == "left" or last_dir == "down") else 250.0
	
	var tween := create_tween()
	# Dodge wide enough to clear the guard entirely
	tween.tween_property(totoy, "position:x", totoy.position.x + dodge_x, 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(totoy, "position:y", totoy.position.y - 300.0, 0.4).set_trans(Tween.TRANS_SINE)
	await tween.finished

	if _current_line + 1 >= 3:
		# All 3 lines cleared, instantly trigger victory without fading to black
		_change_state(State.VICTORY)
		return

	await _fade(0.0, 1.0)      # Fade to black (hidden reset happens here).
	_current_line += 1
	_current_round = 0
	_clear_input_feedback()
	result_label.visible = false
	
	# Fix: Reset timer visually while screen is black
	timer_bar.value = 1.0
	timer_bar.modulate = Color.BLACK

	# Reset Totoy and swap guard (behind the fade).
	totoy.position.x = 575.0
	totoy.position.y = 470.0
	_update_guard_visual()
	await _fade(1.0, 0.0)      # Fade back in.
	_change_state(State.PRE_DUEL)

# ── VICTORY ───────────────────────────────────────────────────────────────────

func _enter_victory() -> void:
	match_ended.emit("win")

## Called by the "Continue" button on VictoryScreen (Now Unused, but kept for safety).
func continue_match() -> void:
	pass

# ── GAME_OVER ─────────────────────────────────────────────────────────────────

func _enter_game_over() -> void:
	match_ended.emit("lose")

## Called by the "Try Again" button on GameOverScreen.
func retry() -> void:
	stamina_mgr.reset()
	_update_stamina_display()
	game_over_screen.visible = false
	_change_state(State.INTRO)

## Called by the "Quit" button on GameOverScreen.
func quit_match() -> void:
	match_ended.emit("lose")

# ── Helpers ───────────────────────────────────────────────────────────────────

func _fade(from_alpha: float, to_alpha: float) -> void:
	fade_rect.modulate.a = from_alpha
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", to_alpha, FADE_DURATION)
	await tween.finished

func _show_result(text: String, success: bool) -> void:
	result_label.text = text
	result_label.modulate = Color.GREEN if success else Color.RED
	
	result_label.add_theme_font_size_override("font_size", 48)
	result_label.add_theme_constant_override("outline_size", 6)
	result_label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# Overwrite the input feedback position
	result_label.position.y = input_feedback.position.y
	result_label.visible = true
	_clear_input_feedback() # Clear the ✓/✗ marks so they are replaced

func _show_big_alert(text: String, duration: float = 1.0) -> void:
	var alert := Label.new()
	alert.text = text
	alert.add_theme_font_size_override("font_size", 64)
	alert.add_theme_constant_override("outline_size", 8)
	alert.add_theme_color_override("font_outline_color", Color.BLACK)
	alert.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert.size = Vector2(1152, 100)
	alert.position.y = 280
	$UI/UIRoot.add_child(alert)
	
	var a_tween := create_tween()
	a_tween.tween_property(alert, "modulate:a", 1.0, 0.2)
	a_tween.tween_interval(duration)
	a_tween.tween_property(alert, "modulate:a", 0.0, 0.2)
	a_tween.tween_callback(alert.queue_free)
	await a_tween.finished

func _update_stamina_display() -> void:
	for child in stamina_display.get_children():
		child.queue_free()
	for i in range(stamina_mgr.max_lives):
		var heart := Label.new()
		heart.text = "❤️" if i < stamina_mgr.current_lives else "🖤"
		heart.add_theme_font_size_override("font_size", 32)
		stamina_display.add_child(heart)

func _clear_input_feedback() -> void:
	for child in input_feedback.get_children():
		child.queue_free()

func _update_guard_visual() -> void:
	# If the difficulty has textures assigned, swap the sprite.
	# Falls back to invisible if textures aren't set yet (safe during dev).
	if difficulty.guard_textures.size() > _current_line:
		var tex: Texture2D = difficulty.guard_textures[_current_line]
		if tex != null:
			current_guard.texture = tex
			
			# Auto-normalize scale based on the AtlasTexture region size!
			# Standard grunts have a region height of ~344. Kapitana Kat is ~685.
			# This math shrinks Kat automatically so she visually matches the 344 standard.
			var base_scale = difficulty.guard_scale
			var scale_ratio = 344.0 / float(tex.get_height())
			current_guard.scale = base_scale * scale_ratio
				
			current_guard.visible = true
		else:
			current_guard.visible = false
	else:
		# No textures assigned — hide guard (dev placeholder)
		current_guard.visible = false

## Called from the overworld in Session E to set the difficulty before starting.
func setup(selected_difficulty: PatinteroDifficulty) -> void:
	difficulty = selected_difficulty
