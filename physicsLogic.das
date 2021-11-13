

require daslib/media
require daslib/math


require util
require map


struct HitData
    time: float
    position: float2


def calculate_contact_final(startPos: float2; velocity: float2; radius: float; gravity, wind: float; startT, endT: float): HitData
    if (endT <= startT)
        let pos0 = calc_position_by_time(startPos, velocity, gravity, wind, startT)
        var contactResult: float2
        if (map_get_circle_contact_point(pos0, radius, contactResult))
            return [[HitData time = -1.0]] // TODO: maybe just return false
    var approxData = calc_contact_time_internal(startPos, velocity, radius, gravity, wind, startT, endT)
    if (approxData.time < 0.0)
        return approxData
	// TODO: correction is broken
    return approxData //correct_contact_internal(startPos, radius, approxData.position, approxData.time, velocity, gravity, wind)


def calc_position_by_time(startPos: float2; velocity: float2; gravity, wind: float; time: float)
	return startPos + time * (velocity + float2(wind, -gravity) * time * 0.5)

def calc_velocity_by_time(velocity: float2; gravity, wind: float; time: float)
	return velocity + float2(wind, -gravity) * time



let private PIXEL_RADIUS = 0.5

// TODO: broken !!
def private correct_contact_internal(startPos: float2; radius: float; pixelPos: float2; predictedT: float; velocity: float2; gravity, wind: float): HitData
	var result = [[HitData time = -1.0]]
	// pixelRay == pixelRadius == 0.5
	let finalPos = calc_position_by_time(startPos, velocity, gravity, wind, predictedT)
	let finalVel = calc_velocity_by_time(velocity, gravity, wind, predictedT)
	let sgnPixelSide = sign(finalPos - pixelPos)
	let acc = float2(wind, -gravity)
	// [top-bottom]
	if (abs(finalPos.x - pixelPos.x) < PIXEL_RADIUS && map_check_terrain(pixelPos + float2(sgnPixelSide.x*PIXEL_RADIUS*2.0, 0.0)))
		var newtonT: float
		if (!solve_quadratic_newton_way(0.0, 0.0, 0.0, -gravity*0.5, finalVel.y, finalPos.y - (pixelPos.y + sgnPixelSide.y * (radius + PIXEL_RADIUS)), newtonT))
			return result
		result.time = predictedT + newtonT
		result.position = (acc * result.time * 0.5 + velocity) * result.time + startPos - float2(0.0, sgnPixelSide.y * radius)
	// [left-right]
	elif (abs(finalPos.y - pixelPos.y) < PIXEL_RADIUS * 2.0 && map_check_terrain(pixelPos + float2(0.0, sgnPixelSide.y*PIXEL_RADIUS*2.0)))
		var newtonT: float
		if (!solve_quadratic_newton_way(0.0, 0.0, 0.0, wind*0.5, finalVel.x, finalPos.x - (pixelPos.x + sgnPixelSide.x * (radius + PIXEL_RADIUS)), newtonT))
			return result
		result.time = predictedT + newtonT
		result.position = (acc * result.time * 0.5 + velocity) * result.time + startPos - float2(sgnPixelSide.x * radius, 0.0)
	// [general case]
	else
		let d = radius + PIXEL_RADIUS
		let diff = startPos - pixelPos
		let A = dot(acc, acc) * 0.25
		let B = dot(acc, velocity)
		let C = dot(velocity, velocity) + dot(diff, acc)
		let D = dot(diff, velocity) * 2.0
		let E = dot(diff, diff) - d*d
		var newtonT: float
		if (!solve_quadratic_newton_way(predictedT, A, B, C, D, E, newtonT))
			if (!solve_quadratic_newton_way(predictedT, 0.0, 4.0*A, 3.0*B, 2.0*C, D, newtonT))
				return result
		result.time = newtonT
		let hitPos = calc_position_by_time(startPos, velocity, gravity, wind, result.time)
		let normal = normalize(pixelPos - hitPos)
		result.position = hitPos + normal * radius
	return result


def /*private*/ calc_contact_time_internal(startPos: float2; velocity: float2; radius: float; gravity, wind: float; startT, endT: float): HitData
	var startHit = calc_contact_time_linear(startPos, velocity, radius, gravity, wind, startT, endT, true)
	if (startHit.time < 0.0)
		return startHit // null
	var endHit = calc_contact_time_linear(startPos, velocity, radius, gravity, wind, startT, endT, false)
	if (endHit.time < 0.0)
		return endHit // null
	var result = calc_contact_time_logarithmic(startPos, velocity, radius, gravity, wind, startHit.time, endHit.time)
	return result.time < 0.0 ? endHit : result


def private calc_contact_time_logarithmic(startPos: float2; velocity: float2; radius: float; gravity, wind: float; var startT, endT: float): HitData
    let EPS = 0.0001 //0.00000001
	var result = [[HitData time = 0.0, position = startPos]]
	var foundA, foundB = false
	while (abs(endT - startT) > EPS)
		let midTime = (startT + endT) * 0.5
		let midPos = calc_position_by_time(startPos, velocity, gravity, wind, midTime)
        var contactResult: float2
        if (map_get_circle_contact_point(midPos, radius, contactResult))
			foundA = true
			result.position = contactResult
			endT = midTime
		else
			foundB = true
			startT = midTime
	result.time = startT
	return (foundA && foundB) ? result : [[HitData time = -1.0]]


