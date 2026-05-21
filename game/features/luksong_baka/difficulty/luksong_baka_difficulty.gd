class_name LuksongBakaDifficulty
extends Resource

@export var tier_name: String = ""
@export_range(2, 5) var sequence_length: int = 2
@export var time_per_level: Array[float] = [8.0, 7.0, 6.0, 5.0, 4.0]
