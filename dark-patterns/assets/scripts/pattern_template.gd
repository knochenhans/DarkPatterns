extends Resource
class_name DarkPattern
@export var name : String
@export var icon : Texture2D
@export_multiline var description : String
@export var duration : float
@export var size : float
@export_range(0,1000000,1) var price : int
@export var effect : String
@export var color : Color
@export var placement_sound : AudioStream
@export var money_added: int
@export var use_collision: bool = true

# Effects
@export var depression_effect : int
@export var community_effect : int
