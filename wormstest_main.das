// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code



require daslib/media
require daslib/decs_boost
require daslib/random

require render
require animation
require map
require util
require physics
require resources
require physicsLogic
require entityTemplates





def create_worm(pos: float2; vel: float2; teamId: int)
    create_entity <| @ ( eid, cmp )
        let wormRadius = 10.0
        let wormScale = 0.1

        cmp |> set("eid", eid)
        cmp |> set("tagWorm", true)
        cmp |> set("position", pos)
        cmp |> set("size", wormRadius * wormScale)
        cmp |> set("radius", wormRadius)
        cmp |> set("velocity", vel)
        cmp |> set("facing", false) // 0,1: left, right
        cmp |> set("surfaceNormal", float2(0,0))

        cmp |> set("animState_spriteSheetId", globalAnim_Worm_Idle)
        cmp |> set("animState_speed", 1.0)
        cmp |> set("animState_normalizedTime", 0.0)
        cmp |> set("animState_animType", AnimType AT_PING_PONG)

        cmp |> set("physicsParamsIndex", globalPhysicsParamIndex_Worm)
        cmp |> set("moveState", MoveState MS_Falling)
        cmp |> set("bRefreshBouncing", true)

        cmp |> set("health", 100)
        cmp |> set("team", teamId)

        cmp |> set("blastHitModifier", 1.0)
        cmp |> set("isActive", true)
        cmp |> set("isDrowning", false)


def create_grenade(pos: float2; vel: float2; grenadeTimer: float)
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        cmp |> set("position", pos)
        cmp |> set("size", 1.0)
        cmp |> set("radius", 8.0)
        cmp |> set("velocity", vel)
        cmp |> set("facing", false) // 0,1: left, right
        cmp |> set("surfaceNormal", float2(0,0))

        cmp |> set("animState_spriteSheetId", globalAnim_Weapon_Grenade)
        cmp |> set("animState_speed", 1.0)
        cmp |> set("animState_normalizedTime", 0.0)
        cmp |> set("animState_animType", AnimType AT_MANUAL)

        cmp |> set("physicsParamsIndex", globalPhysicsParamIndex_Grenade)
        cmp |> set("bRefreshBouncing", true)

        cmp |> set("blastHitModifier", 1.0)
        cmp |> set("isActive", true)
        cmp |> set("isDrowning", false)
        cmp |> set("moveState", MoveState MS_Falling)

        cmp |> set("grenadeTimer", grenadeTimer)
        cmp |> set("blastRadius", 70.0)
        cmp |> set("blastPower", 800.0)
        cmp |> set("blastDamage", 25)


def create_missile(pos: float2; vel: float2)
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        cmp |> set("position", pos)
        cmp |> set("size", 1.0)
        cmp |> set("radius", 4.0)
        cmp |> set("velocity", vel)
        cmp |> set("facing", false) // 0,1: left, right
        cmp |> set("surfaceNormal", float2(0,0))

        cmp |> set("animState_spriteSheetId", globalAnim_Weapon_Missile)
        cmp |> set("animState_speed", 1.0)
        cmp |> set("animState_normalizedTime", 0.0)
        cmp |> set("animState_animType", AnimType AT_MANUAL)

        cmp |> set("isActive", true)
        cmp |> set("isDrowning", false)
        cmp |> set("moveState", MoveState MS_Falling)
        cmp |> set("physicsParamsIndex", globalPhysicsParamIndex_Bazooka)

        cmp |> set("tagMissile", true)
        cmp |> set("blastRadius", 50.0)
        cmp |> set("blastPower", 1000.0)
        cmp |> set("blastDamage", 30)


def create_air_strike_missile(pos: float2; vel: float2)
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        cmp |> set("position", pos)
        cmp |> set("size", 1.0)
        cmp |> set("radius", 6.0)
        cmp |> set("velocity", vel)
        cmp |> set("facing", false) // 0,1: left, right
        cmp |> set("surfaceNormal", float2(0,0))

        cmp |> set("animState_spriteSheetId", globalAnim_Weapon_Airstrike)
        cmp |> set("animState_speed", 1.0)
        cmp |> set("animState_normalizedTime", 0.0)
        cmp |> set("animState_animType", AnimType AT_MANUAL)

        cmp |> set("isActive", true)
        cmp |> set("isDrowning", false)
        cmp |> set("moveState", MoveState MS_Falling)
        cmp |> set("physicsParamsIndex", globalPhysicsParamIndex_AirStrike)

        cmp |> set("tagMissile", true)
        cmp |> set("blastRadius", 20.0)
        cmp |> set("blastPower", 500.0)
        cmp |> set("blastDamage", 15)




