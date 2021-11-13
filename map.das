

require daslib/media
require daslib/math

require util

require render



struct MapData
    size: int2
    outerRect: float4
    outerCameraRect: float4
    // data: array<uint> // bool //uint8
    // data: ImageHandle
    transparentPixel: uint

let private PIXEL_RADIUS = 0.5 // TODO: assuming map is in world space (not scaled)
let private EPS = 0.001

var private globalMapImage: ImageHandle
var private globalMapBackgroundImage: ImageHandle
var private globalMapData: MapData

def private get_map_coords(var pos: int2): int2
    pos.y = globalMapData.size.y - 1 - pos.y
    pos = clamp(pos, int2(0,0), globalMapData.size - int2(1,1)) // TODO
    return pos

def private map_get_pixel(var pos: int2): uint
    pos = get_map_coords(pos)
    return globalMapImage |> get_pixel(pos.x, pos.y)
def private map_set_pixel(var pos: int2; color: uint)
    pos = get_map_coords(pos)
    globalMapImage |> set_pixel(pos.x, pos.y,color)

def get_map_data(): MapData
    return globalMapData

def private calc_backround_taint(color: uint)
    let alpha = (color >> 24u) & 0xFF
    return alpha == 0x00 ? color : multiply_colors(desaturate_color(color), 0x2222180D)

def init_map(resolution: int2; mapTextureSrc: ImageHandle)
    globalMapData.size = resolution
    globalMapImage <- create_managed_image(resolution.x,resolution.y)
    for y in range(min(resolution.y, mapTextureSrc.height))
        for x in range(min(resolution.x, mapTextureSrc.width))
            globalMapImage |> set_pixel(x, y, mapTextureSrc |> get_pixel(x, y))
    make_image_color_transparent(globalMapImage, globalMapImage |> get_pixel(0,0))
    globalMapData.transparentPixel = globalMapImage |> get_pixel(0,0)

    for y in range(mapTextureSrc.height, resolution.y)
        for x in range(mapTextureSrc.width, resolution.x)
            globalMapImage |> set_pixel(x, y, globalMapData.transparentPixel)

    globalMapBackgroundImage <- create_managed_image(resolution.x,resolution.y)
    for y in range(globalMapBackgroundImage.height)
        for x in range(globalMapBackgroundImage.width)
            globalMapBackgroundImage |> set_pixel(x, y, calc_backround_taint(globalMapImage |> get_pixel(x, y)))
    make_image_color_transparent(globalMapBackgroundImage, globalMapData.transparentPixel)

    let origSize = float2(resolution)
    let center = origSize * 0.5
    let OUTER_BORDER_SCALE = 1.0
    let OUTER_BORDER_AIR = 1000.0
    let OUTER_BORDER_WATER = 200.0
    let OUTER_BORDER_BORDER = 1000.0
    let extents = origSize * 0.5 * OUTER_BORDER_SCALE
    globalMapData.outerCameraRect = float4(-extents.x-OUTER_BORDER_BORDER, -extents.y-OUTER_BORDER_WATER, extents.x+OUTER_BORDER_BORDER, extents.y + OUTER_BORDER_AIR)
    globalMapData.outerRect = globalMapData.outerCameraRect
    globalMapData.outerRect += float4(center.x, center.y, center.x, center.y)


def map_check_pos_is_outside(pos: float2)
    return !is_pos_in_rect(pos, globalMapData.outerRect)

def map_clamp_camera_rect_by_borders(center: float2; extents: float2)
    let rectMin = float2(globalMapData.outerCameraRect.x, globalMapData.outerCameraRect.y)+extents
    let rectMax = float2(globalMapData.outerCameraRect.z, globalMapData.outerCameraRect.w)-extents
    return (rectMin.x < rectMax.x && rectMin.y < rectMax.y) ? clamp(center, rectMin, rectMax) : center



def map_fill_circle(pos: float2; radius: float; color: uint)
    let posI = roundi(pos)
    let radiusI = roundi(radius)
    let r2 = radiusI * radiusI
    for y in range(-radiusI, radiusI)
        for x in range(-radiusI, radiusI)
            if (x*x + y*y <= r2)
                map_set_pixel(posI + int2(x,y), color)

def map_erase_circle(pos: float2; radius: float)
    map_fill_circle(pos, radius, globalMapData.transparentPixel)


def map_fill_linear_route(start: float2; end: float2; radius: float; color: uint)
    unsafe
        var func <- @ <| (p : int2) : bool
            map_set_pixel(p, color)
            return true
        map_fill_circle(start, radius, color) // iteration does not check start
        iterate_in_linear_route(start, end, radius, false, func)



def map_erase_linear_route(start: float2; end: float2; radius: float)
    map_fill_linear_route(start, end, radius, globalMapData.transparentPixel)



def map_draw()
    enable_alpha_blend()
    game_draw_image(globalMapBackgroundImage, float2(0, globalMapData.size.y), float2(globalMapData.size.x, globalMapData.size.y))
    game_draw_image(globalMapImage, float2(0, globalMapData.size.y), float2(globalMapData.size.x, globalMapData.size.y))
    disable_alpha_blend()



