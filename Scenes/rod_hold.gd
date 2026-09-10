extends Sprite2D

# --- pose ---
@export var hold_angle: float = -15.0     # resting lean once the fish is on
@export var lean_in_time: float = 0.4     # seconds to ease from vertical into the lean
@export var bob_angle: float = 6.0        # how far it rocks each way from hold_angle
@export var bob_time: float = 0.6         # seconds per half-rock

# --- line ---
@export var line_sag: float = 25.0
@export var line_width: float = 2.0
@export var line_color: Color = Color.WHITE

@onready var tip: Marker2D = $Tip
@onready var line: Line2D = %FishingLine

func _ready() -> void:
	# start exactly where the cast scene left the rod
	rotation = 0.0
	z_index = 2

	line.top_level = true
	line.position = Vector2.ZERO
	line.z_index = 1
	line.width = line_width
	line.default_color = line_color
	_update_line()

	_lean_in()

func _lean_in() -> void:
	var tw := create_tween()
	tw.tween_property(self, "rotation", deg_to_rad(hold_angle), lean_in_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_start_bob)

func _start_bob() -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(self, "rotation", deg_to_rad(hold_angle - bob_angle), bob_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "rotation", deg_to_rad(hold_angle + bob_angle), bob_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(_delta: float) -> void:
	_update_line()

func _update_line() -> void:
	var start: Vector2 = tip.global_position
	var end: Vector2 = GameState.line_end
	var mid: Vector2 = (start + end) * 0.5 + Vector2(0.0, line_sag)
	line.points = PackedVector2Array([start, mid, end])
