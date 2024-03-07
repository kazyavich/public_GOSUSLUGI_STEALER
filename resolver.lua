--[[ prayers for good code
    * Rahman ve rahim olan Allah'ın adıyla!
    * Dünyada herkesi, ahirette sadece mü'minleri rahmetine alan Allah adına.

    * C Nuestro que estas en la Memoria,
    * Compilado sea tu código,
    * venga a nosotros tu software,
    * carguense tus punteros.
    * así en la RAM como en el Disco Duro,
    * Danos hoy nuestro Array de cada día,
    * Perdona nuestros Warnings,
    * así como nosotros también los eliminamos,
    * no nos dejes caer en Bucles,
    * y libranos del Windows, Enter.

    * Избавь нас от Юзера глупого, ибо продвинут он стал и имя ему БУХ.
    * Выправи программы наши кривые, ибо клинит башни нам от конфигураторов и отладчиков.
    * Открой нам знание, ибо истинно говоришь Ты нам, где тру и фолс.
    * Откомментируй код наш многомегабайтный, ибо погрязли мы в MD-шниках своих.
]]

ffi.cdef([[
    struct c_animstate {
        char pad[ 3 ];
        char m_bForceWeaponUpdate; //0x4
        char pad1[ 91 ];
        void* m_pBaseEntity; //0x60
        void* m_pActiveWeapon; //0x64
        void* m_pLastActiveWeapon; //0x68
        float m_flLastClientSideAnimationUpdateTime; //0x6C
        int m_iLastClientSideAnimationUpdateFramecount; //0x70
        float m_flAnimUpdateDelta; //0x74
        float m_flEyeYaw; //0x78
        float m_flPitch; //0x7C
        float m_flGoalFeetYaw; //0x80
        float m_flCurrentFeetYaw; //0x84
        float m_flCurrentTorsoYaw; //0x88
        float m_flUnknownVelocityLean; //0x8C
        float m_flLeanAmount; //0x90
        char pad2[ 4 ];
        float m_flFeetCycle; //0x98
        float m_flFeetYawRate; //0x9C
        char pad3[ 4 ];
        float m_fDuckAmount; //0xA4
        float m_fLandingDuckAdditiveSomething; //0xA8
        char pad4[ 4 ];
        float m_vOriginX; //0xB0
        float m_vOriginY; //0xB4
        float m_vOriginZ; //0xB8
        float m_vLastOriginX; //0xBC
        float m_vLastOriginY; //0xC0
        float m_vLastOriginZ; //0xC4
        float m_vVelocityX; //0xC8
        float m_vVelocityY; //0xCC
        char pad5[ 4 ];
        float m_flUnknownFloat1; //0xD4
        char pad6[ 8 ];
        float m_flUnknownFloat2; //0xE0
        float m_flUnknownFloat3; //0xE4
        float m_flUnknown; //0xE8
        float m_flSpeed2D; //0xEC
        float m_flUpVelocity; //0xF0
        float m_flSpeedNormalized; //0xF4
        float m_flFeetSpeedForwardsOrSideWays; //0xF8
        float m_flFeetSpeedUnknownForwardOrSideways; //0xFC
        float m_flTimeSinceStartedMoving; //0x100
        float m_flTimeSinceStoppedMoving; //0x104
        bool m_bOnGround; //0x108
        bool m_bInHitGroundAnimation; //0x109
        float m_flTimeSinceInAir; //0x10A
        float m_flLastOriginZ; //0x10E
        float m_flHeadHeightOrOffsetFromHittingGroundAnimation; //0x112
        float m_flStopToFullRunningFraction; //0x116
        char pad7[ 4 ]; //0x11A
        float m_flMagicFraction; //0x11E
        char pad8[ 60 ]; //0x122
        float m_flWorldForce; //0x15E
        char pad9[ 462 ]; //0x162
        float m_flMaxYaw; //0x334

        float velocity_subtract_x; //0x0330 
        float velocity_subtract_y; //0x0334 
        float velocity_subtract_z; //0x0338 
    };

    typedef void*(__thiscall* get_client_entity_t)(void*, int);

    typedef struct
    {
        float   m_anim_time;		
        float   m_fade_out_time;	
        int     m_flags;			
        int     m_activity;			
        int     m_priority;			
        int     m_order;			
        int     m_sequence;			
        float   m_prev_cycle;		
        float   m_weight;			
        float   m_weight_delta_rate;
        float   m_playback_rate;	
        float   m_cycle;			
        void* m_owner;			
        int     m_bits;				
    } C_AnimationLayer;

    typedef uintptr_t (__thiscall* GetClientEntityHandle_4242425_t)(void*, uintptr_t);
]])
local vmt = require('vmt_hooks')
local enabled = gui.add_checkbox('Resolver engine', 'lua>tab b')

