class_name PatinteroDifficulty
extends Resource
## Data container for one Patintero difficulty tier.
## Create .tres presets (Tutorial, Bronze, Silver, Champion) via the Godot editor.
## All values are tunable in the Inspector without touching code.

## Display name shown during the Intro state (e.g., "Bronze Grunt").
@export var tier_name: String = ""

## Number of directional keys in each sequence.
@export_range(2, 10) var sequence_length: int = 4

## Seconds each arrow takes to appear during the sequential reveal.
@export_range(0.1, 1.0, 0.05) var reveal_time_per_arrow: float = 0.5

## Seconds all arrows remain visible together after the reveal finishes.
@export_range(0.5, 10.0, 0.1) var hold_time: float = 3.0

## Seconds allowed per key during the execution phase.
## Total execution time = sequence_length × execution_time_per_key.
@export_range(0.5, 5.0, 0.1) var execution_time_per_key: float = 2.0

## Number of memory rounds required to clear each line.
## Array must have exactly 3 elements (one per line).
## Example: [1, 2, 3] means Line 1 needs 1 round, Line 2 needs 2, Line 3 needs 3.
@export var rounds_per_line: Array[int] = [1, 1, 2]

## Number of lives (hearts) the player starts with.
@export_range(1, 10) var max_lives: int = 3

## Calculated property: total execution time for this tier.
func get_execution_time() -> float:
	return sequence_length * execution_time_per_key

## Calculated property: total observation time for this tier.
func get_observation_time() -> float:
	return (reveal_time_per_arrow * sequence_length) + hold_time
