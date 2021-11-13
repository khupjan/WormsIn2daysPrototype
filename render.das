

require daslib/media


struct Camera
    position: float2 = float2(0,0)
    scale: float = 1.0
var private globalCamera: Camera = [[Camera position = float2(0,0), scale = 1.0]]

def get_camera() : Camera
    return globalCamera
def update_camera(position: float2; scale: float)
    globalCamera.position = position
    globalCamera.scale = scale

var global_focus_point: float2
def set_camera_focus_point(focus_point)
    global_focus_point = focus_point

def transform_pos_world_to_screen(var pos: float2)
    pos = pos - global_focus_point
    pos = (pos - globalCamera.position) * globalCamera.scale * float2(1, -1)
    pos = pos + global_focus_point
    return pos
def transform_size_world_to_screen(var size: float2)
    return size * globalCamera.scale
def transform_size_world_to_screen(var size: float)
    return size * globalCamera.scale

def transform_screen_to_world_pos(var pos: float2)
    pos = pos - global_focus_point
    pos = pos / globalCamera.scale * float2(1, -1) + globalCamera.position
    pos = pos + global_focus_point
    return pos
def transform_screen_to_world_size(var size: float2)
    return size / globalCamera.scale
def transform_screen_to_world_size(var size: float)
    return size / globalCamera.scale


def transform_pos_world_to_screen_no_scale(var pos: float2)
    pos = (pos - globalCamera.position) * float2(1, -1)
    return pos
def transform_screen_to_world_pos_no_scale(var pos: float2)
    pos = pos * float2(1, -1) + globalCamera.position
    return pos


var private globalImageArr: array<ImageHandle>



def game_create_image(srcPath: string; hasTransparency: bool) : int
    let index = globalImageArr |> length()
    var tex = create_managed_image(srcPath)
    globalImageArr |> push(tex)
    if (hasTransparency)
        make_image_color_transparent(tex, get_pixel(tex, 0, 0))
    return index
def game_create_image(width, height: int; hasTransparency: bool) : int
    let index = globalImageArr |> length()
    var tex = create_managed_image(width, height)
    globalImageArr |> push(tex)
    if (hasTransparency)
        make_image_color_transparent(tex, get_pixel(tex, 0, 0))
    return index
def game_get_texture(index: int) : ImageHandle
    return globalImageArr[index]






def game_draw_image(img: ImageHandle; var position: float2; var size: float2)
    position = transform_pos_world_to_screen(position)
    size = transform_size_world_to_screen(size)
    img |> draw_image(position.x, position.y, make_color(1.0), size)

def game_draw_image(img: ImageHandle; region: float4; var position: float2; var size: float2)
    position = transform_pos_world_to_screen(position)
    size = transform_size_world_to_screen(size)
    img |> draw_image_region(position.x, position.y, region, make_color(1.0), size)