math.clamp = function(v, min, max)
    if min > max then min, max = max, min end
    if v > max then return max end
    if v < min then return v end
    return v
end

math.angle_diff = function(dest, src)
    local delta = 0.0
    delta = math.fmod(dest - src, 360.0)
    if dest > src then
        if delta >= 180 then delta = delta - 360 end
    else
        if delta <= -180 then delta = delta + 360 end
    end

    return delta
end

math.angle_normalize = function(angle)
    local ang = 0.0
    ang = math.fmod(angle, 360.0)
    if ang < 0.0 then ang = ang + 360 end
    return ang
end

math.anglemod = function(a)
    local num = (360 / 65536) * bit.band(math.floor(a * (65536 / 360.0), 65535))
    return num
end

math.approach_angle = function(target, value, speed)
    target = math.anglemod(target)
    value = math.anglemod(value)
    local delta = target - value
    if speed < 0 then speed = -speed end
    if delta < -180 then
        delta = delta + 360
    elseif delta > 180 then
        delta = delta - 360
    end
    if delta > speed then
        value = value + speed
    elseif delta < -speed then
        value = value - speed
    else
        value = target
    end
    return value
end
local entity_list_ptr = ffi.cast("void***", utils.find_interface("client.dll", "VClientEntityList003"))
local get_client_entity_fn = ffi.cast("GetClientEntityHandle_4242425_t", entity_list_ptr[0][3])
local get_client_entity_by_handle_fn = ffi.cast("GetClientEntityHandle_4242425_t", entity_list_ptr[0][4])
local rawientitylist = utils.find_interface("client.dll", "VClientEntityList003") or error("VClientEntityList003 wasnt found", 2)
local ientitylist = ffi.cast(ffi.typeof("void***"), rawientitylist) or error("rawientitylist is nil", 2)
local get_client_entity = ffi.cast("get_client_entity_t", ientitylist[0][3]) or error("get_client_entity is nil", 2)

local entity = {}
entity.get_address = function(idx)
    return get_client_entity_fn(entity_list_ptr, idx)
end
entity.get_animstate = function(idx)
    local addr = entity.get_address(idx)
    if not addr then return end
    return ffi.cast("struct c_animstate**", addr + 0x9960)[0]
end
entity.get_animlayer = function(idx)
    local addr = entity.get_address(idx)
    if not addr then return end
    return ffi.cast("C_AnimationLayer**", ffi.cast('uintptr_t', addr) + 0x9960)[0]
end
entity.get_prop = function(ent, ...)
    if not ent then return end
    return entities.get_entity(ent):get_prop(...)
end
entity.get_local_player = function()
    local lp = engine.get_local_player()
    if not lp then return end
    return entities.get_entity(lp)
end
entity.get_velocity = function(idx)
    local ent = entities.get_entity(idx)
    return math.vec3(ent:get_prop("m_vecVelocity[0]"), ent:get_prop("m_vecVelocity[1]"), ent:get_prop("m_vecVelocity[2]"))
end

