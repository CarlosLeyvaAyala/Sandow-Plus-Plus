-- local dmlib = jrequire 'dmlib'
local l = jrequire 'sandowpp.shared'
local c = jrequire 'sandowpp.const'

local skills = {}

-- ;>========================================================
-- ;>===                   PROPERTIES                   ===<;
-- ;>========================================================

--- Property for the training (WGP) given by this skill.
function skills.skillTraining(data, skName, x)
    if x ~= nil then data.preset.bhv.skills[skName].training = x
    else return data.preset.bhv.skills[skName].training
    end
end

function skills.skillFatigue(data, skName)
    return data.preset.bhv.skills[skName].fatigue
end

function skills.trainingAndFatigue(data, skName)
    if not c.skills.physical[skName] and not c.skills.magical[skName] then
        return nil, nil
    else
        return skills.skillTraining(data, skName), skills.skillFatigue(data, skName)
    end
end

-- ;>========================================================
-- ;>===                     SETUP                      ===<;
-- ;>========================================================

local magFatigueRateMul = 2
local travSkPhys = l.traverse(c.skills.physical)
local travSkMag = l.traverse(c.skills.magical)

--- Sets a fatigue multiplier for a skill.
--- @param skName string
---@param _ nil
---@param data table
---@param val number
local function setFatigueMult(skName, _, data, val)
    data.preset.bhv.skills[skName].fatigue = val
end

--- Generates skill multipliers.
function skills.setMult(data, mult)
    travSkPhys(setFatigueMult, {data=data, extra=mult})
    travSkMag(setFatigueMult, {data=data, extra=magFatigueRateMul * mult})
end

--- Sets default training multipliers.
function skills.defaultTraining(data)
    -- No other way to do it than manually
    skills.skillTraining(data, c.skills.physical.Block, 0.25)
    skills.skillTraining(data, c.skills.physical.HeavyArmor, 0.33)
    skills.skillTraining(data, c.skills.physical.LightArmor, 0.2)
    skills.skillTraining(data, c.skills.physical.Marksman, 0.2)
    skills.skillTraining(data, c.skills.physical.OneHanded, 0.25)
    skills.skillTraining(data, c.skills.physical.Sneak, 0.25)
    skills.skillTraining(data, c.skills.physical.Smithing, 0.25)
    skills.skillTraining(data, c.skills.physical.TwoHanded, 0.5)

    skills.skillTraining(data, c.skills.magical.Alteration, 0.2)
    skills.skillTraining(data, c.skills.magical.Conjuration, 0.0)
    skills.skillTraining(data, c.skills.magical.Destruction, 0.0)
    skills.skillTraining(data, c.skills.magical.Illusion, 0.0)
    skills.skillTraining(data, c.skills.magical.Restoration, 0.15)
end

--- Generates default multipliers.
function skills.defaultMult(data)
    skills.setMult(data, 1)
end

--- Generates default values and multipliers for all skills.
--- @param data table
function skills.default(data)
    data.preset.bhv.skills.fatigueMul = 1 -- This value is used to configure mulitpliers in the mcm
    skills.defaultMult(data)
    skills.defaultTraining(data)
    return data
end

-- ;>========================================================
-- ;>===                TREE GENERATION                 ===<;
-- ;>========================================================

local function genSkillTrees(skName, _, data)
    print("Generating skill tree for: "..skName)
    data.preset.bhv.skills[skName] = {}
end

function skills.generateDataTree(data)
    print("Generating skills\n=================")
    data.preset.bhv.skills = {}

    travSkPhys(genSkillTrees, {data = data})
    travSkMag(genSkillTrees, {data = data})

    print("Finished generating skills\n")
    return data
end

return skills