def init_wind_particles()
    let particleCnt = 400
    let screenSize = int2(get_screen_width(), get_screen_height()) * 4
    var seed = int4(1,2,3,666)
    let wind = get_wind()
    let windStrength = abs(wind) + 10.0
    for i in range(particleCnt)
        var randomPos = float2(random_int(seed) % screenSize.x, random_int(seed) % screenSize.y)
        randomPos = randomPos - float2(screenSize) / 2.0
        let randomVel = float2(sign(wind), -0.1)*float2(random_float(seed) % windStrength, random_float(seed) % windStrength)// % float2(100.0, 10.0) + float2(50.0, 5.0)
        let randomSize = lerp(0.8, 1.5, random_float(seed) % 1.0)
        create_entity <| @ ( eid, cmp )
            cmp |> set("eid", eid)
            cmp |> set("particlePos", randomPos)
            cmp |> set("particleVel", randomVel)
            cmp |> set("particleTargetVel", randomVel)
            cmp |> set("particleSize", randomSize)

[decs(stage = update)]
def update_background_particles(var particlePos: float2&; var particleVel: float2&; var particleTargetVel: float2&)
    let dt = get_delta_time()
    let wind = get_wind()
    particlePos += particleVel * dt * 6.0

    particleVel = lerp(particleTargetVel, particleVel, 0.8)
    particleTargetVel = float2(wind, -(abs(wind)*0.5 + 0.5)) * float2(1.0, 0.5) * 0.1

    let screenSize = float2(get_screen_width(), get_screen_height()) * float2(1.0, 2.0)
    if (particlePos.x > screenSize.x)
        particlePos.x -= 2.0*screenSize.x
    if (particlePos.x < -screenSize.x)
        particlePos.x += 2.0*screenSize.x

    if (particlePos.y > screenSize.y)
        particlePos.y -= 2.0*screenSize.y
    if (particlePos.y < -screenSize.y)
        particlePos.y += 2.0*screenSize.y

    // map_modulo_camera_rect_by_borders(particlePos)


[decs(stage = draw_background)]
def draw_background_particles(particlePos: float2; particleSize: float)
    let screenPos = transform_pos_world_to_screen(particlePos)
    let screenSize = transform_size_world_to_screen(particleSize)
    enable_alpha_blend()
    fill_circle(screenPos.x, screenPos.y, screenSize, 0xFF8DA5B3)
    disable_alpha_blend()




enum WeaponType
    WT_Bazooka
    WT_Grenade
    WT_AirStrike
    WT_END

var weaponIconArr = [[auto globalAnim_Icon_Bazooka; globalAnim_Icon_Grenade; globalAnim_Icon_Airstrike]]

var globalWeaponTypeId = 0



let globalGravity = 600.0
var globalWind = 1000.0
var globalWaterLevel = 0.0
var globalTargetWind = 1000.0
var globalTargetWaterLevel = 0.0
def get_gravity(): float
    return globalGravity
def get_wind(): float
    return globalWind
def get_water_level(): float
    return globalWaterLevel

def set_wind(wind: float)
    globalTargetWind = clamp(wind, -1000.0, 1000.0)
def set_water_level(waterLevel: float)
    globalTargetWaterLevel = clamp(waterLevel, 0.0, 1000.0)

var sky_gradient, water_gradient, water_gradientFg: Image


def init_camera()
    query () <| $ (eid: EntityId; cameraPosition: float2)
        delete_entity(eid)
    create_entity <| @ ( eid, cmp )
        cmp.eid := eid
        cmp |> set("cameraPos", float2(0,0))
        cmp |> set("cameraPosTarget", float2(0,0))
        cmp |> set("cameraScale", 1.0)
        cmp |> set("cameraScaleTarget", 1.0)