local resolver = {
    layers = {},
    safepoints = {},
    cache = {},
    rotation = {
        CENTER = 1,
        LEFT = 2,
        RIGHT = 3
    },
    getMaxDesyncDelta = function(self, idx)
        if not idx or idx <= 0 then return end
        local animstate = entity.get_animstate(idx)
        local speedfactor = math.clamp(animstate.m_flFeetSpeedForwardsOrSideWays, 0, 1)
        local avg_speedfactor = (animstate.m_flStopToFullRunningFraction * -0.3 - 0.2) * speedfactor + 1
        local duck_amount = animstate.m_fDuckAmount
        if duck_amount > 0 then
            local max_velocity = math.clamp(animstate.m_flFeetSpeedForwardsOrSideWays, 0, 1)
            local duck_speed = duck_amount * max_velocity
            avg_speedfactor = avg_speedfactor + (duck_speed * (0.5 - avg_speedfactor))
        end
        return avg_speedfactor
    end,
    updateLayers = function(self, idx)
        local resolver = self
        if not idx then return end
        local layers = entity.get_animlayer(idx)
        if not layers then return end
        if not resolver.layers[idx] then
            resolver.layers[idx] = {}
        end
        for i = 1, 12 do
            local layer = layers[i]
            if not layer then goto continue end
            if not resolver.layers[idx][i] then
                resolver.layers[idx][i] = {}
            end
            resolver.layers[idx][i].m_playback_rate = layer.m_playback_rate or resolver.layers[idx][i].m_playback_rate
            resolver.layers[idx][i].m_sequence = layer.m_sequence or resolver.layers[idx][i].m_sequence
            ::continue::
        end
    end,
    isLBYFlexing = function(self, idx)
        local resolver = self
        if not resolver.layers[idx] then return end
        for i = 1, 12 do
            if not resolver.layers[idx][i] then goto continue end
            if not resolver.layers[idx][i].m_sequence then goto continue end

            if resolver.layers[idx][i].m_sequence == 979 then return true end

            ::continue::
        end
        return false
    end,
    updateSafety = function(self, idx, side, desync)
        local resolver = self
        if not resolver.safepoints[idx] then
            resolver.safepoints[idx] = {}
        end
        if not resolver.safepoints[idx][3] then
            for i = 1, 3 do
                resolver.safepoints[idx][i] = {}
                resolver.safepoints[idx][i].m_playback_rate = nil
                resolver.safepoints[idx][i].m_flDesync = nil
            end
        end
        if side < 0 then
            if not resolver.safepoints[idx][3].m_flDesync then
                resolver.safepoints[idx][3].m_flDesync = -desync
            end
            if math.abs(resolver.safepoints[idx][3].m_flDesync) <= desync then
                resolver.safepoints[idx][3].m_flDesync = -desync
                resolver.safepoints[idx][3].m_playback_rate = resolver.layers[idx][6].m_playback_rate
            end
            if not resolver.safepoints[idx][3].m_playback_rate then
                resolver.safepoints[idx][3].m_playback_rate = resolver.layers[idx][6].m_playback_rate
            end
        elseif side > 0 then
            if not resolver.safepoints[idx][2].m_flDesync then
                resolver.safepoints[idx][2].m_flDesync = desync
            end
            if resolver.safepoints[idx][2].m_flDesync >= desync then
                resolver.safepoints[idx][2].m_flDesync = desync
                resolver.safepoints[idx][2].m_playback_rate = resolver.layers[idx][6].m_playback_rate
            end
            if not resolver.safepoints[idx][2].m_playback_rate then
                resolver.safepoints[idx][2].m_playback_rate = resolver.layers[idx][6].m_playback_rate
            end 
        else
            local m_flDesync = side * desync
            if not resolver.safepoints[idx][1].m_flDesync then
                resolver.safepoints[idx][1].m_flDesync = m_flDesync
            end
            if math.abs(resolver.safepoints[idx][1].m_flDesync) >= desync then
                resolver.safepoints[idx][1].m_flDesync = m_flDesync
                resolver.safepoints[idx][1].m_playback_rate = resolver.layers[idx][6].m_playback_rate
            end
            if not resolver.safepoints[idx][1].m_playback_rate then
                resolver.safepoints[idx][1].m_playback_rate = resolver.layers[idx][6].m_playback_rate
            end 
        end
        if resolver.safepoints[idx][2].m_playback_rate and resolver.safepoints[idx][3].m_playback_rate then
            local m_flDesync = side * desync
            if m_flDesync >= resolver.safepoints[idx][3].m_flDesync then
                if m_flDesync <= resolver.safepoints[idx][2].m_flDesync then
                    if not resolver.safepoints[idx][1].m_flDesync then
                        resolver.safepoints[idx][1].m_flDesync = m_flDesync
                    end
                    if math.abs(resolver.safepoints[idx][1].m_flDesync) >= desync then
                        resolver.safepoints[idx][1].m_flDesync = m_flDesync
                        resolver.safepoints[idx][1].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                    end
                    if not resolver.safepoints[idx][1].m_playback_rate then
                        resolver.safepoints[idx][1].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                    end 
                end
            end
        end
    end,
    transition = function(self, m_flWalkToRunTransition, m_bWalkToRunTransitionState, m_flLastUpdateIncrement, m_flVelocityLengthXY)
        local ANIM_TRANSITION_WALK_TO_RUN = false
        local ANIM_TRANSITION_RUN_TO_WALK = true
        local CSGO_ANIM_WALK_TO_RUN_TRANSITION_SPEED = 2.0
        local CS_PLAYER_SPEED_RUN = 260.0
        local CS_PLAYER_SPEED_DUCK_MODIFIER = 0.34
        local CS_PLAYER_SPEED_WALK_MODIFIER = 0.52
        if m_flWalkToRunTransition > 0 and m_flWalkToRunTransition < 1 then
            if m_bWalkToRunTransitionState == ANIM_TRANSITION_WALK_TO_RUN then
                m_flWalkToRunTransition = m_flWalkToRunTransition + m_flLastUpdateIncrement * CSGO_ANIM_WALK_TO_RUN_TRANSITION_SPEED
            else
                m_flWalkToRunTransition = m_flWalkToRunTransition - m_flLastUpdateIncrement * CSGO_ANIM_WALK_TO_RUN_TRANSITION_SPEED
            end
            m_flWalkToRunTransition = math.clamp(m_flWalkToRunTransition, 0, 1)
        end
        if m_flVelocityLengthXY > (CS_PLAYER_SPEED_RUN * CS_PLAYER_SPEED_WALK_MODIFIER) and m_bWalkToRunTransitionState == ANIM_TRANSITION_RUN_TO_WALK then
            m_bWalkToRunTransitionState = ANIM_TRANSITION_WALK_TO_RUN
            m_flWalkToRunTransition = math.max(0.01, m_flWalkToRunTransition)
        elseif m_flVelocityLengthXY < (CS_PLAYER_SPEED_RUN * CS_PLAYER_SPEED_WALK_MODIFIER) and m_bWalkToRunTransitionState == ANIM_TRANSITION_WALK_TO_RUN then
            m_bWalkToRunTransitionState = ANIM_TRANSITION_RUN_TO_WALK
            m_flWalkToRunTransition = math.min(0.99, m_flWalkToRunTransition)
        end
        return m_flWalkToRunTransition, m_bWalkToRunTransitionState
    end,
    predictedFootYaw = function(self, m_flFootYawLast, m_flEyeYaw, m_flLowerBodyYawTarget, m_flWalkToRunTransition, m_vecVelocity, m_flMinBodyYaw, m_flMaxBodyYaw)
        local m_flVelocityLengthXY = math.min(m_vecVelocity:length2d(), 260.0)
        local m_flFootYaw = math.clamp(m_flFootYawLast, -360, 360)
        local flEyeFootDelta = math.angle_diff(m_flEyeYaw, m_flFootYaw)
        if flEyeFootDelta > m_flMaxBodyYaw then
            m_flFootYaw = m_flEyeYaw - math.abs(m_flMaxBodyYaw)
        elseif flEyeFootDelta < m_flMinBodyYaw then
            m_flFootYaw = m_flEyeYaw + math.abs(m_flMinBodyYaw)
        end
        m_flFootYaw = math.angle_normalize(m_flFootYaw)
        local m_flLastUpdateIncrement = global_vars.interval_per_tick
        if m_flVelocityLengthXY > 0.1 or m_vecVelocity.z > 100 then
            m_flFootYaw = math.approach_angle(m_flEyeYaw, m_flFootYaw, m_flLastUpdateIncrement * (30.0 + 20.0 * m_flWalkToRunTransition))
        else
            m_flFootYaw = math.approach_angle(m_flLowerBodyYawTarget, m_flFootYaw, m_flLastUpdateIncrement * 100)
        end
        return m_flFootYaw
    end,
    main = function(self, idx)
        local resolver = self
        if not idx or idx <= 0 then return end
        local m_bIsValidIdx = entity.get_address(idx)
        if not m_bIsValidIdx then return end
        local animstate = entity.get_animstate(idx)
        if not animstate then return end
        resolver:updateLayers(idx)
        if not resolver.cache[idx] then
            resolver.cache[idx] = {}
        end
        local m_vecVelocity = entity.get_velocity(idx)
        local m_flVelocityLengthXY = m_vecVelocity:length2d()
        local m_flMaxDesyncDelta = resolver:getMaxDesyncDelta(idx)
        local m_flDesync = m_flMaxDesyncDelta * 57
        local m_flEyeYaw = animstate.m_flEyeYaw
        local m_flGoalFeetYaw = animstate.m_flGoalFeetYaw
        local m_flLowerBodyYawTarget = entity.get_prop(idx, 'm_flLowerBodyYawTarget') 
        local m_flAngleDiff = math.angle_diff(m_flEyeYaw, m_flGoalFeetYaw)
        local side = 0
        if m_flAngleDiff < 0 then
            side = 1
        elseif m_flAngleDiff > 0 then
            side = -1
        end
        local m_flAbsAngleDiff = math.abs(m_flAngleDiff)
        local m_flAbscacheDiff = math.abs(resolver.cache[idx].m_flAbsAngleDiff or m_flAbsAngleDiff)
        local m_bShouldTryResolve = true
        if m_flAbsAngleDiff > 0 or m_flAbscacheDiff > 0 then
            if m_flAbsAngleDiff < m_flAbscacheDiff then
                m_bShouldTryResolve = false
                if m_flVelocityLengthXY > (resolver.cache[idx].m_flVelocityLengthXY or 0) then
                    m_bShouldTryResolve = true
                end
            end
            if resolver:isLBYFlexing(idx) then m_bShouldTryResolve = true end
            if m_bShouldTryResolve then
                local m_flCurrentAngle = math.max(m_flAbsAngleDiff, m_flAbscacheDiff)
                if m_flAbsAngleDiff <= 10.0 and m_flAbscacheDiff <= 10.0 then
                    m_flDesync = m_flCurrentAngle
                elseif m_flAbsAngleDiff <= 35.0 and m_flAbscacheDiff <= 35.0 then
                    m_flDesync = math.max(29.0, m_flCurrentAngle)
                else
                    m_flDesync = math.clamp(m_flCurrentAngle, 29.0, 57)
                end
            end
        end
        m_flDesync = math.clamp(m_flDesync, 0, (m_flMaxDesyncDelta * 57))
        resolver:updateSafety(idx, side, m_flDesync)
        if m_flVelocityLengthXY > 5 and side ~= 0 then
            if resolver.safepoints[1] and resolver.safepoints[2] and resolver.safepoints[3] then
                if resolver.safepoints[1].m_playback_rate and resolver.safepoints[2].m_playback_rate and resolver.safepoints[3].m_playback_rate then
                    local server_playback = resolver.layers[idx][6].m_playback_rate
                    local center_playback = resolver.safepoints[1].m_playback_rate
                    local left_playback = resolver.safepoints[2].m_playback_rate
                    local right_playback = resolver.safepoints[3].m_playback_rate
                    local m_layer_delta1 = math.abs(server_playback - center_playback)
                    local m_layer_delta2 = math.abs(server_playback - left_playback)
                    local m_layer_delta3 = math.abs(server_playback - right_playback)
                    if m_layer_delta1 < m_layer_delta2 or m_layer_delta3 <= m_layer_delta2 then
                        if m_layer_delta1 >= m_layer_delta3 or m_layer_delta2 > m_layer_delta3 then
                            side = 1
                        end
                    else
                        side = -1
                    end
                end
            end
        end
        resolver.cache[idx].m_flAbsAngleDiff = m_flAbsAngleDiff
        resolver.cache[idx].m_flVelocityLengthXY = m_flVelocityLengthXY
        resolver.cache[idx].m_flDesync = m_flDesync * side
        resolver.cache[idx].m_flGoalFeetYaw = animstate.m_flGoalFeetYaw
        resolver.cache[idx].m_flWalkToRunTransition, resolver.cache[idx].m_bWalkToRunTransitionState = resolver:transition(
            resolver.cache[idx].m_flWalkToRunTransition or 0,
            resolver.cache[idx].m_bWalkToRunTransitionState or false,
            global_vars.interval_per_tick, m_flVelocityLengthXY
        )
        resolver.cache[idx].m_flPredictedFootYaw = resolver:predictedFootYaw(
            m_flGoalFeetYaw, m_flEyeYaw + resolver.cache[idx].m_flDesync, m_flLowerBodyYawTarget,
            resolver.cache[idx].m_flWalkToRunTransition, m_vecVelocity, -57, 57
        )
        animstate.m_flGoalFeetYaw = resolver.cache[idx].m_flPredictedFootYaw
    end
}
local hooked_function = nil
resolver.initMain = function(thisptr, edx)
    hooked_function(thisptr, edx)
    if not enabled:get_bool() then return end

    local lp = entity.get_local_player()
    if not lp or lp:get_index() <= 0 or lp:is_alive() == false then return end
    entities.for_each(function(ent)
        local idx = ent:get_index()
        if idx == nil then return end
        if ent:is_enemy() == false or ent:is_valid() == false then return end
        if lp:get_index() == idx or ent:is_alive() == false then return end

        resolver:main(idx)
    end)
end
local vmt_hook = nil
function on_run_command()
    local lp = engine.get_local_player()
    if not lp or entities.get_entity(lp):is_alive() == false then return end

    local lp_ptr = entity.get_address(lp)
    if not lp_ptr or hooked_function then return end
    vmt_hook = vmt.new(lp_ptr)
    hooked_function = vmt_hook.hookMethod("void(__fastcall*)(void*, void*)", resolver.initMain, 224)
end
function on_shutdown()
    for i, unHookFunc in ipairs(vmt.hooks) do
        unHookFunc()
    end
end
