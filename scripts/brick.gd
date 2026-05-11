extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


#brick is hit
func hit():
	#add to score
	GameManager.addPoints(1)
	
	#particles for block destruction, disable collider and sprite
	$CPUParticles2D.emitting = true # turn off particles
	$Sprite2D.visible = false #disable sprite so we can't see it
	$CollisionShape2D.disabled = true #disable collision shape so it can't interact with ball
	
	#count bricks left
	var bricksLeft = get_tree ().get_nodes_in_group ("Brick")
	if(bricksLeft.size() == 1):
		#if last brick, reload scene to next level
		get_parent().get_node("Ball").is_active = false
		await get_tree().create_timer(1).timeout #pause
		GameManager.level += 1 #iterate level
		get_tree().reload_current_scene() #reload scene
	else:
		#wait, then remove block (so particles can play)
		await get_tree().create_timer(1).timeout #pause
		queue_free() #remove brick from scene
	