[decs(stage = update)]
def camera_update(var cameraPos, cameraPosTarget: float2&; var cameraScale, cameraScaleTarget: float&)
    let dt = get_delta_time()

    let minPosDiff = 0.5
    let minZoomDiff = 0.1

    let minZoom = 0.5
    let maxZoom = 2.0

    let cameraSpeed = 1000.0
    let zoomSpeed = 300.0
    let moveLerpSpeed = 0.1
    let zoomLerpSpeed = 0.1

    var targetVel = float2(0,0)
    if get_key(VK_A)
        targetVel.x -= 1.0
    if get_key(VK_D)
        targetVel.x += 1.0
    if get_key(VK_S)
        targetVel.y -= 1.0
    if get_key(VK_W)
        targetVel.y += 1.0
    targetVel /= max(targetVel |> length(), 0.00001)

    cameraScaleTarget = clamp(cameraScaleTarget*pow(zoomSpeed, get_mouse_scroll_delta()*dt), minZoom, maxZoom)

    cameraPosTarget = cameraPosTarget + targetVel * (cameraSpeed * dt)
    if (length_sq(cameraPos - cameraPosTarget) > minPosDiff*minPosDiff)
        cameraPos = lerp(cameraPos, cameraPosTarget, moveLerpSpeed)

    if (abs(cameraScale - cameraScaleTarget) > minZoomDiff*minZoomDiff)
        cameraScale = lerp(cameraScale, cameraScaleTarget, zoomLerpSpeed)

    let extents = transform_screen_to_world_size(float2(get_screen_width(), get_screen_height())) * 0.5
    cameraPos = map_clamp_camera_rect_by_borders(cameraPos, extents)
    cameraPosTarget = map_clamp_camera_rect_by_borders(cameraPosTarget, extents)

    update_camera(cameraPos, cameraScale)



def private calc_blast_modifier(distSq, rangeSq: float): float
    return clamp(1.0 - sqrt(distSq/rangeSq), 0.2, 1.0)

def blast_in_radius(pos: float2; blastRadius: float; power: float; damage: int)
    map_erase_circle(pos, blastRadius)
    query () <| $ (position: float2; radius: float; var velocity: float2&; var bRefreshBouncing: bool&; blastHitModifier: float)
        let dd = length_sq(pos - position)
        let rr = sqr(blastRadius + radius + 0.01)
        if (dd <= rr)
            bRefreshBouncing = true
            if (blastHitModifier > 0.0)
                let modifier = calc_blast_modifier(dd,rr)
                let dir = normalize(pos - position)
                velocity -= dir*(power*modifier*blastHitModifier)

    query () <| $ (position: float2; radius: float; var health: int&; var moveState: MoveState&; var facing: bool&;
        var animState_spriteSheetId: int&; var animState_animType: AnimType&)
        let dd = length_sq(pos - position)
        let rr = sqr(blastRadius + radius + 0.01)
        if (dd <= rr)
            if (health > 0)
                let modifier = calc_blast_modifier(dd,rr)
                let dmg = roundi(float(damage) * modifier)
                health = max(health - dmg, 0)
                moveState = MoveState MS_Falling
                animState_animType = AnimType AT_MANUAL
                facing = pos.x < position.x
                animState_spriteSheetId = globalAnim_Worm_FallAway




def init_map(is_hard_reload: bool; resolution: int2)
    var mapTextureSrc: ImageHandle = create_managed_image("resources/images/map.png")
    init_map(resolution, mapTextureSrc)




var globalParticleTex: ImageHandle
def init_resources()
    globalParticleTex <- create_managed_image("resources/images/ball.png")
    make_image_color_transparent(globalParticleTex, get_pixel(globalParticleTex, 0, 0))

    sky_gradient <- create_image(2, 2, [{uint[] make_color(0.1, 0.2, 0.4);  make_color(0.25, 0.2, 0.5);
                                                make_color(0.0, 0.15, 0.0); make_color(0.0, 0.22, 0.0)}])
    sky_gradient |> set_image_smooth(true)

    water_gradient <- create_image(2, 2, [{uint[] 0xFF1E3DDA; 0xFF1E3EDA; 0xFF0D2FD8; 0xFF0D2FD8}])
    water_gradient |> set_image_smooth(true)
    water_gradientFg <- create_image(2, 2, [{uint[] 0xB91E5ADA; 0xB91E5ADA; 0xDB1E5ADA; 0xDB1E5ADA}])
    water_gradientFg |> set_image_smooth(true)





