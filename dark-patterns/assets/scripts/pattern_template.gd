extends Resource
class_name DarkPattern
@export var name : String
@export var icon : Texture2D
@export_multiline var description : String
@export var duration : float
@export var size : float
@export var depression_effect : float
@export_range(0,1000000,1) var price : int
@export var effect : String
@export var color : Color
@export var placement_sound : AudioStream