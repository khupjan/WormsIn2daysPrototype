

require daslib/media
require daslib/math


def solve_quartic(a, b, c: float; var outX: float2&) : bool
    let EPS = 0.000001
    if (abs(a) < EPS)
        if (abs(b) > EPS)
            outX.x = -c/b
            outX.y = outX.x
            return true
    else
        var D = b*b-4.0*a*c
        if (D < 0.0 && D > -EPS)
            D = 0.0
        if (D >= 0.0)
            D = sqrt(D)
            outX = float2(-b+D, -b-D) / (2.0 * a)
            return true
    return false

def solve_quadratic_newton_way(x0: float; a, b, c, d, e: float; var outX: float&): bool
    let EPS = 0.00000001
    let TOLERANCE = EPS
    let MAX_ITER = 20
    outX = x0
    for i in range(MAX_ITER-1)
        let dfx = ((4.0*a*outX+3.0*b)*outX+2.0*c)*outX+d
        if (abs(dfx) < EPS)
            break
        let fx = (((a*outX+b)*outX+c)*outX+d)*outX+e
        let x1 = outX - fx/dfx
        if (abs(x1 - outX) <= TOLERANCE * abs(x1))
            return true
        outX = x1
    return false


// rect: x1,y1,x2,y2
def is_pos_in_rect(pos: float2; rect: float4): bool
    return pos.y > rect.y && pos.x < rect.z && pos.x > rect.x && pos.y < rect.w;



def transform_pos_by_angle(pos: float2; sinX: float; cosX: float): float2
    return float2(cosX*pos.x+sinX*pos.y, cosX*pos.y-sinX*pos.x)

def transform_pos_by_angle(pos: float2; angle: float): float2
    var sinX, cosX: float
    sincos(angle, sinX, cosX)
    return transform_pos_by_angle(pos, sinX, cosX)