[export]
def initialize(var is_hard_reload: bool)
    is_hard_reload = true
    restart()

    set_window_title("Worms Demo")

    let windowRes = int2(1280,720)

    init_resources()

    init_map(is_hard_reload, windowRes)

    init_camera()

    init_wind_particles()

    let focusPoint = float2(get_screen_width(), get_screen_height())*0.5
    set_camera_focus_point(focusPoint)



var lastFixedMousePosL = float2(0,0)
var lastFixedMousePosR = float2(0,0)
var lastLaunchVelocityL = float2(0,0)
var lastLaunchVelocityR = float2(0,0)
var trajectoryTest : array<float2>

var testTeamId = 0




[export]
def act(dt: float)

    if get_key(VK_ESCAPE)
        schedule_quit_game()

    if get_key(VK_UP)
        set_water_level(get_water_level() + dt * 1000.0)
    if get_key(VK_DOWN)
        set_water_level(get_water_level() - dt * 1000.0)
    if get_key(VK_RIGHT)
        set_wind(get_wind() + dt * 10000.0)
    if get_key(VK_LEFT)
        set_wind(get_wind() - dt * 10000.0)

    let lerpSpeed = 0.8
    globalWind = lerp(globalTargetWind, globalWind, lerpSpeed)
    globalWaterLevel = lerp(globalTargetWaterLevel, globalWaterLevel, lerpSpeed)

    let mouseWorldPos = transform_screen_to_world_pos(get_mouse_position())
    if get_mouse_button_down(MB_LEFT)
        lastFixedMousePosL = mouseWorldPos
    if get_mouse_button_down(MB_RIGHT)
        lastFixedMousePosR = mouseWorldPos


    decs_stage("update")
    decs_stage("animation")
    decs_stage("late_animation")


    let showTrajectory = get_key(VK_LCONTROL) && globalWeaponTypeId != int(WeaponType WT_AirStrike)
    if (!showTrajectory)
        trajectoryTest |> clear()

    let launchPowerMul = 4.0
    let velocityL = (mouseWorldPos - lastFixedMousePosL) * launchPowerMul
    let velocityR = (mouseWorldPos - lastFixedMousePosR) * launchPowerMul

    if (get_mouse_button(MB_LEFT))
        let gravity = get_gravity()
        let wind = globalWeaponTypeId == 0 ? get_wind() : 0.0
        let radius = 5.0
        let startT = 0.0
        let endT = 2.0
        let hitData = calculate_contact_final(lastFixedMousePosL, velocityL, radius, gravity, wind, startT, endT)
        if (showTrajectory && hitData.time > 0.0)
            trajectoryTest |> clear()
            if (hitData.time > 0.0)
                trajectoryTest |> push(hitData.position)
            let visualizerDt = 0.01
            let visualizerDs = 2.0
            var t = 0.0
            var lastP = lastFixedMousePosL
            let visualizerDs2 = visualizerDs*visualizerDs
            while (t < hitData.time)
                let p = calc_position_by_time(lastFixedMousePosL, velocityL, gravity, wind, t)
                if (length_sq(p - lastP) > visualizerDs2)
                    lastP = p
                    trajectoryTest |> push(p)
                t += visualizerDt

    for t in range(int(WeaponType WT_END))
        if (get_key_down(VK_0 + t + 1))
            globalWeaponTypeId = t

    if (get_mouse_button_up(MB_LEFT))
        lastLaunchVelocityL = velocityL
    if (get_mouse_button_up(MB_RIGHT))
        lastLaunchVelocityR = velocityR

    if (get_mouse_button_up(MB_RIGHT))
        create_worm(lastFixedMousePosR, lastLaunchVelocityR, testTeamId)
        testTeamId = (testTeamId + 1) % 2

    if (get_mouse_button_up(MB_LEFT) || get_key_down(VK_SPACE))
        if (globalWeaponTypeId == int(WeaponType WT_Bazooka))
            create_missile(lastFixedMousePosL, lastLaunchVelocityL)
        elif (globalWeaponTypeId == int(WeaponType WT_Grenade))
            let grenadeTimer = 5.0
            create_grenade(lastFixedMousePosL, lastLaunchVelocityL, grenadeTimer)
        elif (globalWeaponTypeId == int(WeaponType WT_AirStrike))
            let missileHeight = transform_screen_to_world_pos(float2(0, 0)).y
            let missileDist = 20.0
            let missileCnt = 6
            let dir = lastLaunchVelocityL.x < 0.0 ? -1.0 : 1.0
            var pos = float2(lastFixedMousePosL.x - (0.5*missileDist*float(missileCnt) + dir*200.0), missileHeight)
            let velocity = float2(dir*200.0, -200.0)
            for i in range(missileCnt)
                create_air_strike_missile(pos, velocity)
                pos.x += missileDist
        commit()

