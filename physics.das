

require daslib/media
require daslib/math
require daslib/decs_boost

require map
require util
require physicsLogic



enum MoveState
    MS_Idle
    MS_Falling
    MS_Rolling
    MS_Nothing

struct PhysicsObjParams
    bouncyness: float
    friction: float
    useWind: bool

var private globalPhysicsObjParams : array<PhysicsObjParams>

def get_physics_obj_params(physicsParamsIndex: int): PhysicsObjParams
    return globalPhysicsObjParams[physicsParamsIndex]

def create_physics_obj_params(params: PhysicsObjParams): int
    let index = globalPhysicsObjParams |> length()
    globalPhysicsObjParams |> push(params)
    return index


