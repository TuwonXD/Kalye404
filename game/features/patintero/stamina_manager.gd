class_name StaminaManager
extends Node
## Tracks the player's remaining lives (hearts) during a Patintero match.
## Emits signals when lives are lost and when a game over occurs.

## Emitted when the player loses a life. [param remaining]: lives left.
signal life_lost(remaining: int)

## Emitted when lives reach zero.
signal game_over

## Maximum lives for the current match (set during setup).
var max_lives: int = 3

## Current remaining lives.
var current_lives: int = 3

## Initializes the stamina manager with the given number of lives.
## Call this at the start of a match or on retry.
func setup(lives: int) -> void:
	max_lives = lives
	current_lives = lives

## Deducts one life. Emits [signal life_lost], and [signal game_over] if lives hit zero.
func take_damage() -> void:
	current_lives -= 1
	life_lost.emit(current_lives)
	if current_lives <= 0:
		game_over.emit()

## Restores lives to max. Used when retrying the same tier.
func reset() -> void:
	current_lives = max_lives

## Returns true if the player still has lives remaining.
func is_alive() -> bool:
	return current_lives > 0