def draw_weapon_icons()
    let windowSize = float2(get_screen_width(), get_screen_height())
    let iconSize = 0.05
    let iconScreenSize = float2(windowSize.y,windowSize.y)*iconSize
    var iconPos = float2(0.05, 0.9)
    for i in range(int(WeaponType WT_END))
        let pos = iconPos*windowSize
        game_get_texture(weaponIconArr[i]) |> draw_image(pos.x, pos.y, make_color(1.0), iconScreenSize)
        if (globalWeaponTypeId == i)
            rect(pos.x, pos.y, iconScreenSize.x, iconScreenSize.y, 0x00E10000)
        iconPos.x += iconSize*0.5*1.2

def draw_debug_stuff()
    let cam = get_camera()
    // text_out(20, 110, "Camera pos: {cam.position}", 0xFFFFFF)
    // text_out(20, 140, "Camera scale: {cam.scale}", 0xFFFFFF)

    // let mouseWorldPos = transform_screen_to_world_pos(get_mouse_position())
    // text_out(20, 170, "mouseWorldPos = {mouseWorldPos}\n", 0xFFFFFF)

    text_out(20, 110, "Wind Strength = {globalWind}\n", 0xFFFFFF)
    text_out(20, 140, "Water Level = {globalWaterLevel}\n", 0xFFFFFF)



[export]
def draw
    let WATER_LEVEL_START = 20.0
    let WATER_LEVEL_END = 400.0
    let sWaterLevel = transform_pos_world_to_screen(float2(0.0, get_water_level() + WATER_LEVEL_START)).y
    let sWaterLevelSize = transform_size_world_to_screen(get_water_level() + WATER_LEVEL_END)

    sky_gradient |> draw_image(0.0, 0.0, make_color(1.0), float2(get_screen_width(), get_screen_height()))

    decs_stage("draw_background")

    water_gradient |> draw_image(0.0, sWaterLevel, make_color(1.0), float2(float(get_screen_width()), sWaterLevelSize))

    map_draw()

    decs_stage("draw")

    enable_alpha_blend()
    water_gradientFg |> draw_image(0.0, sWaterLevel, make_color(1.0), float2(float(get_screen_width()), sWaterLevelSize))
    disable_alpha_blend()

    let visualizerRadius = 5.0
    let visualizerColor = 0x16C2F2
    for p in trajectoryTest
        let screenP = transform_pos_world_to_screen(p)
        circle(screenP.x, screenP.y, visualizerRadius, visualizerColor)

    decs_stage("draw_ui")
    draw_weapon_icons()

    draw_debug_stuff()


let FLAT_SURFACE_BIAS = 0.99




[decs(stage = draw)]
def draw_anim(position: float2; size: float;animState_spriteSheetId: int; animState_speed: float;
    animState_normalizedTime: float; animState_animType: AnimType; facing: bool; moveState: MoveState)
    let tex = game_get_texture(animState_spriteSheetId)
    var spriteSize = size*float2(tex.width, tex.width)
    var drawPos = position + spriteSize*float2(-0.5, 0.5)

    let w = tex.width
    let spriteId : int = get_sprite_index(animState_spriteSheetId, animState_normalizedTime, animState_animType)
    let rect = float4(int4(0, spriteId*w, w, w))

    drawPos = transform_pos_world_to_screen(drawPos)
    spriteSize = transform_size_world_to_screen(spriteSize)
    let invertFacing = moveState == MoveState MS_Falling
    if (invertFacing ? facing : !facing)
        drawPos.x += spriteSize.x
        spriteSize.x = -spriteSize.x
    enable_alpha_blend()
    tex |> draw_image_region(drawPos.x, drawPos.y, rect, make_color(1.0), spriteSize) // TODO: ability to flip it !!
    disable_alpha_blend()




