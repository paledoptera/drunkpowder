class_name LevelBoss
extends Level


enum BossState {IDLE, ATTACK, }
enum BossAttack {BASIC_FIREBALL}

var boss_state := BossState.IDLE

var current_attack = ""

@export var boss_timer: Timer
@export var boss_head: Node2D
@export var boss_head_guide: Node2D
@export var boss_cannon: Cannon
@export var stages: Array[BossStage]

var head_guide_target: Node2D

var current_stage: BossStage
var stage_num: int = -1

@export var player_cannon: PlayerCannon

var current_pattern: Array = [0,0,0]


func _ready() -> void:
	super()
	Audio.play_music(preload("uid://bwtfqk31scinb")) #flamedemon_boss.ogg
	


func switch_boss_state() -> void:
	var previous_state = boss_state
	var new_state: BossState
	var timer_amount: float = 4.0
	
	match previous_state:
		BossState.IDLE:
			if current_stage.attack_pool:
				new_state = BossState.ATTACK
		BossState.ATTACK:
			new_state = BossState.IDLE
	
	
	boss_state = new_state
	
	print("PREVIOUS STATE: ", previous_state, " NEW STATE:", new_state)
	
	match new_state:
		BossState.ATTACK:
			
			current_attack = current_stage.attack_pool.pick_random()
			
			match current_attack:
				BossAttack.BASIC_FIREBALL:
					head_guide_target = Global.ui_cursor
					print(head_guide_target)
					await get_tree().create_timer(2.5).timeout
					boss_cannon.fire()
					timer_amount = 0.2
					head_guide_target = null
					
					
					
	
	head_guide_target = null
	boss_timer.start(timer_amount)
	
	## Boss AI is basically handled in here

func _process(delta: float) -> void:
	if head_guide_target:
		boss_head_guide.look_at(head_guide_target.global_position)
		boss_head.rotation = lerp_angle(boss_head.rotation,boss_head_guide.rotation-deg_to_rad(90.0),5.0*delta)
	else:
		boss_head.rotation = lerp_angle(boss_head.rotation,0.0,10.0*delta)
	super(delta)

func _on_timer_timeout() -> void:
	if not current_stage:
		current_stage = stages.pop_front()
		stage_num += 1
		
		
		match stage_num:
			1:
				Audio.play_sfx(preload("uid://cqu0kujtor5i4"))
				$Animations.play("phase0_end")
				$Animations.queue("phase1_start")
			2:
				$Animations.play("phase1_end")
		
		print(current_stage)
	
	if current_stage is BossStageSort:
		if not sections:
			sections = current_stage.sections
		super()
	
	if current_stage is BossStageAttack:
		current_pattern[0] = current_stage.slot1.pick_random()
		current_pattern[1] = current_stage.slot2.pick_random()
		current_pattern[2] = current_stage.slot3.pick_random()
		player_cannon.process_mode = Node.PROCESS_MODE_INHERIT
		player_cannon.active = true
	else:
		player_cannon.process_mode = Node.PROCESS_MODE_DISABLED

func end() -> void:
	if stages.size() > 0:
		current_stage = null
		if timer.is_stopped():
			timer.start(0.1)
		return
	
	ended = true
	$Animations.play("end")
	await $Animations.animation_finished
	Global.victory()
	#Global.goto_scene(VICTORY_SCENE)
	
			
