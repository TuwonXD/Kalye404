class_name SequenceGenerator
## Generates random directional sequences for the Patintero memory challenge.
## This is a pure logic class with no scene dependency.

## The four possible directions a sequence can contain.
const DIRECTIONS: Array[String] = ["up", "down", "left", "right"]

## Generates a random sequence of directional strings.
## [param length]: Number of directions in the sequence.
## Returns: Array[String] — e.g., ["up", "left", "down", "right", "up"]
static func generate(length: int) -> Array[String]:
	var sequence: Array[String] = []
	for i in range(length):
		sequence.append(DIRECTIONS[randi() % DIRECTIONS.size()])
	return sequence