[decs(stage = draw_ui)]
def draw_worm_ui(tagWorm: bool; health: int; position: float2; radius: float; team: int; isActive: bool; isDrowning: bool)
    let textWorldSize = 10.0
    let drawRadius = radius * 4.0
    let sPos = roundi(transform_pos_world_to_screen(position + drawRadius * float2(-0.5, 1.0)))
    let sSize = textWorldSize//transform_size_world_to_screen(textWorldSize)
    if (isActive && !isDrowning)
        text_out(sPos.x, sPos.y,"{health}", get_team_color(team))

[decs(stage = draw_ui)]
def draw_grenade_timer(grenadeTimer: float; position: float2; radius: float; isDrowning: bool)
    let textWorldSize = 8.0
    let drawRadius = radius * 4.0
    let sPos = roundi(transform_pos_world_to_screen(position + drawRadius * float2(-0.5, 1.0)))
    let sSize = textWorldSize//transform_size_world_to_screen(textWorldSize)
    if (!isDrowning)
        let timerI = roundi(grenadeTimer)
        text_out(sPos.x, sPos.y,"{timerI}",timerI <= 1 ? 0xFFCD1B1B : 0xFFFFFFFF)





def play_anim_once(targetSpriteSheet: int; resetTime: bool;
    var animState_spriteSheetId: int& implicit; var animState_normalizedTime: float& implicit; var animState_animType: AnimType& implicit)
    if (animState_spriteSheetId != targetSpriteSheet)
        animState_spriteSheetId = targetSpriteSheet
        animState_animType = AnimType AT_ONCE
        if (resetTime)
            animState_normalizedTime = 0.0

[decs(stage = animation)]
def update_worm_anim(eid: EntityId; var moveState: MoveState&; var position: float2&; var velocity: float2&;
    surfaceNormal: float2; var facing: bool&; isDrowning: bool; var isActive: bool&; health: int;
    var physicsParamsIndex: int&;
    var animState_spriteSheetId: int&; var animState_normalizedTime: float&; var animState_animType: AnimType&)
    var dt = min(get_delta_time(), MAX_SIMULATION_DT)

    if (isDrowning)
        isActive = false
        if (animState_spriteSheetId != globalAnim_Grave)
            animState_normalizedTime = 0.0
            moveState = MoveState MS_Nothing
            animState_spriteSheetId = globalAnim_Worm_FallAway
    elif (isActive)
    	let fallMinVelY = 50.0;
    	let fallMaxVelX = 20.0;
    	let minStuckVelocity = 100.0;
    	let minFallVelocity = 100.0;

        let hasSurfaceContact = length_sq(surfaceNormal) > 0.001

        if (velocity.y < -fallMinVelY && abs(velocity.x) < fallMaxVelX)
            animState_animType = AnimType AT_PING_PONG
            animState_spriteSheetId = globalAnim_Worm_FallDown
            moveState = MoveState MS_Falling
        elif (hasSurfaceContact)
            let slopeLimit = 45.0
            let slidingMinSpeed = 5.0
            let slope = atan2(surfaceNormal.y, surfaceNormal.x) * (180.0 / PI) * sign(surfaceNormal.x*(facing ? -1.0 : 1.0))
            if (length_sq(velocity) < slidingMinSpeed*slidingMinSpeed)
                moveState = MoveState MS_Idle
                if (slope > slopeLimit)
                    play_anim_once(globalAnim_Worm_SlideEndU, false, animState_spriteSheetId, animState_normalizedTime, animState_animType)
                elif (slope < -slopeLimit)
                    play_anim_once(globalAnim_Worm_SlideEndF, false, animState_spriteSheetId, animState_normalizedTime, animState_animType)
                else
                    play_anim_once(globalAnim_Worm_SlideEndD, false, animState_spriteSheetId, animState_normalizedTime, animState_animType)
                if (health <= 0)
                    isActive = false
                    physicsParamsIndex = globalPhysicsParamIndex_Grave
            elif (slope > slopeLimit)
                play_anim_once(globalAnim_Worm_SlideD, true, animState_spriteSheetId, animState_normalizedTime, animState_animType)
            elif (slope < -slopeLimit)
                play_anim_once(globalAnim_Worm_SlideF, true, animState_spriteSheetId, animState_normalizedTime, animState_animType)
            else
                play_anim_once(globalAnim_Worm_SlideD, true, animState_spriteSheetId, animState_normalizedTime, animState_animType)
        elif (moveState == MoveState MS_Falling && length_sq(velocity) > 0.001)
            animState_normalizedTime = 1.0 - atan2(abs(velocity.x), -velocity.y) / PI
            if (length_sq(velocity) > minFallVelocity*minFallVelocity)
                animState_animType = AnimType AT_MANUAL
                facing = velocity.x > 0.0
                animState_spriteSheetId = globalAnim_Worm_FallAway


