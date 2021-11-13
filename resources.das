

require daslib/media

require render
require physics
require animation





let globalPhysicsParamIndex_Worm: int = create_physics_obj_params([[PhysicsObjParams bouncyness = 0.1, friction = 0.96, useWind = false]])
let globalPhysicsParamIndex_Grave: int = create_physics_obj_params([[PhysicsObjParams bouncyness = 0.2, friction = 0.7, useWind = false]])
let globalPhysicsParamIndex_Bazooka: int = create_physics_obj_params([[PhysicsObjParams bouncyness = 0.5, friction = 0.5, useWind = true]])
let globalPhysicsParamIndex_Grenade: int = create_physics_obj_params([[PhysicsObjParams bouncyness = 0.7, friction = 0.99, useWind = false]])
let globalPhysicsParamIndex_AirStrike : int = create_physics_obj_params([[PhysicsObjParams bouncyness = 0.5, friction = 0.5, useWind = true]])





let globalAnim_Worm_Idle = game_create_image("resources/images/worm/idle/wbrth1.png", true)
let globalAnim_Worm_SlideF = game_create_image("resources/images/worm/slide/wslide.png", true)
let globalAnim_Worm_SlideD = game_create_image("resources/images/worm/slide/wslided.png", true)
let globalAnim_Worm_SlideEndF = game_create_image("resources/images/worm/slide/wsldlk1.png", true)
let globalAnim_Worm_SlideEndU = game_create_image("resources/images/worm/slide/wsldlk1d.png", true)
let globalAnim_Worm_SlideEndD = game_create_image("resources/images/worm/slide/wsldlk1u.png", true)
let globalAnim_Worm_Die = game_create_image("resources/images/worm/misc/wdie.png", true)
let globalAnim_Worm_FallDown = game_create_image("resources/images/worm/fall/wfall.png", true)
let globalAnim_Worm_FallAway = game_create_image("resources/images/worm/fall/wfly3.png", true)

let globalAnim_Weapon_Missile = game_create_image("resources/images/weapons/missile.png", true)
let globalAnim_Weapon_Grenade = game_create_image("resources/images/weapons/grenade.png", true)
let globalAnim_Weapon_Airstrike = game_create_image("resources/images/weapons/airmisl.png", true)

let globalAnim_Grave = game_create_image("resources/images/graves/grave1.png", true)

let globalAnim_Icon_Bazooka = game_create_image("resources/images/icons/bazooka.1.png", true)
let globalAnim_Icon_Grenade = game_create_image("resources/images/icons/grenade.1.png", true)
let globalAnim_Icon_Airstrike = game_create_image("resources/images/icons/airstrke.1.png", true)



def get_team_color(team: int): uint
    if (team == 0)
        return 0xFFFF8A8A
    elif (team == 1)
        return 0xFF6294FF
    else
        return 0xFFFF00FF