let RESTRICT_CONTACT_CALC_TO_INSIDE = true // mostly for visualization


def private calc_contact_time_linear(startPos: float2; velocity: float2; radius: float; gravity, wind: float; startT, endT: float; bContactOut: bool): HitData
	var result = [[HitData time = 0.0, position = startPos]]
	let MAX_SAFETY_ITER = 500 // TODO
	let contactEpsMul = 0.1 //10.0
	let stepD = 10.01
	let dt = calc_time_until_dist(calc_velocity_by_time(velocity, gravity, wind, startT), gravity, wind, stepD)
	var curT = startT
	var safetyI = 0
	while (curT < endT && safetyI++ < MAX_SAFETY_ITER)
		let lastT = curT
		curT = min(curT + dt, endT)
		if (calc_linear_route_contact_point(
			calc_position_by_time(startPos, velocity, gravity, wind, lastT),
			calc_position_by_time(startPos, velocity, gravity, wind, curT), radius, bContactOut, result.position))
			break
		if (RESTRICT_CONTACT_CALC_TO_INSIDE && map_check_pos_is_outside(result.position))
			break
	result.time = !bContactOut ? min(curT + dt * contactEpsMul, endT) : max(curT - dt * contactEpsMul, startT)
	return result

def private calc_positive_min(a, b: float)
	var res = (a <= 0.0 || is_nan(a)) ? b : min(a, b)
	return (res <= 0.0 || is_nan(res)) ? -1.0 : res


def calc_time_until_dist(velocity: float2; gravity, wind: float; distance): float
	return 0.01 // TODO: for now (it's broken)
	// let MIN_DT = 0.0001
	// var result = -1.0
	// var curPair: float2
	// if (solve_quartic(wind*0.5, velocity.x, distance, curPair))
	// 	result = calc_positive_min(result, curPair.x)
	// 	result = calc_positive_min(result, curPair.y)
	// if (solve_quartic(wind*0.5, velocity.x, -distance, curPair))
	// 	result = calc_positive_min(result, curPair.x)
	// 	result = calc_positive_min(result, curPair.y)
	// if (solve_quartic(-gravity*0.5, velocity.y, distance, curPair))
	// 	result = calc_positive_min(result, curPair.x)
	// 	result = calc_positive_min(result, curPair.y)
	// if (solve_quartic(-gravity*0.5, velocity.y, -distance, curPair))
	// 	result = calc_positive_min(result, curPair.x)
	// 	result = calc_positive_min(result, curPair.y)
	// result = calc_positive_min(result, velocity.y / gravity)
	// if (abs(wind) > 0.00001)
	// 	result = calc_positive_min(result, abs(velocity.x) / wind)
	// 	// result = calc_positive_min(result, -velocity.x / wind)
	// return max(result, MIN_DT)

def calc_launch_hit_time(startPos: float2; velocity: float2; radius: float; gravity, wind: float; maxT: float): HitData
	let EPS = 0.0001
	let MAX_SAFETY_ITER = 200
	let bigRadius = radius * sqrt(2.0)
	let dist = bigRadius
	var nullRes = [[HitData time = -1.0]]
	if (length_sq(velocity) < 0.01)
		return nullRes
	var timeHistory : array<float>
	timeHistory |> push(0.0)
	var curTime = min(calc_time_until_dist(velocity, gravity, wind, dist), maxT)
	var safetyI = 0
	while (safetyI++ < MAX_SAFETY_ITER)
		let pos = calc_position_by_time(startPos, velocity, gravity, wind, curTime)
		if (!timeHistory |> empty())
			let sTime = timeHistory[timeHistory |> length() - 1]
        	var contactResult: float2
			if (map_get_circle_contact_point(pos, bigRadius, contactResult)
				|| map_get_circle_contact_point(calc_position_by_time(startPos, velocity, gravity, wind, sTime), bigRadius, contactResult))
				var result : HitData = calculate_contact_final(startPos, velocity, radius + EPS, gravity, wind, sTime, curTime)
				if (result.time > 0.0)
					return result
				let checkPos = calc_position_by_time(startPos, velocity, gravity, wind, curTime)
				var contactP : float2
				if (calc_linear_route_contact_point(checkPos, checkPos, radius, false, contactP))
					var fakeContact: HitData
					let dir = normalize(calc_velocity_by_time(velocity, gravity, wind, curTime))
					fakeContact.position = pos + dir * radius
					fakeContact.time = curTime
					return fakeContact
		if (curTime >= maxT)
			return nullRes
		if (map_check_pos_is_outside(pos))
			return nullRes
		timeHistory |> push(curTime)
		let timeStep = calc_time_until_dist(calc_velocity_by_time(velocity, gravity, wind, curTime), gravity, wind, dist)
		curTime = min(curTime + timeStep, maxT)
	if (safetyI >= MAX_SAFETY_ITER)
		print("INFINITE LOOP !!!\n")
	return nullRes