let MAX_SIMULATION_DT = 1.0/30.0



[decs(stage = late_animation)]
def update_anim_state(isActive: bool; isDrowning: bool; var animState_speed: float&;
    var animState_normalizedTime: float&; var animState_animType: AnimType&; var animState_spriteSheetId: int&)
    if (animState_animType == AnimType AT_MANUAL)
        return
    let dt = get_delta_time()
    animState_normalizedTime += animState_speed * dt
    if (animState_animType == AnimType AT_LOOP || animState_animType == AnimType AT_PING_PONG)
        animState_normalizedTime = animState_normalizedTime % 1.0
    elif (animState_animType == AnimType AT_ONCE && animState_normalizedTime >= 1.0 && !isDrowning)
        if (isActive)
            animState_spriteSheetId = globalAnim_Worm_Idle
            animState_animType = AnimType AT_PING_PONG
            animState_speed = 1.0
        elif (animState_spriteSheetId != globalAnim_Worm_Die)
            animState_normalizedTime = 0.0
            animState_spriteSheetId = globalAnim_Worm_Die
            animState_animType = AnimType AT_ONCE
            animState_speed = 0.5
        else
            animState_spriteSheetId = globalAnim_Grave
            animState_animType = AnimType AT_PING_PONG
    animState_normalizedTime = clamp(animState_normalizedTime, 0.0, 1.0)


[decs(stage = update)]
def update_drowning(eid: EntityId; var moveState: MoveState&; var position: float2&; var velocity: float2&;
    var isDrowning: bool&; var animState_normalizedTime: float&; var animState_animType: AnimType&)
    let DROWNING_SPEED = 50.0
    var dt = min(get_delta_time(), MAX_SIMULATION_DT)
    let waterLevel = get_water_level()
    if (position.y < waterLevel)
        isDrowning = true
        moveState = MoveState MS_Nothing
        animState_normalizedTime = 0.5
        animState_animType = AnimType AT_MANUAL
    if (isDrowning)
        position.y -= DROWNING_SPEED * dt
        velocity = float2(0,0)



[decs(stage = update)]
def update_grenade_obj(eid: EntityId; var position: float2&; var velocity: float2&; radius: float;
    var animState_normalizedTime: float&; isDrowning: bool;
    var grenadeTimer: float&;
    blastRadius: float; blastPower: float; blastDamage: int)

    let minVelocityToSpin = 1.0
    let rotationSpeed = 0.006

    var dt = min(get_delta_time(), MAX_SIMULATION_DT)
    grenadeTimer -= dt

    if (grenadeTimer <= 0.0)
        blast_in_radius(position, blastRadius, blastPower, blastDamage)
        delete_entity(eid)

    elif (!isDrowning && abs(velocity.x) > minVelocityToSpin)
        animState_normalizedTime = (animState_normalizedTime + length(velocity)*sign(velocity.x)*dt*rotationSpeed + 1.0) % 1.0


