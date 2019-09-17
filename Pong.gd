extends Node2D

const BOARD_WIDTH = 1024
const BOARD_HEIGHT = 600

const PADDLE_SPEED = 500.0
const AI_ACTION_DISTANCE = 10.0
const BALL_RANDOMNESS = 0.05
const BALL_HORIZONTAL_SPEED = 5.0

var velocity = Vector2(BALL_HORIZONTAL_SPEED, 0.0)
var random_y_accel = 0.0

var player_score = 0
var ai_score = 0

func _physics_process(delta):
	# Handle ball colliding with paddles
	var collision = $Ball.move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)

	# Handle ball colliding with top and bottom of screen
	if $Ball.position.y < 0:
		velocity.y = abs(velocity.y)
		random_y_accel = 0.0
	elif $Ball.position.y > BOARD_HEIGHT:
		velocity.y = -abs(velocity.y)
		random_y_accel = 0.0
	
	# Handle ball bouncing off left and right edging, updating scores
	if $Ball.position.x < 0:
		velocity.x = abs(velocity.x)
		player_score += 1
	elif $Ball.position.x > BOARD_WIDTH:
		velocity.x = -abs(velocity.x)
		ai_score += 1
	
	# Player paddle movement
	if Input.is_action_pressed("move_down"):
		$PlayerPaddle.move_and_collide(Vector2(0, PADDLE_SPEED * delta))
	if Input.is_action_pressed("move_up"):
		$PlayerPaddle.move_and_collide(Vector2(0, -PADDLE_SPEED * delta))
	
	# AI paddle movement
	var aioffset = $AIPaddle.position.y - $Ball.position.y
	if aioffset > AI_ACTION_DISTANCE:
		$AIPaddle.move_and_collide(Vector2(0, -PADDLE_SPEED * delta))
	if aioffset < -AI_ACTION_DISTANCE:
		$AIPaddle.move_and_collide(Vector2(0, PADDLE_SPEED * delta))
	
	# Ball's y position gets a random acceleration
	var yrelative = $Ball.position.y / BOARD_HEIGHT
	random_y_accel += (yrelative - randf()) * BALL_RANDOMNESS
	velocity.y += random_y_accel
	
	# Since we bounce off paddles with the normal we might have lost horizontal speed
	velocity.x = sign(velocity.x) * BALL_HORIZONTAL_SPEED
	
	# Set score text
	$ScoreText.text = str(player_score) + " - " + str(ai_score)