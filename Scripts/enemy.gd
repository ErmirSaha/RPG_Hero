extends CharacterBody2D

var speed = 50
var player_chase = false
var player = null
var health = 100
var player_in_attack_zone = false
var can_take_damage = true

func _ready():
	set_health_label()


func _physics_process(delta):
	deal_with_damage()
	if player_chase:
		position += (player.position - position)/speed 
		
		$AnimatedSprite2D.play("front_walk")
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.play("left_walk")
		else:
			$AnimatedSprite2D.play("right_walk")
	else:
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	
func enemy():
	pass

func deal_with_damage():
	if player_in_attack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 10
			spawn_dmgIndicator(10)
			$take_damage_cooldown.start()
			can_take_damage = false
			print("witch health is ", health)
			set_health_label()
			if health <= 0: 
				self.queue_free()

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false


func _on_take_damage_cooldown_timeout():
	can_take_damage = true

func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position, offset: Vector2 = Vector2.ZERO):
		if EFFECT:
			
			var effect = EFFECT.instantiate()
			effect.global_position = effect_position + offset  # Applying offset to the position
			get_tree().current_scene.add_child(effect)
			
			return effect 
			
func spawn_dmgIndicator(damage: int):
	var INDICATOR_DAMAGE = preload("res://ui/enemy_damage_indicator.tscn")
	var indicator = spawn_effect(INDICATOR_DAMAGE, global_position, Vector2(60, -40))
	if indicator:
		indicator.label_node.text = "- " + str(damage)
		
func set_health_label() -> void:
	$HealthLabel.value = health