[decs(stage = update)]
def update_bullet_obj(eid: EntityId; tagMissile: bool; var position: float2&; var velocity: float2&; radius: float;
    physicsParamsIndex: int; var animState_normalizedTime: float&; isDrowning: bool;
    blastRadius: float; blastPower: float; blastDamage: int)

    let params : PhysicsObjParams = get_physics_obj_params(physicsParamsIndex)
    let gravity = get_gravity()
    let wind = params.useWind ? get_wind() : 0.0

    var dt = min(get_delta_time(), MAX_SIMULATION_DT)
    let hitData = calc_launch_hit_time(position, velocity, radius, gravity, wind, dt)
    if (hitData.time > 0.0)
        dt = hitData.time
    position = calc_position_by_time(position, velocity, gravity, wind, dt)
    velocity = calc_velocity_by_time(velocity, gravity, wind, dt)
    if (hitData.time > 0.0)
        blast_in_radius(position, blastRadius, blastPower, blastDamage)
        delete_entity(eid)
    elif (map_check_pos_is_outside(position))
        delete_entity(eid)
    elif (!isDrowning && length_sq(velocity) > 0.001)
        animState_normalizedTime = (atan2(velocity.x, velocity.y)/(2.0 * PI) + 1.0) % 1.0


[decs(stage = update)]
def update_bouncy_obj(eid: EntityId; var moveState: MoveState&; var position: float2&; var velocity: float2&; radius: float;
    physicsParamsIndex: int; var bRefreshBouncing: bool&; isDrowning: bool; var surfaceNormal: float2&;
    var animState_normalizedTime: float&; var animState_animType: AnimType&)
    let EPS = 0.001
    let FLOATING_VEL_EPS = 0.01
    let params : PhysicsObjParams = get_physics_obj_params(physicsParamsIndex)
    let minDv = 0.1
    let dvSqCheck = 0.1
    let dvSq = 0.01
    let minVel = 2.0

    let gravity = get_gravity()
    let wind = params.useWind ? get_wind() : 0.0

    let disableAxisX = false // TODO

    let dt = min(get_delta_time(), MAX_SIMULATION_DT)

    if (!isDrowning)
        if (moveState != MoveState MS_Idle)
            surfaceNormal = float2(0,0)
        var timeLeft = dt
        var bRun = true
        while (bRun && timeLeft > 0.0 && moveState != MoveState MS_Idle)
            let hitData = calc_launch_hit_time(position, velocity, radius, gravity, wind, timeLeft)
            if (hitData.time < EPS)
                bRun = false
            else
                timeLeft -= hitData.time
                let timeSpent = max(hitData.time - EPS, 0.0)
                position = calc_position_by_time(position, velocity, gravity, wind, timeSpent)
                velocity = calc_velocity_by_time(velocity, gravity, wind, timeSpent)
                let normal = disableAxisX ? float2(0,1) : normalize(hitData.position - position)
                if (normal.y > FLAT_SURFACE_BIAS && length_sq(velocity) < minVel)
                    moveState = MoveState MS_Idle
                if (moveState != MoveState MS_Idle)
                    let dv = max((params.bouncyness+1.0)*dot(velocity, normal), minDv)
                    let angle = atan2(normal.x, -normal.y)
                    let relVel = transform_pos_by_angle(velocity, angle) * float2(params.friction, 1.0)
                    velocity = transform_pos_by_angle(relVel, -angle)
                    let checkPos = position - normal * dvSqCheck
                    var checkHitPos : float2
                    if (calc_linear_route_contact_point(position, checkPos, radius, false, checkHitPos))
                        let checkPosNormal = checkHitPos - position
                        if ((normal.y < 0.0 || checkPosNormal.y < 0.0) && normal.x*checkPosNormal.x < 0.0)
                            moveState = MoveState MS_Idle
                    if (moveState != MoveState MS_Idle)
                        position = position - normal * dvSq
                    velocity = velocity - dv*normal
                    surfaceNormal = normal
                if (map_check_pos_is_outside(position))
                    bRun = false

        if (timeLeft > 0.0 && moveState != MoveState MS_Idle)
            position = calc_position_by_time(position, velocity, gravity, wind, timeLeft)
            velocity = calc_velocity_by_time(velocity, gravity, wind, timeLeft)

        if (moveState == MoveState MS_Idle)
            if (bRefreshBouncing)
                moveState = MoveState MS_Falling
                if (abs(velocity.y) < FLOATING_VEL_EPS)
                    velocity.y = FLOATING_VEL_EPS

        if (moveState == MoveState MS_Idle)
            velocity = float2(0,0)

    bRefreshBouncing = false

    if (map_check_pos_is_outside(position))
        delete_entity(eid) // TODO: maybe not here, also, do some other stuff