def map_check_terrain(posI: int2): bool
    if (posI.x < 0 || posI.y < 0 || posI.x >= globalMapData.size.x || posI.y >= globalMapData.size.y) // TODO: move it outside, but check/clamp the ranges
        return false
    return map_get_pixel(posI) != globalMapData.transparentPixel
def map_check_terrain(pos: float2): bool
    return map_check_terrain(roundi(pos))


def private map_check_circle_border_contact_internal(pos: float2; radius: float; var outContact: float2&)
    outContact = float2(roundi(float2(pos.x, pos.y-radius))) // bottom
    if (map_check_terrain(outContact) && map_check_terrain(float2(outContact.x + sign(pos.x - outContact.x), outContact.y)))
        return true

    outContact = float2(roundi(float2(pos.x-radius, pos.y))) // left
    if (map_check_terrain(outContact) && map_check_terrain(float2(outContact.x, outContact.y + sign(pos.y - outContact.y))))
        return true

    outContact = float2(roundi(float2(pos.x+radius, pos.y))) // right
    if (map_check_terrain(outContact) && map_check_terrain(float2(outContact.x, outContact.y + sign(pos.y - outContact.y))))
        return true

    outContact = float2(roundi(float2(pos.x, pos.y+radius))) // top
    if (map_check_terrain(outContact) && map_check_terrain(float2(outContact.x + sign(pos.x - outContact.x), outContact.y)))
        return true
    return false


def map_get_circle_contact_point(pos: float2; radius: float; var outContact: float2&): bool
    if (map_check_circle_border_contact_internal(pos, radius, outContact))
        return true
    let posI = roundi(pos)
    let minI = roundi(pos - float2(radius+0.5,radius+0.5))
    let maxI = roundi(pos + float2(radius+0.5,radius+0.5))
    let d2 = sqr(radius + PIXEL_RADIUS)
    for y in range(minI.y, maxI.y)
        for x in range(minI.x, maxI.x)
            if (map_check_terrain(int2(x, y)) && length_sq(float2(x, y) - pos) <= d2)
                outContact = float2(x, y)
                return true
    return false


def private map_check_pos_in_route_internal (pos: float2; focusMinMaxU: float2; focusV: float; sinX, cosX: float; radius: float; isStartMin: bool): bool
    let r2 = radius * radius
    let posUV = transform_pos_by_angle(pos, sinX, cosX)
    if (posUV.x < focusMinMaxU.x)
        if (!isStartMin && length_sq(float2(focusMinMaxU.x, focusV) - posUV) <= r2)
            return true
    elif (focusMinMaxU.y < posUV.x)
        if (isStartMin && length_sq(float2(focusMinMaxU.y, focusV) - posUV) <= r2)
            return true
    elif (abs(posUV.y - focusV) <= radius)
        return true
    return false


def calc_linear_route_contact_point(startPos: float2; endPos: float2; radius: float; bContactOut: bool; var outContact: float2&): bool
    let EPS = 0.001
    if (!map_get_circle_contact_point(startPos, radius - EPS, outContact))
        if (map_get_circle_contact_point(endPos, radius - EPS, outContact))
            return true // optimization
    var bFound = false
    unsafe
        var bFoundPtr = addr(bFound)
        var outContactPtr = addr(outContact)
        var func <- @ <| (p : int2) : bool
            if (map_check_terrain(p))
                *outContactPtr = float2(p) + float2(PIXEL_RADIUS, PIXEL_RADIUS)
                *bFoundPtr = true
                return false
            return true
        iterate_in_linear_route(startPos, endPos, radius, bContactOut, func)
    return bFound


def private iterate_in_linear_route(start: float2; end: float2; radius: float; isContactOut: bool; iteratorPtr: lambda<(a:int2):bool>)
    let fromTo = end - start
    let angle = atan2(fromTo.y, fromTo.x)
    var sinX, cosX: float
    sincos(angle, sinX, cosX)
    let focusUV1 = transform_pos_by_angle(start, sinX, cosX)
    let focusUV2 = transform_pos_by_angle(end, sinX, cosX)
    let isStartMin = focusUV1.x < focusUV2.x // TODO
    let focusMinMaxU = float2(min(focusUV1.x, focusUV2.x), max(focusUV1.x, focusUV2.x))
    let focusV = focusUV1.y // == focusUV2.y
    let r = radius + PIXEL_RADIUS*(isContactOut ? sqrt(2.0) : 1.0) + EPS
    let minI = roundi(min(start, end) - float2(radius + PIXEL_RADIUS,radius + PIXEL_RADIUS))
    let maxI = roundi(max(start, end) + float2(radius + PIXEL_RADIUS,radius + PIXEL_RADIUS))
    for y in range(minI.y, maxI.y)
        for x in range(minI.x, maxI.x)
            if (map_check_pos_in_route_internal(float2(x, y), focusMinMaxU, focusV, sinX, cosX, r, isStartMin) && !invoke(iteratorPtr, int2(x, y)))
                return
