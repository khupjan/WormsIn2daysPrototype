

require daslib/media
require daslib/math
require daslib/decs_boost

require render


enum AnimType
    AT_MANUAL
    AT_LOOP
    AT_PING_PONG
    AT_ONCE

def get_sprite_index(animState_spriteSheetId: int; animState_normalizedTime: float; animState_animType: AnimType): int
    let tex = game_get_texture(animState_spriteSheetId)
    let spriteCnt = tex.height / tex.width
    var spritePos : float
    if (animState_animType == AnimType AT_PING_PONG)
        if (animState_normalizedTime < 0.5)
            spritePos = animState_normalizedTime*2.0
        else
            spritePos = (1.0-animState_normalizedTime)*2.0
    else
        spritePos = animState_normalizedTime
    return clamp(floori(float(spriteCnt-1)*spritePos + 0.5), 0, spriteCnt-1)
