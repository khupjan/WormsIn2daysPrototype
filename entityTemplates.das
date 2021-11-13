

require daslib/decs_boost

require physics
require animation
require resources




// def create_worm(pos: float2; vel: float2; teamId: int)
//     create_entity <| @ ( eid, cmp )
//         let wormRadius = 10.0
//         let wormScale = 0.1

//         cmp |> set("eid", eid)
//         cmp |> set("tagWorm", true)
//         cmp |> set("position", pos)
//         cmp |> set("size", wormRadius * wormScale)
//         cmp |> set("radius", wormRadius)
//         cmp |> set("velocity", vel)
//         cmp |> set("facing", false) // 0,1: left, right
//         cmp |> set("surfaceNormal", float2(0,0))

//         cmp |> set("animState_spriteSheetId", globalAnim_Worm_Idle)
//         cmp |> set("animState_speed", 1.0)
//         cmp |> set("animState_normalizedTime", 0.0)
//         cmp |> set("animState_animType", AnimType AT_PING_PONG)

//         cmp |> set("physicsParamsIndex", globalPhysicsParamIndex_Worm)
//         cmp |> set("moveState", MoveState MS_Falling)
//         cmp |> set("bRefreshBouncing", true)

//         cmp |> set("health", 100)
//         cmp |> set("team", teamId)

//         cmp |> set("blastHitModifier", 1.0)
//         cmp |> set("isActive", true)
//         cmp |> set("isDrowning", false)


// def create_grenade(pos: float2; vel: float2; grenadeTimer: float)
//     create_entity <| @ ( eid, cmp )
//         cmp |> set("eid", eid)
//         cmp |> set("position", pos)
//         cmp |> set("size", 1.0)
//         cmp |> set("radius", 8.0)
//         cmp |> set("velocity", vel)
//         cmp |> set("facing", false) // 0,1: left, right
//         cmp |> set("surfaceNormal", float2(0,0))

//         cmp |> set("animState_spriteSheetId", globalAnim_Weapon_Grenade)
//         cmp |> set("animState_speed", 1.0)
//         cmp |> set("animState_normalizedTime", 0.0)
//         cmp |> set("animState_animType", AnimType AT_MANUAL)

//         cmp |> set("physicsParamsIndex", globalPhysicsParamIndex_Grenade)
//         cmp |> set("bRefreshBouncing", true)

//         cmp |> set("blastHitModifier", 1.0)
//         cmp |> set("isActive", true)
//         cmp |> set("isDrowning", false)
//         cmp |> set("moveState", MoveState MS_Falling)

//         cmp |> set("grenadeTimer", grenadeTimer)
//         cmp |> set("blastRadius", 70.0)
//         cmp |> set("blastPower", 800.0)
//         cmp |> set("blastDamage", 25)


// def create_missile(pos: float2; vel: float2)
//     create_entity <| @ ( eid, cmp )
//         cmp |> set("eid", eid)
//         cmp |> set("position", pos)
//         cmp |> set("size", 1.0)
//         cmp |> set("radius", 4.0)
//         cmp |> set("velocity", vel)
//         cmp |> set("facing", false) // 0,1: left, right
//         cmp |> set("surfaceNormal", float2(0,0))

//         cmp |> set("animState_spriteSheetId", globalPhysicsParamIndex_Bazooka)
//         cmp |> set("animState_speed", 1.0)
//         cmp |> set("animState_normalizedTime", 0.0)
//         cmp |> set("animState_animType", AnimType AT_MANUAL)

//         cmp |> set("isActive", true)
//         cmp |> set("isDrowning", false)
//         cmp |> set("moveState", MoveState MS_Falling)
//         cmp |> set("physicsParamsIndex", globalPhysicsParamIndex_Bazooka)

//         cmp |> set("tagMissile", true)
//         cmp |> set("blastRadius", 50.0)
//         cmp |> set("blastPower", 1000.0)
//         cmp |> set("blastDamage", 30)


// def create_air_strike_missile(pos: float2; vel: float2)
//     create_entity <| @ ( eid, cmp )
//         cmp |> set("eid", eid)
//         cmp |> set("position", pos)
//         cmp |> set("size", 1.0)
//         cmp |> set("radius", 6.0)
//         cmp |> set("velocity", vel)
//         cmp |> set("facing", false) // 0,1: left, right
//         cmp |> set("surfaceNormal", float2(0,0))

//         cmp |> set("animState_spriteSheetId", globalAnim_Weapon_Airstrike)
//         cmp |> set("animState_speed", 1.0)
//         cmp |> set("animState_normalizedTime", 0.0)
//         cmp |> set("animState_animType", AnimType AT_MANUAL)

//         cmp |> set("isActive", true)
//         cmp |> set("isDrowning", false)
//         cmp |> set("moveState", MoveState MS_Falling)
//         cmp |> set("physicsParamsIndex", globalPhysicsParamIndex_AirStrike)

//         cmp |> set("tagMissile", true)
//         cmp |> set("blastRadius", 20.0)
//         cmp |> set("blastPower", 500.0)
//         cmp |> set("blastDamage", 15)

