--[[

BSD 3-Clause License

Copyright (c) 2023, thrustfox (thrustfox@gmail.com)

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

AppInfo = {
  appName = 'bridgehead',
  ver = '1.00.000',
  verDate = '23/04/20',
  authorName = 'thrustfox',
  logHeader = 'BRIDGEHEAD_LOG'
}

FixedOption = {
  --useStepLimit, useLunchBox, useSmoke, curDifficulty, langCd
  langCd = 'kr'
}

myLog = mist.Logger:new(AppInfo.logHeader)

myConfigSet = 0
myConfig = {
  bPreInit = false,
  bPostInit = false,
}
eHandler = {}

function myDebug(a, b, force)
  if TestFeature.useLog ~= true and force ~= true then
    return
  end
  
  if b == nil then
    myLog:msg(a)
    return
  end

  if type(b) == 'table' then
    myLog:msg(a .. ':')
    myLog:msg(b)
  else
    myLog:msg(a .. ': ' .. b)
  end
end

function myRetail(a, b)
  myDebug(a, b, true)
end

function myDebug3(a, b, c)
  myDebug(a .. '\\ ' .. b, c)
end

function evtBroadcast(a, b)
  if TestFeature.bEvtBroadcast ~= true then
    return
  end
  if b == nil then
    Util.broadcast('[EVT] ' .. a)
  else
    Util.broadcast('[EVT] ' .. a .. ': ' .. b)
  end
end

TestFeature = {
  useLog = false,
  bEvtBroadcast = false,
  disableArrivalSupport = false,
  aerialDestSmoke = false,
  groundDestSmoke = false,
  debugReroute = false,
  debugRoute = false,
  debugAttacker = false,
  msgEvent = false,
  defenderHold = false,
  patrolHold = false,
  supportHold = false,
  testMenu = false,
  displayAutoAxisArea = false,
  disableRoeEmerPatrol = false,
  disableRoeArea = false,
  successCheckOnDestroyed = false,
  useLeftCnt = false,
  useDetectClient = false,
  broadcastT = false,
  useTestCard = false,
}

myDebug('--- script loading start')

PreConst = {
  aerialWaitingRoe = 'hold', -- hold여야 roeEmer 동작
}

Const = {
  axisInitial = {
    maxStep = 0,
    curStep = 1,
    finished = false,
    failed = false,
    zones = {},
    state = 'moving', -- moving, paused, occupying, garrison, finished
    timeToOccupyCnt = 0,
    searchCnt = 0,
    alertCoolCnt = 0,
  },
  lunchInitial = {

  },
  attackerInitial = {
    isAlive = true,
    axisIndex = 0,
  },
  defenderInitial = {
    isAlive = true,
    revealedPos = nil,
    zoneName = nil,
    axisIndex = 0
  },
  patrolInitial = {
    isAlive = true,
    baseWp = {},
    wp = {},
    wpIndex = 1,
    rerouteCnt = 0,
    roeState = 'hold',
    roeEmer = false,
    roeArea = false,
    unitCnt = 0,
    spawnCnt = 0,
    dispatchCnt = 0,
    patrolState = '', -- '', ready, on
    destAction = '', --PreConst.aerialWaitingRoe,
    dispatchAxis = '', -- index
  },
  supportInitial = {
    isAlive = true,
    baseWp = {},
    wp = {},
    wpIndex = 1,
    rerouteCnt = 0,
    roeState = 'hold',
    unitCnt = 0,
    spawnCnt = 0,
    spawnLeft = 0,
    dispatchCnt = 0,
    patrolState = '', -- '', ready, on
    destAction = '', --PreConst.aerialWaitingRoe,
    dispatchAxis = '', -- index
  },
  zoneInitial = {
    name = '',
    axisIndex = -1,
  },
  vzoneInitial = {
    name = '',
    axisIndex = -1,
    pos = nil,
    radius = 0,
    isSmoked = false,
    defenderLeft = 0,
    defenderLeftMax = 0,
    card = nil,
  },
  distCheckArrivalAttacker = 100, -- meter
  distCheckArrivalPatrol_Support = 1.6,
  distAttackerSearch = 1.8,
  generateWpOffset = 5.5,
  generateWpThreshold = 0.27,
  zoneGroundA = 'GROUND-A',
  zoneGroundD = 'GROUND-D',
  periodReroute = 5,
  distReroute = 11.1,
  spawnHeightAerial = 3000,
  distRoeEmer = 25,
  checkTerrainRadius = 15, -- meter
  spawnRadiusSub = 35, -- meter
  spawnRadiusSubInner = 25, -- meter
  validTerrainGnd = {'LAND', 'ROAD'},

  -- zone label
  zoneLabelRadiusStatic = 0.55,
  useZoneLabelRadiusStatic = true,
  zoneColors = {
    {1, 0, 0, 1},
    {0, 1, 0, 1},
    {0, 0, 1, 1},
    {0.5, 0, 0, 1},
    {0, 0.5, 0, 1},
    {0, 0, 0.5, 1},
  },
  zoneLabelColor = {1, 1, 1, 1},
  zoneLabelTextSize = 24,

  axisNames = {
    'Alpha',
    'Bravo',
    'Charlie',
    'Delta',
    'Echo',
    'Foxtrot',
    'Golf',
    'Hotel',
    'Indiana',
    'Jones',
    'Kilo',
    'Lima',
    'Mike',
  },

  minPPS = 3,
  maxTrial = 50,
  successCntMax = ({30, 10})[2],
  rollAlertMin = 1,
  rollAlertMax = 20,
  useRollProportional = true,
  isSym = ({':', ','})[2],
  separatorSym = ', ',
  broadcastShort = 15,
  broadcastLong = 30,
  wpAltitude = 4500, -- meter
  wpAltitudeAwacs = 9000,
  wpSpeed = 180,  -- "m/s"
  wpSpeedAwacs = 128,
  supportCallnames = {
    [1] = 7,
    [2] = 8,
  },
  supportCallnumber = 3,
  setEngageTypes = {'Fighters', 'Helicopters'},
  setEngageRadius = 30,
  useCardPick = true,
  useRestartMenu = true,
  useOperatorNameAlt = true,
  axisCntSuccessMax = 2,
  
  --constend
}

ConfigSet = {
  [0] = {
    langSupports = 0,
    clients = 0,
    attackerSets = 0,
    defenderSets = 0,
    defenderSetsForDepth = 0,
    defenderSetsFinalFront = 0,
    defenderSetsFinalBack = 0,
    typeToProto = 0,
    bigZones = 0,
    axisesManual = 0,
    patrolZones = 0,
    supportZones = 0,
    patrolZoneAuto = 0,
    supportZoneAuto = 0,

    const = {
      stepLimit = 2,
      testValue = 11,
      timeToOccupy = ({120, 10})[1],
      periodSearch = 120,
      rollAttackerSearch = ({4, 6})[2],
      colorAttackerSearch = trigger.smokeColor.Blue,
      periodPatrolSpawn = ({900, 30})[1],
      periodSupportSpawn = ({600, 10})[1],
      periodSupportSpawnAwacs = 10,
      periodDispatch = ({600, 300})[1],
      periodDispatchFriendly = ({600, 300})[1],
      rollAlertBasis = ({8, 18})[1],
      rollAlertDisperse = 4,
      rollAlertMultitude = 1,
      axisBias = 45,
      minDistPath = ({2.5, 2.5})[2],
      maxDistPath = ({3.5, 2.8})[2],
      minDistEntry = ({2.0, 2.1})[2],
      maxDistEntry = ({2.2, 2.3})[2],
      minRadiusAxis = 0.55,
      maxRadiusAxis = 0.83,
      radiusEntry = 0.35,
      useAxisesManual = false,
      useSupportManual = true,
      usePatrolManual = true,
      radiusSupportZoneAuto = 2.5,
      aerialWpType = 'flyOverPoint', -- 'turningpoint' or 'flyOverPoint'
      alertCoolMax = ({60, 5})[1],
      useSlowMode = false, -- not used. diminish roll alert
      useHeliMode = false, -- not used.
      diminishChanceRatio = 0.5,
      pathThreshold = 45, -- degree
      alertRadiusRatioMin = ({1.5, 5.0})[2],
      alertRadiusRatioMax = 9.0,
      smokeAccuracy = 30,
      typesSpecial = {
        ['LIGHT_A'] = 'msg_type_light',
        ['AAA_A'] = 'msg_type_aaa',
        ['SCOUT_A'] = 'msg_type_scout',
        ['SAM_A'] = 'msg_type_sam',
      },
      cardNumMax = 3,
      cardRange = 10,
      cardShapes = {
        'Axeman',
        'Scarecrow',
        'Beast',
        'Dorothy',
      },
      unknownCardName = 'Unknown',
      periodRestart = 20,
    }
  }
}

Role = {
  Operator = 'operator',
  Support = 'support',
  Axis = 'axis',
}

indexing = {
  lunchToDefender = {},
  unitToGroup = {},
  axisToAttacker = {},
  patrolUnitToIndex = {},
}

general = {
  defenders = {},
  attackers = {},
  lunches = {},
  axises = {},
  axisCnt = 0,
  zones = {},
  finishedAxis = {},
  patrols = {},
  supports = {},
  postInitialized = false,
  blockPostInit = false, -- no duplicate postInit
  curProfile = 1,
  vzones = {},
  vzonesSupport = {}, -- for backup
  locs = {},
  marks = {},
  markSeq = 0,
  successCnt = 0,
  slowMode = false,
  heliMode = false,
  isSuccess = false,
  isSuccessComplete = false,
  isFailed = false,
  fxId = { nextId = 500 },
  specialty = {},
  cardList = nil,
  cardPicked = {},
  totalDestroyed = 0,
  totalOccupied = 0,
  vote = {},
  restartCnt = 0,
  awacsName = '',
  
  --generalend
}

postConfig = {
  useStepLimit = true,
  useLunchBox = true,
  useSmoke = true,
  curDifficulty = 'normal',
  langCd = 'en',
  
  useHardMode = false,
  axisCntSuccess = 1,
  defendersMultitude = 2,
}

commandDb = {}

timerInfos = {
  {
    period = 1,
    fn = function () processSupport() end,
    preInit = true, -- active before postinit
    --periodFn = function () return onTest() end,
    --periodFn = onTest,
  },
  {
    period = 1,
    fn = function () processPatrol() end,
  },
  {
    period = 1,
    fn = function () processAxis() end,
  },
  {
    period = 1,
    fn = function () checkArrivalPatrol() end,
  },
  {
    period = 1,
    fn = function () checkArrivalSupport() end,
    enabled = not TestFeature.disableArrivalSupport,
    preInit = true,
  },
  {
    period = 1,
    fn = function () checkArrivalAttacker() end,
  },
  {
    period = 1,
    fn = function () checkSearch() end,
  },
  {
    period = 60,
    fn = function () updateReveal() end,
  },
}

Config = {
  langSupports = {
    [0] = {
      {
        name = 'English',
        langCd = 'en',
      },
      {
        name = 'Korean',
        langCd = 'kr',
      },
    },
    [1] = {
      {
        name = 'Korean',
        langCd = 'kr',
      },
    },
  },
  clients = {
    [0] = {
      -- fighters
      {
        groupName = 'Aerial-1',
      },
      {
        groupName = 'Aerial-2',
      },
      {
        groupName = 'Aerial-3',
      },
      {
        groupName = 'Aerial-4',
      },
      {
        groupName = 'Aerial-5',
      },
      {
        groupName = 'Aerial-6',
      },

      -- attackers
      {
        groupName = 'Aerial-7',
        isSlow = true,
      },
      {
        groupName = 'Aerial-8',
        isSlow = true,
      },
      {
        groupName = 'Aerial-9',
        isSlow = true,
      },
      {
        groupName = 'Aerial-10',
        isSlow = true,
      },

      -- reserved
      {
        groupName = 'Aerial-11',
      },
      {
        groupName = 'Aerial-12',
      },
      {
        groupName = 'Aerial-13',
      },
      {
        groupName = 'Aerial-14',
      },
      {
        groupName = 'Aerial-15',
      },

      
      -- helis
      {
        groupName = 'Rotary-1',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-2',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-3',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-4',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-5',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-6',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-7',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-8',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-9',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-10',
        isSlow = true,
        isHeli = true,
      },
      {
        groupName = 'Rotary-11',
        isSlow = true,
        isHeli = true,
      },
    },
  },
  patrolZoneAuto = {
    [0] = 'PATROL-GEN'
  },
  supportZoneAuto = {
    [0] = 'SUPPORT-GEN'
  },
  patrolZones = {
    [0] = {
      {
        name = 'PATROL-1',
        patrolType = 'PATROL_D',
      },
      {
        name = 'PATROL-2',
        patrolType = 'PATROL_D',
      },
    }
  },
  supportZones = {
    [0] = {
      {
        name = 'SUPPORT-1',
        unitName = 'Bart',
        supportType = 'SUPPORT_A',
        spawnLeft = 1,
      },
      {
        name = 'SUPPORT-2',
        unitName = 'Lisa',
        supportType = 'SUPPORT_A',
        isCas = false,
        isHeli = false,
        spawnLeft = 1,
      },
      {
        name = 'SUPPORT-3',
        unitName = 'Support_3DP',
        supportType = 'SUPPORT_A2',
        isAwacs = true,
        spawnLeft = 0,
      },
    }
  },
  bigZones = {
    [0] = {
      'AREA-1',
      'AREA-2',
      'AREA-3',
      'AREA-4',
      'AREA-5',
    },
  },
  axisesManual = {
    [0] = {
      { 'ENTRY_1', 'AREA-11', 'AREA-22', 'AREA-11B', 'AREA-22B', },
      { 'ENTRY_2', 'AREA-33', 'AREA-44', },
    }
  },
  attackerSets = {
    [0] = {
      {
        payload = {
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
        },
        roll = 0
      },
      -- roll map: (4, 4, 5, 4) -> (20, 16, 16, 9.6)%
      {
        payload = {
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'AAA_A',
        },
        roll = 4
      },
      {
        payload = {
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'LIGHT_A',
        },
        roll = 4
      },
      {
        payload = {
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'SAM_A',
        },
        roll = 5
      },
      {
        payload = {
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'TRANSPORT_A',
          'SCOUT_A',
        },
        roll = 4
      },
    }
  },
  defenderSets = {
    [0] = {
      {
        payload = {
          'HEAVY_D',
          'HEAVY_D',
          'HEAVY_D',
          'HEAVY_D',
        },
        roll = 0
      },

      -- roll map: (10, 10, 6) -> (50, 25, 20)%
      {
        payload = {
          'HEAVY_D',
          'HEAVY_D',
          'HEAVY_D',
          'AAA_D',
        },
        roll = 10
      },
      {
        payload = {
          'HEAVY_D',
          'HEAVY_D',
          'HEAVY_D',
          'SAM_D',
        },
        roll = 10
      },
      {
        payload = { 
          'HEAVY_D',
          'HEAVY_D',
          'HEAVY_D',
          'LIGHT_D',
        },
        roll = 16
      },
    }
  },
  defenderSetsForDepth = {
    [0] = {
      --[2] = {
      --  {
      --    payload = {
      --      'AAA_D',
      --      'SAM_D',
      --      'SAM_D',
      --      'SAM2_D',
      --    },
      --    roll = 19
      --  },
      --},
      [3] = {
        --{
        --  payload = {
        --    'AAA_D',
        --    'SAM_D',
        --    'SAM_D',
        --    'SAM2_D',
        --  },
        --  roll = 19
        --},
      },
    }
  },
  defenderSetsFinalFront = {
    [0] = {
      {
        payload = {
          'HEAVY_D',
          'HEAVY_D',
          'HEAVY_D',
          'SAM_D',
        },
        roll = 10
      },

      -- roll map: (4, 5, 5, 7, 4, 5) -> (20, 20, 15, 15.8, 5.9, 5.9)%
      {
        payload = {
          'HEAVY_D',
          'HEAVY_D',
          'AAA_D',
          'AAA_D',
        },
        roll = 4
      },
      {
        payload = {
          'LIGHT_D',
          'LIGHT_D',
          'AAA_D',
          'AAA_D',
        },
        roll = 5
      },
      {
        payload = {
          'LIGHT_D',
          'LIGHT_D',
          'HEAVY_D',
          'HEAVY_D',
        },
        roll = 5
      },
      { 
        payload = {
          'HEAVY_D',
          'HEAVY_D',
          'HEAVY_D',
          'SAM2_D',
        },
        roll = 7
      },
      { 
        payload = {
          'HEAVY_D',
          'HEAVY_D',
          'SAM_D',
          'SAM2_D',
        },
        roll = {4, 1}
      },
      {
        payload = {
          'AAA_D',
          'SAM_D',
          'SAM_D',
          'SAM2_D',
        },
        roll = {5, 1}
      },
    }
  },
  defenderSetsFinalBack = {
    [0] = {
    }
  },
  typeToProto = {
    [0] = {
      HEAVY_D = { 'D-T72', 'D-T72B3', 'D-T80', 'D-T90', },
      LIGHT_D = { 'D-BTR80', 'D-BTRRD','D-MTLB','D-BMD1','D-BMP1','D-BMP2','D-BMP3','D-BTR82A',},
      SAM_D = { 'D-GOPHER', 'D-TUNGUSKA', 'D-GASKIN', },
      SAM2_D = { 'D-OSA', 'D-TOR', },
      AAA_D = { 'D-ZU23-CE', 'D-ZU23-EM', 'D-HL-ZU23', 'D-LC-ZU23', 'D-SHILKA', 'D-ZSU57', 'D-ZU23-URAL', 'D-GEPARD', },
      LUNCH = { 'D-66', 'D-43101', 'D-375', 'D-4320T', 'D-131', 'D-135', },
      PATROL_D = { 'D-SU33', 'D-SU27', 'D-SU30', 'D-MIG23', 'D-MIG29', },
      PATROLSUB_D = { 'D-SU25', },
      SUPPORT_A = { 'A-FA18', 'A-F15', 'A-F16', 'A-M2000'},
      SUPPORTSUB_A = { 'A-A10', },
      SUPPORT_A2 = { 'A-E2D', },

      TRANSPORT_A = { 'A-BEDFORD', 'A-M939', },
      LIGHT_A = { 'A-M113', 'A-TPZ', 'A-ATGM-STRYKER', 'A-LAV25', 'A-STRYKER', 'A-M2A2', 'A-STRYKER-MGS', },
      SCOUT_A = { 'A-SCOUT-HMM', 'A-ATGM-HMM', },
      AAA_A = { 'A-VULCAN', 'A-GEPARD', },
      SAM_A = { 'A-AVENGER', 'A-CHAPARRAL', 'A-LINEBACKER', 'A-ROLAND', },
    },
    [1] = {
      HEAVY_D = { 'HEAVY_D_PROTO_1', },
      LIGHT_D = { 'LIGHT_D_PROTO_1', },
      SAM_D = { 'SAM_D_PROTO_1', },
      AAA_D = { 'AAA_D_PROTO_1', },
      LUNCH = { 'LUNCH_PROTO_1' },
      PATROL_D = { 'PATROL_D_PROTO_1', },
      PATROLSUB_D = { 'PATROLSUB_D_PROTO_1', },
      SUPPORT_A = { 'SUPPORT_A_PROTO_1', },
      SUPPORTSUB_A = { 'SUPPORTSUB_A_PROTO_1', },
      SUPPORT_A2 = { 'SUPPORT_A_PROTO_2', },

      TRANSPORT_A = { 'TRANSPORT_A_PROTO_1', },
      LIGHT_A = { 'LIGHT_A_PROTO_1' },
      SCOUT_A = { 'SCOUT_A_PROTO_1' },
    },
  },
}


-- utilbm

Util = {
  bracketStr = function (value, squared)
    value = value or 'nil'
    if squared == true then
      return '[' .. value .. ']'
    else
      return '(' .. value .. ')'
    end
  end,
  
  difficultyStr = function (value)
    if value == 'normal' then
      return Msg.getText('msg_difficulty_normal')
    elseif value == 'easy' then
      return Msg.getText('msg_difficulty_easy')
    elseif value == 'hard' then
      return Msg.getText('msg_difficulty_hard')
    end
    return ''
  end,

  curTotalStr = function (cur, total)
    return '(' .. cur .. '/' .. total .. ')'
  end,
  
  yesNoStr = function (value)
    if value == true then
      return Msg.getText('msg_yes')
    end
    return Msg.getText('msg_no')
  end,
  
  nullProblem = function (value)
    return value or ''
  end,
  
  getStateStr = function (state)
    if state == 'moving' then
      return Msg.getText('msg_st_moving')
    elseif state == 'paused' then
      return Msg.getText('msg_st_paused')
    elseif state == 'occupying' then
      return Msg.getText('msg_st_occupying')
    elseif state == 'garrison' then
      return Msg.getText('msg_st_garrison')
    elseif state == 'finished' then
      return Msg.getText('msg_st_finished')
    end
    return ''
  end,
  
  easyList = function (title, list)
    myDebug(title)
    chain(list).each(function (d)
        myDebug(d)
    end)
  end,

  unidirectTrue = function (cur, set)
    return cur or set
  end,

  unidirectFalse = function (cur, set)
    return cur and set
  end,

  checkFinished = function (successCnt)
    return Util.getFinished() >= successCnt
  end,
  
  getFinished = function ()
    return chain(general.finishedAxis)
      .filter(function (d) return d == true end).size()
  end,
  
  isSupportAlive = function (eleIndex)
    return chain(general.supports)
      .filter(function (ele, i)
          return ele.initialIndex == eleIndex
             end)
      .some(function (ele)
          return ele.isAlive
           end)
  end,
  
  isSupportRestoring = function (eleIndex)
    return chain(general.supports)
      .filter(function (ele, i)
          return ele.initialIndex == eleIndex
             end)
      .some(function (ele)
          return ele.isAlive and ele.spawnCnt > 0
           end)
  end,
  
  isSupportAvailable = function (eleIndex)
    -- alive and non-patrol state and non-awacs and non-respawning
    return chain(general.supports)
      .filter(function (ele, i)
          return ele.initialIndex == eleIndex
             end)
      .some(function (ele)
          return ele.isAlive and ele.isAwacs ~= true and ele.patrolState == '' and ele.spawnCnt <= 0
           end)
  end,
  
  isSupportOnDispatch = function (eleIndex)
    return chain(general.supports)
      .filter(function (ele, i)
          return ele.initialIndex == eleIndex
             end)
      .some(function (ele)
          return ele.isAlive and ele.patrolState ~= '' and ele.spawnCnt <= 0
           end)
  end,
  
  getNextId = function (nextIdCont)
    nextIdCont = nextIdCont or {}
    local nextId = nextIdCont.nextId
    nextIdCont.nextId = nextIdCont.nextId + 1
    return nextId
  end,
  
  notifyOP = function (msgId, opt)
    opt = opt or {}
    opt.prefix = Util.prefixBy(Role.Operator)
    Msg.notifyC(msgId, opt)
  end,

  notifyAX = function (msgId, index, opt)
    opt = opt or {}
    opt.prefix = Util.prefixBy(Role.Axis, index)
    Msg.notifyC(msgId, opt)
  end,
  
  notifySP = function (msgId, index, opt)
    opt = opt or {}
    opt.prefix = Util.prefixBy(Role.Support, index)
    Msg.notifyC(msgId, opt)
  end,
  
  limit = function (value, a, b)
    if value < a then
      return a
    elseif value > b then
      return b
    end
      
    return value
  end,
  
  getSwapped = function (obj)
    local newObj = {}
    newObj[1] = obj[2]
    newObj[2] = obj[1]
    return newObj
  end,
  
  checkLToR = function (pos1, pos2, orient)
    return let({
        mist.utils.toDegree(mist.utils.getHeadingPoints(pos1, pos2)),
        },
      function (heading)
        return (heading > orient and heading <= orient + 180)
    end).value()
  end,
  
  checkDualPath = function (pos1, pos2, minDist, orient)
    -- heading : degree
    return mist.utils.get2DDist(pos1, pos2) >= minDist and 
      let({
          mist.utils.toDegree(mist.utils.getHeadingPoints(pos1, pos2)),
          myConfig.const.pathThreshold / 2
          },
        function (heading, halfTh)
          return (heading > orient + 90 - halfTh and heading <= orient + 90 + halfTh) or
            (heading > orient + 270 - halfTh and heading <= orient + 270 + halfTh)
      end).value()
  end,
  
  checkAndGen = function (genFn, checkFn, maxCnt, fnName)
    -- until checkFn is true(true is ok)
    fnName = fnName or 'checkAndGen'
    local isOk = false
    local nCnt = 0
    local res
    while isOk == false do
      res = genFn()
      if checkFn(res) then
        isOk = true
      end
      nCnt = nCnt + 1
      if nCnt > maxCnt then
        Util.unexpected(fnName, 'maxCnt exceeded')
        isOk = true
      end
    end
    return res
  end,
  
  makeZoneKey_axis = function (axisIndex, zoneIndex) -- for axis
    return 'Z' .. axisIndex .. '-' .. zoneIndex
  end,

  makeZoneKey_support = function (supportIndex) -- for support
    return 'S' .. supportIndex
  end,

  makeZoneKey_patrol = function (patrolIndex) -- for patrol
    return 'P' .. patrolIndex
  end,

  generateLocsFromSupportZoneAuto = function (supportZone, genCnt)
    local fnName = 'generateLocsFromSupportZoneAuto'
    return rigid({
        trigger.misc.getZone(supportZone)
    }).stage(fnName, 'zone null', function (zone)
               return range(genCnt).map(function (i)
                   return {
                     pos = Util.makeVec3GL(mist.getRandPointInCircle(zone.point, zone.radius)),
                     radius = mist.utils.NMToMeters(myConfig.const.radiusSupportZoneAuto),
                   }
               end).value()
    end).value()
  end,

  generateLocsFromSupportZones = function (supportZones)
    local fnName = 'generateLocsFromSupportZones'
    return chain(supportZones).map(function (supportZone)
        return rigid({
            trigger.misc.getZone(supportZone.name)
        }).stage(fnName, 'zone null', function (zone)
                   local x = zone.point.x
                   local z = zone.point.z
                   local y = land.getHeight({x = x, y = z})
                   return {
                     pos = { x = x, y = y, z = z},
                     radius = zone.radius
                   }
        end).value()
    end).value()
  end,

  generateLocsFromAxisesAuto = function (bigZones)
    local fnName = 'generateLocsFromAxisesAuto'
    local bigZoneCnt = #bigZones

    mist.marker.remove(general.marks)
    general.marks = {}

    
    local posGen = {}
    chain(bigZones).map(function (bigZone, bzi)
        return rigid({
            trigger.misc.getZone(bigZone)
        }).stage(fnName, 'zone null', function (zone)
                   return rigid({
                       Util.getZonePosition(zone),
                       zone.radius})
                     .stage(fnName, 'zone info null', function (pos, radius)
                              if #posGen >= bigZoneCnt then
                                return
                              end
                              
                              local minDist = mist.utils.NMToMeters(myConfig.const.minDistPath)
                              local maxDist = mist.utils.NMToMeters(myConfig.const.maxDistPath)
                              local minDistEntry = mist.utils.NMToMeters(myConfig.const.minDistEntry)
                              local maxDistEntry = mist.utils.NMToMeters(myConfig.const.maxDistEntry)
                              local rShrinked = radius - maxDist
                              local posInfos = Util.checkAndGen(
                                function ()
                                  return {
                                    mist.getRandPointInCircle(pos, rShrinked),
                                    mist.getRandPointInCircle(pos, rShrinked)
                                  }
                                end,
                                function (posInfo2)
                                  return Util.checkTerrainValid2(posInfo2[1]) and Util.checkTerrainValid2(posInfo2[2])
                                end,
                                Const.maxTrial
                                , 'init'
                              )

                              if not Util.checkDualPath(posInfos[1], posInfos[2], minDist, myConfig.const.axisBias) or #posGen + 2 > bigZoneCnt then
                                local pos1, pos3, pos0
                                pos3 = Util.checkAndGen(
                                  function () return getRandPointForRoute(posInfos[1], minDist, maxDist, true) end,
                                  function (pos) return Util.checkTerrainValid2(pos) end,
                                  Const.maxTrial
                                , 'pos3'
                                )
                                pos1 = Util.checkAndGen(
                                  function () return getRandPointForRoute(posInfos[1], minDist, maxDist, false) end,
                                  function (pos) return Util.checkTerrainValid2(pos) end,
                                  Const.maxTrial
                                , 'pos1'
                                )
                                pos0 = Util.checkAndGen(
                                  function () return getRandPointForRoute(pos1, minDistEntry, maxDistEntry, false) end,
                                  function (pos) return Util.checkTerrainValid2(pos) end,
                                  Const.maxTrial
                                , 'pos0'
                                )
                                local path = {}
                                path[#path + 1] = { pos = pos0    , radius = mist.utils.NMToMeters(myConfig.const.radiusEntry) }
                                path[#path + 1] = { pos = pos1    , radius = getRandRadius() }
                                path[#path + 1] = { pos = posInfos[1] , radius = getRandRadius() }
                                path[#path + 1] = { pos = pos3    , radius = getRandRadius() }
                                posGen[#posGen + 1] = path
                                
                              else
                                if not Util.checkLToR(posInfos[1], posInfos[2], myConfig.const.axisBias) then
                                  posInfos = Util.getSwapped(posInfos)
                                end

                                chain(posInfos).each(function (posInfo, i)
                                    local pos1, pos3, pos0
                                    if i == 1 then
                                      pos3 = Util.checkAndGen(
                                        function () return getRandPointForRouteLW(posInfo, minDist, maxDist, true) end,
                                        function (pos) return Util.checkTerrainValid2(pos) end,
                                        Const.maxTrial
                                        , 'pos3L'
                                      )
                                      pos1 = Util.checkAndGen(
                                        function () return getRandPointForRouteLW(posInfo, minDist, maxDist, false) end,
                                        function (pos) return Util.checkTerrainValid2(pos) end,
                                        Const.maxTrial
                                        , 'pos1L'
                                      )
                                    else
                                      pos3 = Util.checkAndGen(
                                        function () return getRandPointForRouteRW(posInfo, minDist, maxDist, true) end,
                                        function (pos) return Util.checkTerrainValid2(pos) end,
                                        Const.maxTrial
                                        , 'pos3R'
                                      )
                                      pos1 = Util.checkAndGen(
                                        function () return getRandPointForRouteRW(posInfo, minDist, maxDist, false) end,
                                        function (pos) return Util.checkTerrainValid2(pos) end,
                                        Const.maxTrial
                                        , 'pos1R'
                                      )
                                    end
                                    pos0 = Util.checkAndGen(
                                      function () return getRandPointForRoute(pos1, minDistEntry, maxDistEntry, false) end,
                                      function (pos) return Util.checkTerrainValid2(pos) end,
                                      Const.maxTrial
                                      , 'pos0'
                                    )
                                    
                                    local path = {}
                                    path[#path + 1] = { pos = pos0    , radius = mist.utils.NMToMeters(myConfig.const.radiusEntry) }
                                    path[#path + 1] = { pos = pos1    , radius = getRandRadius() }
                                    path[#path + 1] = { pos = posInfo , radius = getRandRadius() }
                                    path[#path + 1] = { pos = pos3    , radius = getRandRadius() }
                                    posGen[#posGen + 1] = path
                                end)

                                
                              end
                              
                              if TestFeature.displayAutoAxisArea == true then
                                local zoneColor = Util.getZoneColor(1)
                                local fxId = Util.getNextId(general.fxId)
                                trigger.action.circleToAll(-1, fxId, Util.makeVec3GL(pos), radius, zoneColor[1], zoneColor[2], 4)
                                general.marks[#general.marks + 1] = fxId
                                general.markSeq = general.markSeq + 1
                                fxId = Util.getNextId(general.fxId)
                                trigger.action.circleToAll(-1, fxId, Util.makeVec3GL(pos), rShrinked, zoneColor[1], zoneColor[2], 4)
                                general.marks[#general.marks + 1] = fxId
                                general.markSeq = general.markSeq + 1
                              end
                              
                           end).value()
                end).value()
    end).value()

    posGen = chain(posGen).map(function (locs)
        return chain(locs).map(function (loc)
            return { pos = Util.makeVec3GL(loc.pos), radius = loc.radius }
        end).value()
    end).value()

    if TestFeature.displayAutoAxisArea == true then
      local zoneColor = Util.getZoneColor(2)
      chain(posGen).each(
        function (d, i)
          chain(d).each(
            function (d2, i2)
              local fxId = Util.getNextId(general.fxId)
              trigger.action.circleToAll(-1, fxId, Util.makeVec3GL(d2.pos), d2.radius, zoneColor[1], zoneColor[2], 4)
              general.marks[#general.marks + 1] = fxId
              general.markSeq = general.markSeq + 1
            end)
        end)
    end

    return posGen
    
  end,
  
  generateLocsFromAxisesManual = function (axisZonesManual)
    local fnName = 'generateLocsFromAxisZones'
    -- axisZones -> zone names
    -- axisInfos -> pos and radius
    return chain(axisZonesManual).map(function (axisZone)
        return chain(axisZone).map(function (zone)
            return rigid({
                trigger.misc.getZone(zone)
            }).stage(fnName, 'zone null', function (zone)
                       local x = zone.point.x
                       local z = zone.point.z
                       local y = land.getHeight({x = x, y = z})
                       return {
                         pos = { x = x, y = y, z = z},
                         radius = zone.radius
                       }
            end).value()
        end).value()
    end).value()
  end,
  
  isStateForStopMenu = function (state)
    return true
  end,

  isStateForResumeMenu = function (state)
    return true
  end,

  getAttackerLeft = function ()
    local res = range(general.axisCnt).reduce({}, function (state, axisIndex)
        local vlist = chain(general.attackers)
          .filter(function (attacker)
              return attacker.axisIndex == axisIndex and attacker.isAlive
                 end)
          .value()
        state[axisIndex] = #vlist
        return state
    end)
    return res
  end,
  
  isAttackerLeft = function (axisIndex)
    local vlist = chain(general.attackers)
      .filter(function (attacker)
          return attacker.axisIndex == axisIndex and attacker.isAlive
             end)
      .value()

    return chain(general.attackers)
      .filter(function (attacker)
          return attacker.axisIndex == axisIndex and attacker.isAlive
             end)
      .some(function (attacker)
          return true
      end)
  end,
  
  makeVec3GL = function (pos2)
    local v3Pos = mist.utils.makeVec3(pos2)
    v3Pos.y = land.getHeight({x = v3Pos.x, y = v3Pos.z})
    return v3Pos
  end,
  
  getVzoneByName = function (zoneName)
    -- return: vec3
    return chain(general.vzones)
      .filter(function (vzone) return vzone.name == zoneName end)
      .doFirst(function (vzone)
          return vzone
      end)
  end,
 
  checkTerrainValid2 = function (position)
    -- position: vec2 position
    
    if not mist.isTerrainValid(position, Const.validTerrainGnd) then
      return false
    end

    local v3Pos = mist.utils.makeVec3(position)
    v3Pos.y = land.getHeight({x = v3Pos.x, y = v3Pos.z})
    
    local volS = {
      id = world.VolumeType.SPHERE,
      params = {
        point = v3Pos,
        radius = Const.checkTerrainRadius,
      }
    }
    local founds = {}
    local cbFound = function (item)
      founds[#founds + 1] = item
    end
    world.searchObjects(Object.Category.SCENERY, volS, cbFound)
    if #founds > 0 then
      return false
    end
    
    return true
  end,
  
  checkTerrainValid = function (position)
    -- position: vec2 position
    
    if not mist.isTerrainValid(position, Const.validTerrainGnd) then
      return false
    end

    local v3Pos = position
    v3Pos.y = land.getHeight({x = v3Pos.x, y = v3Pos.z})
    
    local volS = {
      id = world.VolumeType.SPHERE,
      params = {
        point = v3Pos,
        radius = Const.checkTerrainRadius,
      }
    }
    local founds = {}
    local cbFound = function (item)
      founds[#founds + 1] = item
    end
    world.searchObjects(Object.Category.SCENERY, volS, cbFound)
    if #founds > 0 then
      return false
    end
    
    return true

    --Object.Category
    --UNIT    1
    --WEAPON  2
    --STATIC  3
    --BASE    4
    --SCENERY 5
    --Cargo   6
    
    --LAND 
    --SHALLOW_WATER 
    --WATER 
    --ROAD 
    --RUNWAY
  end,

  setCas = function (groupName)
    local fnName = 'setCas'
    rigid({
        Group.getByName(groupName)
    }).stage(fnName, 'group nil', function (group)
      --group:getController():resetTask()
      group:getController():pushTask(
        {
          id = 'EngageTargets', 
          params = { 
            targetTypes = {'All'},
            priority = 1 
          }           
        })
    end)
  end,
  
  setEngage = function (groupName, pos, radius, targetTypes)
    local fnName = 'setEngage'
    targetTypes = targetTypes or Const.setEngageTypes
    radius = radius or Const.setEngageRadius
    radius = mist.utils.NMToMeters(radius)
    myDebug3(fnName, 'enter', { groupName, pos, targetTypes })
    
    rigid({
        Group.getByName(groupName)
    }).stage(fnName, 'group nil', function (group)
      group:getController():pushTask(
        {
          id = 'EngageTargetsInZone', 
          params = { 
            point = pos,
            zoneRadius = radius,
            targetTypes = targetTypes,
            priority = 1 
          }           
        })
    end)
  end,
  
  setAwacs = function (groupName)
    local fnName = 'setAwacs'
    rigid({
        Group.getByName(groupName)
    }).stage(fnName, 'group nil', function (group)
      group:getController():pushTask(
        {
          id = 'AWACS', 
          params = { 
          }           
        })
    end)
  end,

  setGroundRoeByGroup = function (groupName, roeState)
    -- roeState: 'free', 'return', 'hold'
    local fnName = 'setGroundRoeByGroup'
    local roeVal = AI.Option.Ground.val.ROE.WEAPON_HOLD
    if roeState == 'free' then
      roeVal = AI.Option.Ground.val.ROE.OPEN_FIRE
    elseif roeState == 'return' then
      roeVal = AI.Option.Ground.val.ROE.RETURN_FIRE
    else
    end
    rigid({
        Group.getByName(groupName)
    }).stage(fnName, 'group nil', function (group)
      group:getController():setOption(AI.Option.Ground.id.ROE, roeVal)
    end)
    
  end,

  setRoeFromRoeArea = function (ele, eleIndex)
    local fnName = 'setRoeFromRoeArea'
    myDebug3(fnName, 'enter', { roeState = ele.roeState, roeEmer = ele.roeEmer, index = eleIndex })
    
    if ele.roeState ~= 'free' and ele.roeEmer ~= true then
      local roeState
      if ele.roeArea == true then
        roeState = 'free'
      else
        roeState = 'hold'
      end
      Util.setRoeByGroup(ele.name, roeState)

    else
      if ele.roeArea == true then
        evtBroadcast('ROE-AREA ON IGNORE ' .. ele.protoName)
      else
        evtBroadcast('ROE-AREA OFF IGNORE ' .. ele.protoName)
      end
    end
  end,
  
  setRoeFromRoeEmer = function (ele, eleIndex)
    local fnName = 'setRoeFromRoeEmer'
    myDebug3(fnName, 'enter', { roeState = ele.roeState, roeEmer = ele.roeEmer, index = eleIndex })
    
    if ele.roeState ~= 'free' and ele.roeArea ~= true then
      local roeState
      if ele.roeEmer == true then
        if ele.patrolState == 'ready' then
          ele.patrolState = 'on'
          evtBroadcast('PATROL ON ' .. ele.protoName)
        end
        
        roeState = 'free'
      else
        roeState = 'hold'
      end
      Util.setRoeByGroup(ele.name, roeState)

    else
      if ele.roeEmer == true then
        evtBroadcast('ROE-EMER ON IGNORE ' .. ele.protoName)
      else
        evtBroadcast('ROE-EMER OFF IGNORE ' .. ele.protoName)
      end
    end
  end,
  
  setRoeFromRoe = function (ele, eleIndex)
    local fnName = 'setRoeFromRoe'
    myDebug3(fnName, 'enter', { roeState = ele.roeState, roeEmer = ele.roeEmer, index = eleIndex })

    if ele.roeEmer ~= true and ele.roeArea ~= true then
      Util.setRoeByGroup(ele.name, ele.roeState)
    else
      if ele.roeState == 'free' then
        evtBroadcast('ROE ON IGNORE ' .. ele.protoName)
      else
        evtBroadcast('ROE OFF IGNORE ' .. ele.protoName)
      end
    end
  end,

  setInvisible = function (groupName, invisible)
    local fnName = 'setInvisible'
    
    rigid({
        Group.getByName(groupName)
    }).stage(fnName, 'group nil', function (group)
      group:getController():setCommand(
        {
          id = 'SetInvisible', 
          params = {
            value = invisible
          }           
        })

      if invisible == true then
        Util.evtBroadcastT('SET-INVISIBLE ON ' .. groupName)
      else
        Util.evtBroadcastT('SET-INVISIBLE OFF ' .. groupName)
      end

    end)
  end,
  
  setRoeByGroup = function (groupName, roeState, noBroadcast, force)
    -- roe: 'free', 'return', 'hold'
    local fnName = 'setRoeByGroup'
    

    local fnName = 'setRoeByGroup'
    local roeVal = AI.Option.Air.val.ROE.WEAPON_HOLD
    local aa = true
    local ag = true
    if roeState == 'free' then
      if noBroadcast ~= true then
        evtBroadcast('ROE ON ' .. groupName)
      end
      roeVal = AI.Option.Air.val.ROE.WEAPON_FREE
      aa = false
      ag = false
    elseif roeState == 'open' then
      roeVal = AI.Option.Air.val.ROE.OPEN_FIRE
    elseif roeState == 'return' then
      roeVal = AI.Option.Air.val.ROE.RETURN_FIRE
    else
      if noBroadcast ~= true then
        evtBroadcast('ROE OFF ' .. groupName)
      end
    end
    rigid({
        Group.getByName(groupName)
    }).stage(fnName, 'group nil', function (group)

      if force ~= true and TestFeature.patrolHold == true and Util.isGroupPatrol(groupName) then
      elseif force ~= true and TestFeature.supportHold == true and Util.isGroupSupport(groupName) then
      else
        group:getController():setOption(AI.Option.Air.id.ROE, roeVal)
        --group:getController():setOption(AI.Option.Air.id.PROHIBIT_AA, aa)
        --group:getController():setOption(AI.Option.Air.id.PROHIBIT_AG, ag)
      end
               
    end)
    
  end,
  
  booleanStr = function (value)
    if value then
      return 'true'
    else
      return 'false'
    end
  end,
  
  getAxisByRoll = function (curIndex)
    local ret = let({
        range(general.axisCnt).reduce({}, function (state, axisIndex)
            if axisIndex == curIndex then return state else return { axisIndex, unpack(state) } end
        end)
    }, function (axises)
        return branch({}, #axises > 0,
          function ()
            return axises[mist.random(#axises)]
          end,
          function ()
            return {}
        end).value()
    end).value()
    
  end,

  getAxisName = function (axisIndex)
    local axisNamesSize = #Const.axisNames
    local nameIndex = axisIndex % axisNamesSize
    return Const.axisNames[nameIndex]
  end,
  
  getZoneName = function (axisIndex, zoneIndex)
    local axisNamesSize = #Const.axisNames
    local nameIndex = axisIndex % axisNamesSize
    return Const.axisNames[nameIndex] .. '-' .. zoneIndex
  end,
  
  getDimColor = function (color)
    local dimColor = {}
    chain(color).each(function (value, i)
        if i <= 3 then
          dimColor[#dimColor+1] = value
        end
    end)
    dimColor[#dimColor+1] = 0.2
    return dimColor
  end,
  
  getZoneColor = function (axisIndex)
    local zoneColorsSize = #Const.zoneColors
    local colorIndex = axisIndex % zoneColorsSize
    return { Const.zoneColors[colorIndex], Util.getDimColor(Const.zoneColors[colorIndex]) }
  end,
  
  getDispatchedPatrolCnt = function ()
    res = chain(general.patrols).filter(function (patrol) return patrol.dispatchCnt > 0 end).size()
    return res
  end,

  getNextPatrolIndex = function ()
    local fnName = 'getNextPatrolIndex'
    
    if Util.getDispatchedPatrolCnt() >= #general.patrols then return -1 end
    
    local index = mist.random(#general.patrols)
    local nCnt = 0
    while general.patrols[index].dispatchCnt > 0 do
      index = mist.random(#general.patrols)

      nCnt = nCnt + 1
      if nCnt > Const.maxTrial then
        Util.unexpected(fnName, 'maxTrial exceeded')
        break
      end
    end
    if general.patrols[index].dispatchCnt > 0 then
      return -1
    else
      return general.patrols[index].initialIndex
    end
  end,
  
  isEmpty = function (str)
    return str == nil or str == ''
  end,
  
  isResumableState = function (state)
    if state == 'paused' then
      return true
    else
      return false
    end
  end,
  
  isStoppableState = function (state)
    if state == 'moving' then
      return true
    else
      return false
    end
  end,
  
  isGroupClient = function (groupName)
    return find(myConfig.clients,
                function (d)
                  return d.groupName == groupName
                end) ~= nil
  end,

  isGroupClientSlow = function (groupName)
    return find(myConfig.clients,
                function (d)
                  return d.groupName == groupName and d.isSlow == true
                end) ~= nil
  end,

  isGroupClientHeli = function (groupName)
    return find(myConfig.clients,
                function (d)
                  return d.groupName == groupName and d.isHeli == true
                end) ~= nil
  end,

  isGroupSupport = function (groupName)
    return find(general.supports,
                function (d)
                  return d.name == groupName
                end) ~= nil
  end,

  isGroupSupportNonAwacs = function (groupName)
    return find(general.supports,
                function (d)
                  return d.name == groupName and d.isAwacs ~= true
                end) ~= nil
  end,

  isGroupPatrol = function (groupName)
    return find(general.patrols,
                function (d)
                  return d.name == groupName
                end) ~= nil
  end,

  isGroupAttacker = function (groupName)
    return find(general.attackers,
                function (d)
                  return d.name == groupName
                end) ~= nil
  end,

  isGroupDefender = function (groupName)
    return find(general.defenders,
                function (d)
                  return d.name == groupName
                end) ~= nil
  end,
  
  getGroupPos = function (groupName, unitIndex)
    unitIndex = unitIndex or 1
    local group = Group.getByName(groupName)
    if (group) then
      local units = group:getUnits()
      if #units >= unitIndex then
        return group:getUnit(unitIndex):getPosition().p
      end
    end
    return nil
  end,
  
  getTime = function ()
    return timer.getTime()
  end,
  
  addToList = function (list, template, args)
    local newValue = deepcopy(template)
    for k, v in pairs(args) do
      newValue[k] = v
    end
    list[#list + 1] = newValue
    return newValue
  end,

  update = function (table, updated)
    for k, v in pairs(updated) do
      table[k] = v
    end
  end,
  
  updateAxisState = function (axisIndex, state)
    if axisIndex <= general.axisCnt then
      axis = general.axises[axisIndex]
      Util.update(axis, state)
    end
  end,
  
  updateDefenderState = function (groupName, state)
    each(general.defenders, function (d)
           if d.name == groupName then
             Util.update(d, state)
           end
    end)
  end,
  
  testFn = function ()
  end,
  getLunchNames = function()
    return map(general.lunches, function (ele)
                 return ele.name
    end)
  end,
  getDefenderNames = function()
    return map(general.defenders, function (ele)
                 return ele.name
    end)
  end,
  getPatrolNames = function()
    return map(general.patrols, function (ele)
                 return ele.name
    end)
  end,
  getSupportNames = function()
    return map(general.supports, function (ele)
                 return ele.name
    end)
  end,
  getAttackerNames = function()
    return map(general.attackers, function (ele)
                 return ele.name
    end)
  end,
  getAttackersForAxis = function (axisIndex)
    return filter(general.attackers, function (ele)
                    return ele.axisIndex == axisIndex and ele.isAlive
    end)
  end,
  getZonePosition = function (zone)
    local x = zone.point.x
    local z = zone.point.z
    local y = land.getHeight({x = x, y = z})
    return { x = x, y = y, z = z}
  end,
  unexpected = function (name, reason, module)
    if module == nil or module.len == 0 then
      myDebug('******* ' .. name .. ': ' .. reason)
    else
      myDebug('******* [' .. module .. '] ' .. name .. ': ' .. reason)
    end
  end,
  confirm = function (condition, name, reason, module)
    if not condition then
      Util.unexpected(name, reason, module)
      return false
    end
    return true
  end,
  confirmStr = function (str, name, reason, module)
    return Util.confirm(not Util.isEmpty(str), name, reason, module)
  end,
  broadcast = function (msg, coalition, period)
    coalition = coalition or 2
    period = period or Const.broadcastShort
    trigger.action.outTextForCoalition(coalition, msg .. '\n', period)
  end,
  broadcastDefS = function (msg, coalition, period)
    Util.broadcast(msg, coalition, period)
    Msg.notifyC('msg_dummy_for_sound', { audioOnly = true })
  end,
  getOperatorName = function ()
    if Const.useOperatorNameAlt then
      return general.awacsName
    end
    
    return Msg.getText('msg_operator')
  end,
  
  prefixBy = function (role, index)
    local fnName = 'prefixBy'
    
    if role == Role.Operator then
      return Util.wrapNarrator(Util.getOperatorName())
    end

    if role == Role.Support then
      return branch({}, index >= 1 and index <= #general.supports,
        function ()
          return chain(general.supports)
            .filter(function (ele, i)
                return ele.initialIndex == index
                   end)
            .doFirst(function (ele)
                return Util.wrapNarrator(ele.displayName)
                    end) or ''
          
        end
      ).value()
    end

    if role == Role.Axis then
      return rigid({ index }).stage(fnName, 'axisIndex null', function (axisIndex)
                                   return let({
                                       chain(general.attackers)
                                         .find(function (attacker)
                                             return attacker.axisIndex == axisIndex and attacker.isAlive
                                              end)
                                   }, function (attacker)
                                       return rigid({
                                           attacker
                                       }).stage(fnName, 'attacker for axis not left',
                                                function (attacker)
                                                  return Util.wrapNarrator(Util.getAxisName(axisIndex) .. '-' .. attacker.groupIndex)
                                                end
                                               ).value()
                                   end).value()
      end).value()
    end
  end,
  
  broadcastBy = function (msg, role, index, opt)
    local fnName = 'broadcastBy'
    opt = opt or {}
    period = opt.period -- operator only
    msgId = opt.msgId -- msgId for audio
    if role == Role.Operator then
      Util.broadcast(Util.wrapNarrator(Util.getOperatorName()) .. msg, nil, period)
      Msg.notifyC(msgId, { audioOnly = true })
    end

    if role == Role.Support then
      branch({}, index >= 1 and index <= #general.supports,
        function ()

          chain(general.supports)
            .filter(function (ele, i)
                return ele.initialIndex == index
                   end)
            .doFirst(function (support)
              
              branch({}, support.isAlive == true,
                function ()
                  Util.broadcast(Util.wrapNarrator(support.displayName) .. msg)
                  Msg.notifyC(msgId, { audioOnly = true })
                end,
                function ()
                end
              )

            end)

        end
      )
    end

    if role == Role.Axis then
      rigid({ index }).stage(fnName, 'axisIndex null', function (axisIndex)
                                   let({
                                       chain(general.attackers)
                                         .find(function (attacker)
                                             return attacker.axisIndex == axisIndex and attacker.isAlive
                                              end)
                                   }, function (attacker)
                                       branch({}, attacker == nil,
                                         function ()
                                         end,
                                         function ()
                                           let({
                                               Util.getAxisName(axisIndex)
                                           }, function (axisName)
                                               Util.broadcast(Util.wrapNarrator(axisName .. '-' .. attacker.groupIndex) .. msg)
                                               Msg.notifyC(msgId, { audioOnly = true })
                                           end)
                                         end
                                       )
                                   end)
      end)
    end
  end,
  
  getCurAlertRadiusForAxis = function (axisIndex)
    local fnName = 'getCurAlertRadiusForAxis'

    return rigid({general.axises[axisIndex]})
      .stage(fnName, 'axis null', function (axis)
               return rigid({axis.alertRadiuses, axis.curStep})
                 .stage(fnName, 'axis info null', function (alertRadiuses, curStep)
                          return alertRadiuses[curStep]
                       end).value()
      end).value()
  end,
  
  getCurVzoneForAxis = function (axisIndex)
    local fnName = 'getCurVzoneForAxis'

    return rigid({general.axises[axisIndex]})
      .stage(fnName, 'axis null', function (axis)
               return rigid({axis.vzones, axis.curStep})
                 .stage(fnName, 'axis info null', function (vzones, curStep)
                          return vzones[curStep]
                       end).value()
            end)
      .stage(fnName, 'vzoneName null', function (vzoneName)
               return Util.getVzoneByName(vzoneName)
            end)
      .stage(fnName, 'vzone null', function (vzone)
               return { vzone, vzone.pos, vzone.name }
            end).value()

  end,

  wrapNarrator = function (narrator)
    narrator = narrator or ''
    return narrator .. Const.isSym .. ' '
    --return '[' .. narrator .. ']' .. Const.isSym .. ' '
  end,

  isNumber = function (ch)
    if ch == '0' or ch == '1' or ch == '2' or ch == '3' or ch == '4' or ch == '5' or ch == '6' or ch == '7' or ch == '8' or ch == '9' then
      return true
    end
    return false
  end,

  trimNumberPlus = function (str)
    str = str or ''
    local found = nil
    range(string.len(str)).reverse().each(function (i)
        local ch = string.sub(str, i, i)
        if not Util.isNumber(ch) and ch ~= '-' and found == nil then
          found = i
        end
    end)

    if found ~= nil then
      return string.sub(str, 1, found)
    end
    return str
  end,

  trimBySize = function (str, size)
    str = str or ''
    size = size or 1
    if string.len(str) > size then
      return string.sub(str, 1, string.len(str) - size)
    else
      return ''
    end
  end,

  evtBroadcastT = function (msg, coalition, period)
    if TestFeature.broadcastT == true then
      Util.broadcast(msg, coalition, period)
    end
  end,
  
  setCallsign = function (groupName, callname, number)
    local fnName = 'setCallsign'
    
    rigid({
        Group.getByName(groupName)
    }).stage(fnName, 'group nil', function (group)
      group:getController():setCommand(
        {
          id = 'SetCallsign', 
          params = {
            callname = callname,
            number = number
          }           
        })

    end)
  end,

  randomMulti = function (high, multitude)
    -- with no duplicate
    local fnName = 'randomMulti'
    local selected = {}

    range(multitude).each(function (i)
        selected[#selected + 1] = Util.checkAndGen(
          function ()
            return mist.random(high)
          end,
          function (num)
            return not contains(selected, num)
          end,
          Const.maxTrial,
          fnName
        )
                         end)

    return selected
  end,

  getCardName = function (card)
    local fnName = 'getCardName'
    return rigid({
        card.cardShape,
        card.cardNum
    }).stage(fnName, 'shape, num', function (cardShape, cardNum)
               return branch({}, cardShape <= #myConfig.const.cardShapes,
                 function ()
                   return myConfig.const.cardShapes[cardShape]
                 end,
                 function ()
                   return myConfig.const.unknownCardName
                 end
               ).value() .. ' ' .. cardNum
    end).value() or ''
  end,

  defenderSetConcat = function (base, addition)
    return let({
        chain(base).filter(function (d, i) return i == 1 end).value(),
        chain(base).filter(function (d, i) return i > 1 end).value(),
        },
      function (head, rest)
        return tableConcat(tableConcat(head, addition), rest)
      end
    ).value()
  end,

  isDeckComplete = function ()
    return #general.cardPicked == myConfig.const.cardNumMax
  end,

  getTrueVotes = function ()
    return chain(general.vote).filter(function (d) return d.value == true end).value()
  end,

  getClientIds = function ()
    -- return active client groud id and name pair
    local res = chain(myConfig.clients)
      .filter(function (client)
          return let({
              Group.getByName(client.groupName)
          }, function (group)
              return branch({}, group ~= nil, function ()
                  return true
              end).value()
          end).value()
      end)
      .map(function (client)
          return let({
              Group.getByName(client.groupName)
          }, function (group)
              return {
                id = Group.getID(group),
                groupName = client.groupName,
              }
          end).value()
      end).value()

    return res
  end,

  generateAwacsName = function ()
    general.awacsName = chain(general.supports)
      .filter(function (ele, i)
          return ele.isAwacs == true
             end)
      .doFirst(function (ele)
          return ele.displayName
              end) or ''
    myDebug('awacsName', general.awacsName)
  end,

  getLangName = function (langCd)
    if langCd == 'kr' then
      return 'Korean'
    end
    if langCd == 'en' then
      return 'English'
    end
    return ''
  end,

  getOptionTitle = function (cmdId, separator)
    local cmdIdToMsg = {
      CHANGE_OPT_DIFFICULTY  = Msg.getText('msg_opt_difficulty'),
      CHANGE_OPT_EXTENDED    = Msg.getText('msg_opt_extended'),  
      CHANGE_OPT_LUNCHBOX    = Msg.getText('msg_opt_lunchbox'),  
      CHANGE_OPT_SMOKE       = Msg.getText('msg_opt_smoke'),     
      CHANGE_OPT_LANG        = Msg.getText('msg_opt_lang'),      
    }
    local title = cmdIdToMsg[cmdId] or ''
    if cmdId == 'CHANGE_OPT_EXTENDED' then
      title = title .. separator .. Util.yesNoStr(not postConfig.useStepLimit)
    elseif cmdId == 'CHANGE_OPT_LUNCHBOX' then
      title = title .. separator .. Util.yesNoStr(postConfig.useLunchBox)
    elseif cmdId == 'CHANGE_OPT_SMOKE' then
      title = title .. separator .. Util.yesNoStr(postConfig.useSmoke)
    elseif cmdId == 'CHANGE_OPT_DIFFICULTY' then
      title = title .. separator .. Util.difficultyStr(postConfig.curDifficulty)
    elseif cmdId == 'CHANGE_OPT_LANG' then
      title = title .. separator .. Util.getLangName(postConfig.langCd)
    end
    return title
  end,

  dumpMsg = function ()
    local fnName = 'dumpMsg'
    local curDb = Msg.getCurDb()
    local akeys = keys(curDb)
    local audioMode = false
    
    chain(akeys).each(function (key)
        local value = curDb[key]
        local audioStr = '{ '
        if type(value) == 'table' then
          local text = value.text

          if type(text) == 'table' then
            if #text >= 1 then
              if type(text[1]) == 'table' then
                -- complex
                chain(text).each(function (d, i)
                    local key1 = key
                    if #text > 1 then
                      key1 = key .. '_' .. i
                    end
                    audioStr = audioStr .. '\'' .. key1 .. '.ogg\', '
                    local msg1 = d.payload
                    if not audioMode then
                      myDebug('msg1', 'complex|' .. key1 .. '|' .. msg1)
                    end
                end)
              else
                -- array
                chain(text).each(function (msg1)
                    local key1 = key
                    if #text > 1 then
                      key1 = key .. '_' .. i
                    end
                    audioStr = audioStr .. '\'' .. key1 .. '.ogg\', '
                    if not audioMode then
                      myDebug('msg1', 'array|' .. key1 .. '|' .. msg1)
                    end
                end)
              end
            end
          else
            -- simple text
            local msg1 = text
            local key1 = key
            audioStr = audioStr .. '\'' .. key1 .. '.ogg\', '
            if not audioMode then
              myDebug('msg1', 'text|' .. key1 .. '|' .. msg1)
            end
          end
          audioStr = audioStr .. '},'
          if audioMode then
            myDebug('msg1', audioStr)
          end
          
        else
          Util.unexpected(fnName, 'msgData error')
        end
    end)
  end,

  
  --utilend
}



function makeSpecialtyMsg()
  local fnName = 'makeSpecialtyMsg'
  
  if postConfig.langCd ~= 'kr' then
    return let(
      {
        range(general.axisCnt)
          .reduce('',
                  function (res, axisIndex)
                    local separator = ''
                    if res ~= '' then
                      separator = Const.separatorSym
                    end
                    return let(
                      {
                        general.specialty[axisIndex]
                      },
                      function (specialty)
                        return branch({}, specialty ~= nil,
                          function ()
                            return res .. separator.. Msg.getText(myConfig.const.typesSpecial[specialty]) .. '(' .. Util.getAxisName(axisIndex) .. ')'
                          end,
                          function ()
                            return res
                          end
                        ).value()
                      end
                    ).value()
                 end)
      },
      function (content)
        return branch({}, Util.isEmpty(content),
          function ()
            return ''
          end,
          function ()
            return Msg.getText('msg_specialty_desc') .. content 
          end
        ).value()
      end
    ).value()
  end
  
  return let(
    {
      range(general.axisCnt)
        .reduce('',
                function (res, axisIndex)
                  local separator = ''
                  if res ~= '' then
                    separator = Const.separatorSym
                  end
                  return let(
                    {
                      general.specialty[axisIndex]
                    },
                    function (specialty)
                      return branch({}, specialty ~= nil,
                        function ()
                          return res .. separator .. Util.getAxisName(axisIndex) .. ' ' .. Msg.getText('msg_at_attack_force') .. ' ' .. Msg.getText(myConfig.const.typesSpecial[specialty])
                        end,
                        function ()
                          return res
                        end
                      ).value()
                    end
                  ).value()
               end)
    },
    function (content)
      return branch({}, Util.isEmpty(content),
        function ()
          return ''
        end,
        function ()
          return content .. Msg.getText('msg_specialty_footer')
        end
      ).value()
    end
  ).value()
  
end


function getRandRadius()
  local min = mist.utils.NMToMeters(myConfig.const.minRadiusAxis)
  local max = mist.utils.NMToMeters(myConfig.const.maxRadiusAxis)
  return min + mist.random(max - min)  
end


function getRandPointForRoute(pos, minDist, maxDist, forward)
  local fnName = 'getRandPointForRoute'
  return branch({}, forward == true,
    function ()
      return { min = myConfig.const.axisBias - 45, max = myConfig.const.axisBias + 45 }
    end,
    function ()
      return { min = myConfig.const.axisBias - 45 + 180, max = myConfig.const.axisBias + 45 + 180 }
  end)
    .stage(fnName, 'heading info null', function (headingInfo)
             return mist.getRandPointInCircle(pos, maxDist, minDist, headingInfo.max, headingInfo.min)
    end).value()
end

function getRandPointForRouteLW(pos, minDist, maxDist, forward)
  -- left wing
  local fnName = 'getRandPointForRouteLW'
  return branch({}, forward == true,
    function ()
      return { min = myConfig.const.axisBias - 45, max = myConfig.const.axisBias }
    end,
    function ()
      return { min = myConfig.const.axisBias + 180, max = myConfig.const.axisBias + 45 + 180 }
  end)
    .stage(fnName, 'heading info null', function (headingInfo)
             return mist.getRandPointInCircle(pos, maxDist, minDist, headingInfo.max, headingInfo.min)
    end).value()
end

function getRandPointForRouteRW(pos, minDist, maxDist, forward)
  -- right wing
  local fnName = 'getRandPointForRouteRW'
  return branch({}, forward == true,
    function ()
      return { min = myConfig.const.axisBias, max = myConfig.const.axisBias + 45 }
    end,
    function ()
      return { min = myConfig.const.axisBias - 45 + 180, max = myConfig.const.axisBias + 180 }
  end)
    .stage(fnName, 'heading info null', function (headingInfo)
             return mist.getRandPointInCircle(pos, maxDist, minDist, headingInfo.max, headingInfo.min)
    end).value()
end

function doRoll(roll, desc)
  local fnName = 'doRoll'
  if type(roll) == 'table' then
    return rigid({
        roll[1],
        roll[2]
    }).stage(fnName, 'wrong roll table', function (rollNum, multi)
               if rollNum < multi and Const.useRollProportional ~= true then
                 rollNum = multi
               end
               local total = 0
               if Const.useRollProportional == true then
                 total = mist.random(20 * multi)
               else
                 for i=1,multi do
                   local num = mist.random(20)
                   total = total + num
                 end
               end
               --if desc ~= nil then
               --  myDebug(desc .. ': ' .. total .. '/' .. (rollNum))
               --end
               return total <= rollNum
    end).value() or false
  else
    local num = mist.random(20)
    --if desc ~= nil then
    --  myDebug(desc .. ': ' .. num .. '/' .. (roll))
    --end
    return num <= roll
  end
end

function getByRoll(selections)
  local fnName = 'getByRoll'
-- 1) no table
-- 2) table of table (has roll = 0)
-- 3) table

  -- 1)
  if type(selections) ~= 'table' then
    return selections
  end

  -- 2)
  local rollParam = nil
  chain(selections).doFirst(function (selection)
      rollParam = branch({}, type(selection) == 'table', function ()
          return let({
              selection.roll,
              selection.payload,
          }, function (roll, payload)
              if roll == 0 and payload ~= nil then
                return { useRoll = true }
              end
          end).value()
      end).value()
  end)

  if rollParam ~= nil then
    return let({
        reduce(slice(selections, 1), { selection = nil }, function (res, cur)
                 return let({
                     cur.roll,
                     cur.payload
                 }, function (roll, payload)
                     if res.selection == nil and roll ~= nil and payload ~= nil then
                       if doRoll(roll) then
                         return { selection = cur }
                       end
                     end
                     return res
                 end).value()
        end),
    }, function (res)
        return branch({}, res.selection == nil,
          function ()
            return selections[1].payload
          end,
          function ()
            return res.selection.payload
        end).value()
    end).value()
  else
    -- 3)
    if #selections > 0 then
      return selections[mist.random(#selections)]
    end
  end
  
end

function doByRoll(selections, func)
  local selection = getByRoll(selections)
  if selection then
    func(selection)
  end
end

function makeSmoke(pos, color)
  -- trigger.action.signalFlare(pos, color, 0)
  trigger.action.smoke(pos, color, 0)
end

function generateProtoForType(type, exceptList)
  exceptList = exceptList or {}
  
  local proto = Util.checkAndGen(
    function ()
      return getByRoll(myConfig.typeToProto[type])
    end,
    function (proto1)
      return not contains(exceptList, proto1)
    end,
    Const.maxTrial)
  
  return proto
end

function generateAttackerProtos()

  local typesCont = getByRoll(myConfig.attackerSets)
  local localMap = {}
  local specialNames = chain(myConfig.const.typesSpecial).keys().value()

  local specialty = chain(typesCont).reduce({}, function (res, cur)
                if contains(specialNames, cur) then
                  return { found = cur }
                else
                  return res
                end
            end)['found']
  
  local protos = map(typesCont, function (type)
                       return preferably({
                           function ()
                             return localMap[type]
                           end,
                           function ()
                             return let({
                                 generateProtoForType(type)
                             }, function (proto)
                                 localMap[type] = proto
                                 return proto
                             end).value()
                           end
                       })
  end)
  
  return { protos = protos, specialty = specialty }
end

function generateDefenderProtos(curDepth, totDepth)
  local fnName = 'generateDefenderProtos'
  
  local isFinal = curDepth == totDepth
  local defenderSets

  if myConfig.defenderSetsForDepth[curDepth] ~= nil then
    defenderSets = Util.defenderSetConcat(myConfig.defenderSets, myConfig.defenderSetsForDepth[curDepth])
  else
    defenderSets = myConfig.defenderSets
  end
  
  if isFinal == true then
    if myConfig.defenderSetsFinalFront ~= nil then
      defenderSets = Util.defenderSetConcat(defenderSets, myConfig.defenderSetsFinalFront)
    end
    if myConfig.defenderSetsFinalBack ~= nil then
      defenderSets = tableConcat(defenderSets, myConfig.defenderSetsFinalBack)
    end
  end
  
  local typesCont = getByRoll(defenderSets)
  local localMap = {}
  local protos = map(typesCont, function (type)
                       return preferably({
                           function ()
                             return localMap[type]
                           end,
                           function ()
                             return let({
                                 generateProtoForType(type)
                             }, function (proto)
                                 localMap[type] = proto
                                 return proto
                             end).value()
                           end
                       })
  end)
  
  return protos
end


function spawnDefenderForZone(vzoneName, curDepth, totDepth)
  local fnName = 'spawnDefenderForZone'
  
  local protoNames = generateDefenderProtos(curDepth, totDepth)
  if postConfig.useHardMode == true then
    protoNames = chain(protoNames).multiple(postConfig.defendersMultitude).value()
  end

  local lunchProtoName = generateProtoForType('LUNCH')
  
  each(protoNames, function(protoName, i)
         spawnDefenderByProto(vzoneName, protoName, i, lunchProtoName)
  end)
  chain(general.vzones)
    .filter(function (d)
        return d.name == vzoneName
    end)
    .doFirst(function (d)
       d.defenderLeft = #protoNames 
       d.defenderLeftMax = #protoNames 
    end)
end

function spawnAttackerForVzone(vzoneName, axisIndex)
  local info = generateAttackerProtos()
  local protoNames = info.protos
  local specialty = info.specialty
  each(protoNames, function(protoName, i)
         spawnAttackerByProto(vzoneName, protoName, axisIndex, i)
  end)
  general.specialty[axisIndex] = specialty
end


function spawnAttackerByProto(vzoneName, protoName, axisIndex, groupIndex)
  local fnName = 'spawnAttackerByProto'

  local v3SpawnPos = rigid({
      Util.getVzoneByName(vzoneName)
  }).stage(fnName, 'vzone null', function (vzone)
             local pos = vzone.pos
             local radius = vzone.radius
             local v2SpawnPos = Util.checkAndGen(
               function ()
                 return mist.getRandPointInCircle(pos, radius)
               end,
               function (pos)
                 return Util.checkTerrainValid2(pos)
               end,
               Const.maxTrial)

             return Util.makeVec3GL(v2SpawnPos)
          end).value()

  local spawnName = rigid({
      mist.teleportToPoint({groupName = protoName, point = v3SpawnPos, action = 'clone'})
      -- ground units can teleport only to ground, road type
  }).stage(fnName, 'spawnObj null', function (spawnObj)
             return let({spawnObj['name']}, function (name)
                 trigger.action.groupStopMoving(Group.getByName(name))
                 each(Group.getByName(name):getUnits(),
                      function(unit)
                        indexing.unitToGroup[unit:getName()] = name
                      end
                 )
                 return name
             end).value()
          end).value()

  
  local attacker = deepcopy(Const.attackerInitial)
  attacker.name = spawnName
  attacker.axisIndex = axisIndex
  attacker.groupIndex = groupIndex
  general.attackers[#general.attackers + 1] = attacker

end

function generate2PointsAroundZone(zoneName, offset, threshold) -- not used currently
  local fnName = 'generate2Pt'
  
  return let({
      offset or 5000,
      threshold or 500
  }, function (offset, threshold)
    return rigid({ trigger.misc.getZone(zoneName) }).stage(fnName, 'zone null',
        function (zone)
          return rigid({
              Util.getZonePosition(zone),
              mist.getRandomPointInZone(zoneName)
          }).stage(fnName, 'zonePos null',
                   function (zonePos, pos2)
                     return { pos2, mist.getRandPointInCircle(pos2, offset + threshold, offset) }
                   end
          ).value()
        end
    ).value()
  end).value() or {}
  
end

function generate3PointsAroundZone(zoneName, offset, threshold)
  local fnName = 'generate3PointsAroundZone'
  
end

function generate3PointsAroundVzone(zoneName, offset, threshold)
  local fnName = 'generate3PointsAroundVzone'
  
  return let({
      offset or 5000,
      threshold or 500
  }, function (offset, threshold)

      return rigid({Util.getVzoneByName(zoneName)})
        .stage(fnName, 'vzone null', function (vzone)
                 return rigid({
                     mist.getRandPointInCircle(vzone.pos, vzone.radius)
                 }).stage(fnName, 'pos2 null', function (pos2)
                            return {
                              mist.getRandPointInCircle(pos2, offset + threshold, offset),
                              pos2,
                              mist.getRandPointInCircle(pos2, offset + threshold, offset),
                            }
                         end).value()
              end).value()

  end).value() or {}
  
end

function dispatchByAxis(eleIndex, axisIndex, isFriendly)
  local fnName = 'dispatchByAxis'

  rigid({Util.getCurVzoneForAxis(axisIndex)})
    .stage(fnName, 'vzone info null', function (zoneInfo)
             dispatchByZone(eleIndex, zoneInfo[3], axisIndex, isFriendly)
          end)
end
  
function dispatchByZone(eleIndex, zoneName, axisIndex, isFriendly)
  local pos = generateWpAroundZone(zoneName)
  local wp = slice(pos, 1)
  dispatchByWp(eleIndex, wp, axisIndex, isFriendly)
end
  
function dispatchByWp(eleIndex, wp, axisIndex, isFriendly)
  local alist = nil
  if isFriendly == true then
    alist = general.supports
  else
    alist = general.patrols
  end

  chain(alist)
    .filter(function (ele, i) return eleIndex == ele.initialIndex end)
    .doFirst(function (ele)
        if isFriendly == true then
          Util.notifySP('msg_dispatching', eleIndex)
          evtBroadcast('DISPATCHING(S) ' .. eleIndex .. ' ' .. axisIndex)
        else
          evtBroadcast('DISPATCHING ' .. eleIndex .. ' ' .. axisIndex)
        end
        if ele.dispatchCnt == 0 then
          ele.wp = wp
          ele.wpIndex = 1
          if isFriendly == true then
            ele.dispatchCnt = myConfig.const.periodDispatchFriendly
          else
            ele.dispatchCnt = myConfig.const.periodDispatch
          end
          ele.patrolState = 'ready'
          if ele.isCas == true then
            ele.destAction = 'free'
          else
            ele.destAction = ''
          end
          ele.roeState = 'hold'
          ele.dispatchAxis = axisIndex
          setRouteAerial(ele.name, ele, {isFriendly = isFriendly, isHeli = ele.isHeli, isAwacs = ele.isAwacs})
        end
    end)
end

function returnFromDispatch(eleIndex, isFriendly)
  local alist = nil
  if isFriendly == true then
    alist = general.supports
  else
    alist = general.patrols
  end

  chain(alist)
    .filter(function (ele, i) return eleIndex == ele.initialIndex end)
    .doFirst(function (ele)
        if isFriendly == true then
          Util.notifySP('msg_dispatch_returning', eleIndex)
          evtBroadcast('RETURNING(S) ..' .. eleIndex)
        else
          evtBroadcast('RETURNING ..' .. eleIndex)
        end
        ele.wp = ele.baseWp
        ele.wpIndex = 1
        ele.dispatchCnt = 0
        ele.destAction = ''
        ele.roeState = 'hold'
        ele.patrolState = ''
        Util.setRoeFromRoe(ele)
        setRouteAerial(ele.name, ele, {isFriendly = isFriendly, isHeli = ele.isHeli, isAwacs = ele.isAwacs})
    end)

end

function setRouteAerial(groupName, info, opt)
  local fnName = 'setRoute'
  -- info should include wp, wpIndex

  rigid({
      {info, 'wp'},
      {info, 'wpIndex'}}).shift(fnName, 'wp info not found',
        function (wp, wpIndex)
          rigid({wp}).condition(fnName, 'wpIndex overflow', wpIndex <= #wp, function (curWp)
            if wpIndex == #curWp then
              curWp = reverse(curWp)
            end
            
            moveAerialGroupByName(groupName, curWp, opt)
            
          end)
        end
      )
  
end

function generateWpAroundZone(zoneName)
  return generate3PointsAroundVzone(zoneName, mist.utils.NMToMeters(Const.generateWpOffset), mist.utils.NMToMeters(Const.generateWpThreshold))
end

function spawnSupportByProto(protoName, zoneName, isAwacs, displayName, isHeli, spawnLeft, initialIndex, isCas)
  local fnName = 'spawnSupportByProto'

  general.supports = chain(general.supports)
    .filter(function (support) return support.zone ~= zoneName end)
    .value()
  
  local pos = generateWpAroundZone(zoneName)
  local spawnPos = mist.utils.makeVec3(pos[1])
  spawnPos.y = land.getHeight({x = spawnPos.x, y = spawnPos.z}) + Const.spawnHeightAerial
  local action = 'clone'
  if isAwacs == true then
    action = 'respawn'
  end
  
  local group = mist.teleportToPoint({groupName = protoName, point = spawnPos, action = action})
  rigid({ group }).stage(fnName, 'group nil', function (group)
    local groupName = group['name']
    local unitCnt = 0
    local callSign = ''
    rigid({ Group.getByName(groupName) }).stage(fnName, 'group2 nil', function (group2)
      each(group2:getUnits(), function(unit)
             rigid({
                 unit
             }).stage(fnName, 'null: unit', function (unit)
                        if isAwacs == true then
                          callSign = unit:getCallsign()
                        else
                          callSign = Util.trimBySize(unit:getCallsign(), 1)
                        end
                        indexing.unitToGroup[unit:getName()] = groupName
                        unitCnt = unitCnt + 1
             end)
      end)
    end)

    local wp = slice(pos, 1)
    local support = Util.addToList(general.supports, Const.supportInitial,
      {
        name = groupName,
        protoName = protoName,
        zone = zoneName,
        baseWp = wp,
        wp = wp,
        unitCnt = unitCnt,
        isAwacs = isAwacs,
        displayName = callSign,
        isHeli = isHeli,
        spawnLeft = spawnLeft,
        initialIndex = initialIndex,
        isCas = isCas,
      }
    )
    Util.setRoeByGroup(support.name, support.roeState, true, true)
    if isAwacs == true then
      Util.setInvisible(support.name, true)
    end

    setRouteAerial(groupName, support, {isFriendly = true, isHeli = isHeli, isAwacs = isAwacs})
  end)
end

function spawnPatrolByProto(protoName, zoneName, isHeli, initialIndex)
  local fnName = 'spawnPatrolByProto'
  
  general.patrols = chain(general.patrols)
    .filter(function (patrol) return patrol.zone ~= zoneName end)
    .value()
  
  indexing.patrolUnitToIndex = chain(indexing.patrolUnitToIndex).filter(
    function (d) return d.index ~= initialIndex end).value()
  
  local pos = generateWpAroundZone(zoneName)
  local spawnPos = mist.utils.makeVec3(pos[1])
  spawnPos.y = land.getHeight({x = spawnPos.x, y = spawnPos.z}) + Const.spawnHeightAerial
  local group = mist.teleportToPoint({groupName = protoName, point = spawnPos, action = 'clone'})
  rigid({ group }).stage(fnName, 'group nil', function (group)
    local groupName = group['name']
    local unitCnt = 0
    rigid({ Group.getByName(groupName) }).stage(fnName, 'group2 nil', function (group2)
      each(group2:getUnits(), function(unit)
        indexing.unitToGroup[unit:getName()] = groupName
        
        indexing.patrolUnitToIndex[#indexing.patrolUnitToIndex + 1] = {
          unitName = unit:getName(),
          index = initialIndex,
        }

        unitCnt = unitCnt + 1
      end)
    end)
    local wp = slice(pos, 1)
    local patrol = Util.addToList(general.patrols, Const.patrolInitial,
      {
        name = groupName,
        protoName = protoName,
        zone = zoneName,
        baseWp = wp,
        wp = wp,
        unitCnt = unitCnt,
        isHeli = isHeli,
        initialIndex = initialIndex,
      }
    )
    Util.setRoeByGroup(patrol.name, patrol.roeState, true, true)
    setRouteAerial(groupName, patrol, {isHeli = isHeli})
  end)
end

function spawnDefenderByProto(vzoneName, protoName, groupIndex, lunchProtoName)

  local fnName = 'spawnDefenderByProto'

  local v3SpawnPos = rigid({
      Util.getVzoneByName(vzoneName)
  }).stage(fnName, 'vzone null', function (vzone)
             local pos = vzone.pos
             local radius = vzone.radius
             local isPosOk = false
             local v2SpawnPos = Util.checkAndGen(
               function ()
                 return mist.getRandPointInCircle(pos, radius)
               end,
               function (pos)
                 return Util.checkTerrainValid2(pos)
               end,
               Const.maxTrial)
             
             return Util.makeVec3GL(v2SpawnPos)
          end).value()

  local spawnName = rigid({
      mist.teleportToPoint({groupName = protoName, point = v3SpawnPos, action = 'clone'})
      -- ground units can teleport only to ground, road type
  }).stage(fnName, 'spawnObj null', function (spawnObj)
             return let({spawnObj['name']}, function (name)
                 trigger.action.groupStopMoving(Group.getByName(name))
                 if TestFeature.defenderHold == true then
                   Util.setGroundRoeByGroup(name, 'hold')
                 end
                 each(Group.getByName(name):getUnits(),
                      function(unit)
                        indexing.unitToGroup[unit:getName()] = name
                      end
                 )
                 return name
             end).value()
    end).value()
  
  local defender = deepcopy(Const.defenderInitial)
  defender.name = spawnName
  defender.groupIndex = groupIndex
  defender.zoneName = vzoneName
  general.defenders[#general.defenders + 1] = defender
  
  if postConfig.useLunchBox ~= true then
    return
  end

  -- Lunch generate
  local v2SpawnPosSub = Util.checkAndGen(
    function ()
      return mist.getRandPointInCircle(Group.getByName(spawnName):getUnit(1):getPosition().p, Const.spawnRadiusSub, Const.spawnRadiusSubInner)
    end,
    function (pos)
      return Util.checkTerrainValid2(pos)
    end,
    Const.maxTrial)

  local spawnPosSub = Util.makeVec3GL(v2SpawnPosSub)
  
  local spawnNameSub = mist.teleportToPoint({groupName = lunchProtoName, point = spawnPosSub, action = 'clone'})['name']
  trigger.action.groupStopMoving(Group.getByName(spawnNameSub))

  each(Group.getByName(spawnNameSub):getUnits(),
       function(unit)
         indexing.unitToGroup[unit:getName()] = spawnNameSub
       end
  )
  
  indexing.lunchToDefender[spawnNameSub] = spawnName
  
  local lunch = deepcopy(Const.lunchInitial)
  lunch.name = spawnNameSub
  general.lunches[#general.lunches + 1] = lunch

end


function moveAerialGroupByName(groupName, wp, opt)
  local fnName = 'moveAerialGroupByName'
  local isFriendly = opt.isFriendly
  local isHeli = opt.isHeli
  local isAwacs = opt.isAwacs
  
  local groundZoneName = Const.zoneGroundD
  if isFriendly == true then
    groundZoneName = Const.zoneGroundA
  end
  
  rigid({ Group.getByName(groupName) }).stage(fnName, 'group nil', function (group)

    local altitude = Const.wpAltitude
    local speed = Const.wpSpeed
    if isAwacs == true then
      altitude = Const.wpAltitudeAwacs
      speed = Const.wpSpeedAwacs
    end
    
    local zone = trigger.misc.getZone(groundZoneName)
    local zonePos = Util.getZonePosition(zone)
    
    local path = {}
    local wpType = myConfig.const.aerialWpType
    if isHeli == true then
      path[#path + 1] = mist.heli.buildWP(wp[1], wpType)
      path[#path + 1] = mist.heli.buildWP(wp[2], wpType)
      path[#path + 1] = mist.heli.buildWP(zonePos, wpType)
    else
      path[#path + 1] = mist.fixedWing.buildWP(wp[1], wpType, speed, altitude)
      path[#path + 1] = mist.fixedWing.buildWP(wp[2], wpType, speed, altitude)
      path[#path + 1] = mist.fixedWing.buildWP(zonePos, wpType, speed, altitude)
    end
    if TestFeature.aerialDestSmoke then
      makeSmoke(mist.utils.makeVec3GL(wp[1]), trigger.smokeColor.Blue)
    end

    mist.goRoute(groupName, path)
    if isAwacs == true then
      Util.setAwacs(groupName)
    end
  end)
end

function moveGroundGroupByName(groupName, position)
  local fnName = 'moveGroundGroupByName'

  rigid({ Group.getByName(groupName) }).stage(fnName, 'group nil', function (group)
    local curPos = group:getUnit(1):getPosition().p
    
    local path = {}
    path[#path + 1] = mist.ground.buildWP(position, 'Diamond', 5)
    path[#path + 1] = mist.ground.buildWP(position, 'Diamond', 5)
    if TestFeature.groundDestSmoke then
      makeSmoke(position, trigger.smokeColor.Orange)
    end

    mist.goRoute(groupName, path)
  end)
end

function moveAttackersByAxis(axisIndex, position)
  Util.updateAxisState(axisIndex, { state = 'moving' })
  chain(general.attackers)
    .filter(function (attacker)
        return attacker.axisIndex == axisIndex and attacker.isAlive
    end)
    .each(function (attacker)
        moveGroundGroupByName(attacker.name, position)
    end)
end

function moveAttackers(axisIndex, noRebuild)
  local fnName = 'moveAttackers'

  rigid({general.axises[axisIndex]})
    .stage(fnName, 'axis null', function (axis)
             return rigid({axis.vzones, axis.curStep})
               .stage(fnName, 'axis info null', function (vzones, curStep)
                        return vzones[curStep]
                     end).value()
          end)
    .stage(fnName, 'vzoneName null', function (vzoneName)
             return Util.getVzoneByName(vzoneName)
          end)
    .stage(fnName, 'vzone null', function (vzone)
             return vzone.pos
          end)
    .stage(fnName, 'pos null', function (pos)
             moveAttackersByAxis(axisIndex, pos)
          end)
  
end

function stopAttackers(axisIndex, checkState, noRebuild)
  if Util.isAttackerLeft(axisIndex) ~= true then
    return
  end
  
  local axis = general.axises[axisIndex]
  if not Util.isStoppableState(axis.state) then
    evtBroadcast('STOP CANCEL')

    if checkState ~= true then
      if axis.state == 'paused' then
        Util.notifyAX('msg_paused_already', axisIndex)
      elseif axis.state == 'occupying' then
        Util.notifyAX('msg_occupying', axisIndex)
      elseif axis.state == 'garrison' then
        Util.notifyAX('msg_garrison', axisIndex)
      elseif axis.state == 'finished' then
        Util.notifyAX('msg_axis_finished_state', axisIndex)
      end
    end
    return
  end

  local displayBc = true
  if checkState == true and axis.state ~= 'moving' then
    displayBc = false
  end

  if displayBc == true then
    Util.notifyAX('msg_stopped_move', axisIndex)
  end
  
  Util.updateAxisState(axisIndex, { state = 'paused' })
  local attackers = filter(general.attackers,
                           function (attacker)
                             return attacker.axisIndex == axisIndex and attacker.isAlive
  end)
  each(attackers,
       function (attacker)
         trigger.action.groupStopMoving(Group.getByName(attacker.name))
  end)
end            

function resumeAttackers(axisIndex, noRebuild)
  if Util.isAttackerLeft(axisIndex) ~= true then
    return
  end
  
  local axis = general.axises[axisIndex]
  if not Util.isResumableState(axis.state) then
    if axis.state == 'moving' then
      Util.notifyAX('msg_moving_already', axisIndex)
    elseif axis.state == 'occupying' then
      Util.notifyAX('msg_occupying', axisIndex)
    elseif axis.state == 'garrison' then
      Util.notifyAX('msg_garrison', axisIndex)
    elseif axis.state == 'finished' then
      Util.notifyAX('msg_axis_finished_state', axisIndex)
    end
    return
  end
  
  Util.notifyAX('msg_resumed_move', axisIndex)
  Util.updateAxisState(axisIndex, { state = 'moving' })
  local attackers = filter(general.attackers,
                           function (attacker)
                             return attacker.axisIndex == axisIndex and attacker.isAlive
  end)
  each(attackers,
       function (attacker)
         trigger.action.groupContinueMoving(Group.getByName(attacker.name))
  end)

end            

function checkLunchDestroyed(groupName, unitName)

  if postConfig.useLunchBox ~= true then
    return
  end
  
  local allLunchNames = Util.getLunchNames()

  if contains(allLunchNames, groupName) then
    defenderGroupName = indexing.lunchToDefender[groupName]

    indexing.unitToGroup[unitName] = nil
    
    chain(general.defenders)
      .filter(function (defender) return defender.name == defenderGroupName and defender.isAlive end)
      .doFirst(function (defender)
          defenderGroup = Group.getByName(defenderGroupName)
          if Util.confirm(defenderGroup ~= nil, 'defenderGroup', 'defenderGroup nil', 'onevent') then

            each(defenderGroup:getUnits(), function (unit)
                   trigger.action.explosion(unit:getPosition().p, 200)

            end)
          end

      end)
            
  end

end

function checkRoeArea_client(listRoeArea)
  local fnName = 'checkRoeArea_client'

  chain(general.patrols)
    .filter(function (ele)
        return ele.patrolState == 'on' or ele.patrolState == 'ready'
    end)
    .each(function (ele)
        local axisIndex = ele.dispatchAxis
        rigid({
            Util.getCurVzoneForAxis(axisIndex),
            Util.getCurAlertRadiusForAxis(axisIndex),
        }).stage(fnName, 'vzone info null', function (zoneInfo, alertRadius)
                   rigid({
                       zoneInfo[2],
                       zoneInfo[1].radius,
                   }).stage(fnName, 'vzone info null 2', function (zonePos, zoneRadius)
                              local alertRadiusSlow = alertRadius * myConfig.const.alertRadiusRatioMax
                              local alertRadiusHeli = alertRadius * myConfig.const.alertRadiusRatioMin

                              chain(myConfig.clients)
                                .filter(function (client)
                                    return Util.isGroupClientSlow(client.groupName) and not Util.isGroupClientHeli(client.groupName) 
                                       end)
                                .map(function (clientInfo)
                                    return clientInfo.groupName
                                end)
                                .each(function (client, i)
                                    let({
                                        Util.getGroupPos(client)
                                        },
                                      function (groupPos)
                                        branch({}, groupPos ~= nil, function ()

                                            if mist.utils.get3DDist(zonePos, groupPos) <= alertRadiusSlow then
                                              listRoeArea[ele.name] = true
                                            end
                                        end)
                                      end
                                    )
                                    
                                end)

                              chain(myConfig.clients)
                                .filter(function (client)
                                    return Util.isGroupClientHeli(client.groupName)
                                       end)
                                .map(function (clientInfo)
                                    return clientInfo.groupName
                                end)
                                .each(function (client, i)
                                    let({
                                        Util.getGroupPos(client)
                                        },
                                      function (groupPos)
                                        branch({}, groupPos ~= nil, function ()
                                            
                                            if mist.utils.get3DDist(zonePos, groupPos) <= alertRadiusHeli then
                                              listRoeArea[ele.name] = true
                                            end
                                        end)
                                      end
                                    )
                                    
                                end)
                              
                   end)
          end)
    end)
end

function checkRoeEmer_client(newRoeEmer)
  local fnName = 'checkRoeEmer_client'
  chain(myConfig.clients)
    .filter(function (client)
        return not Util.isGroupClientSlow(client.groupName)
    end)
    .map(function (clientInfo)
        return clientInfo.groupName
    end)
    .each(function (client, i)

        let({
            Util.getGroupPos(client)
            },
          function (groupPos)
            branch({}, groupPos ~= nil, function ()
                   local volS = {
                     id = world.VolumeType.SPHERE,
                     params = {
                       point = groupPos,
                       radius = mist.utils.NMToMeters(Const.distRoeEmer),
                     }
                   }
                   local founds = {}
                   local cbFound = function (item)
                     local unitName = item:getName()
                     local groupName = indexing.unitToGroup[unitName]
                     founds[#founds + 1] = groupName
                   end
                   world.searchObjects(Object.Category.UNIT, volS, cbFound)
                   let({
                       filter(founds, function (d)
                                return Util.isGroupPatrol(d)
                       end)
                   }, function (filtered)
                       chain(filtered).each(function (groupName)
                           newRoeEmer[groupName] = true
                       end)
                   end)
                
            end)
          end
        )
          
    end)

end

function checkRoeEmer_support(patrol, newRoeEmer)
  -- check if support exists 
  local fnName = 'checkRoeEmer_support'

  rigid({
      Util.getGroupPos(patrol.name)
  }).stage(fnName, 'grouppos null', function (groupPos)
             
    local volS = {
      id = world.VolumeType.SPHERE,
      params = {
        point = groupPos,
        radius = mist.utils.NMToMeters(Const.distRoeEmer),
      }
    }
    
    local founds = {}
    local cbFound = function (item)
      local unitName = item:getName()
      local groupName = indexing.unitToGroup[unitName]
      founds[#founds + 1] = groupName
    end
    
    world.searchObjects(Object.Category.UNIT, volS, cbFound)
    
    local filtered = filter(founds, function (d)
                              return Util.isGroupSupportNonAwacs(d) --or Util.isGroupClient(d)
    end)
    
    rigid({
        Group.getByName(patrol.name)
    }).stage(fnName, 'group null', function (group)
               if #filtered > 0 then
                 newRoeEmer[patrol.name] = true
               end
    end)
             
  end)

end


function checkRoeEmer_patrol(patrol, newRoeEmer)
  -- check if patrol exists 
  local fnName = 'checkRoeEmer_patrol'

  rigid({
      Util.getGroupPos(patrol.name)
  }).stage(fnName, 'grouppos null', function (groupPos)
             
    local volS = {
      id = world.VolumeType.SPHERE,
      params = {
        point = groupPos,
        radius = mist.utils.NMToMeters(Const.distRoeEmer),
      }
    }
    
    local founds = {}
    local cbFound = function (item)
      local unitName = item:getName()
      local groupName = indexing.unitToGroup[unitName]
      founds[#founds + 1] = groupName
    end
    
    world.searchObjects(Object.Category.UNIT, volS, cbFound)
    
    local filtered = filter(founds, function (d)
                              return Util.isGroupPatrol(d) --or Util.isGroupClient(d)
    end)
    
    rigid({
        Group.getByName(patrol.name)
    }).stage(fnName, 'group null', function (group)
               if #filtered > 0 then
                 newRoeEmer[patrol.name] = true
               end
    end)
             
  end)

end


function processRoeArea_patrol(listRoeArea)
  local fnName = 'processRoeArea_patrol'
  
  chain(general.patrols).each(function (patrol, i)
      if listRoeArea[patrol.name] == true then
        if patrol.roeArea ~= true then
          patrol.roeArea = true
          evtBroadcast('ROE-AREA ON ' .. patrol.initialIndex)
          Util.evtBroadcastT('ROE-AREA ON ' .. patrol.initialIndex)
          Util.setRoeFromRoeArea(patrol)
        end
      else
        if patrol.roeArea == true then
          patrol.roeArea = false
          evtBroadcast('ROE-AREA OFF ' .. patrol.initialIndex)
          Util.evtBroadcastT('ROE-AREA OFF ' .. patrol.initialIndex)
          Util.setRoeFromRoeArea(patrol)
        end
      end
  end)

end


function processRoeEmer_patrol(newRoeEmer)
  local fnName = 'processRoeEmer_patrol'
  chain(general.patrols).each(function (patrol, i)
      if newRoeEmer[patrol.name] == true then
        if patrol.roeEmer ~= true then
          patrol.roeEmer = true
          evtBroadcast('ROE-EMER ON ' .. patrol.initialIndex)
          Util.evtBroadcastT('ROE-EMER ON ' .. patrol.initialIndex)
          Util.setRoeFromRoeEmer(patrol)
        end
      else
        if patrol.roeEmer == true then
          patrol.roeEmer = false
          evtBroadcast('ROE-EMER OFF ' .. patrol.initialIndex)
          Util.evtBroadcastT('ROE-EMER OFF ' .. patrol.initialIndex)
          Util.setRoeFromRoeEmer(patrol)
        end
      end
  end)
end




function processRoeEmer_support(newRoeEmer)
  local fnName = 'processRoeEmer_support'
  chain(general.supports).each(function (patrol, i)
      if newRoeEmer[patrol.name] == true then
        if patrol.roeEmer ~= true then
          patrol.roeEmer = true
          evtBroadcast('ROEEMER(S) ON ' .. patrol.initialIndex)
          Util.setRoeFromRoeEmer(patrol)

          Util.notifySP('msg_support_start_engage', patrol.initialIndex)
        end
      else
        if patrol.roeEmer == true then
          patrol.roeEmer = false
          evtBroadcast('ROEEMER(S) OFF ' .. patrol.initialIndex)
          Util.setRoeFromRoeEmer(patrol)
        end
      end
  end)
end


function processPatrol()
  local respawnInfo = {}
  local newRoeEmer = {}
  local listRoeArea = {}
  
  chain(general.patrols)
    .each(function (patrol, i)
        if patrol.patrolState == 'on' and patrol.dispatchCnt > 0 and patrol.spawnCnt <= 0 and patrol.isAlive == true then
          patrol.dispatchCnt = patrol.dispatchCnt - Const.minPPS
          if patrol.dispatchCnt <= 0 then
            returnFromDispatch(patrol.initialIndex)
          end
        end
        if patrol.spawnCnt > 0 then
          patrol.spawnCnt = patrol.spawnCnt - Const.minPPS
          if patrol.spawnCnt <= 0 then
            respawnInfo[#respawnInfo+1] = { patrol.protoName, patrol.zone, patrol.isHeli, patrol.initialIndex }
          end
        else
          if (TestFeature.disableRoeEmerPatrol ~= true) then
            checkRoeEmer_support(patrol, newRoeEmer)
          end
        end
    end)
  
  if (TestFeature.disableRoeEmerPatrol ~= true) then
    checkRoeEmer_client(newRoeEmer) 
  end
  if (TestFeature.disableRoeArea ~= true) then
    checkRoeArea_client(listRoeArea) 
  end
  
  
  processRoeEmer_patrol(newRoeEmer)
  processRoeArea_patrol(listRoeArea)

  chain(respawnInfo)
    .each(function (info)
        evtBroadcast('RESPAWN_PAT ' .. info[1])
        spawnPatrolByProto(info[1], info[2], info[3], info[4])
    end)

end

function processSupport()
  local respawnInfo = {}
  local newRoeEmer = {}

  chain(general.supports)
    .each(function (patrol, i)
        if patrol.patrolState == 'on' and patrol.dispatchCnt > 0 and patrol.spawnCnt <= 0 and patrol.isAlive == true then
          patrol.dispatchCnt = patrol.dispatchCnt - Const.minPPS
          if patrol.dispatchCnt <= 0 then
            returnFromDispatch(patrol.initialIndex, true)
          end
        end
        if patrol.spawnCnt > 0 then
          patrol.spawnCnt = patrol.spawnCnt - Const.minPPS
          if patrol.spawnCnt <= 0 then
            respawnInfo[#respawnInfo+1] = { patrol.protoName, patrol.zone, patrol.isAwacs, patrol.displayName, patrol.isHeli, patrol.spawnLeft, patrol.initialIndex, patrol.isCas }
          end
        else
          checkRoeEmer_patrol(patrol, newRoeEmer)
        end
    end)
  
  chain(respawnInfo)
    .each(function (info)
        evtBroadcast('RESPAWN_SUP ' .. info[1])
        if info[3] ~= true then -- if not awacs
          Util.broadcastBy(Msg.getText('msg_squadron_ready'), Role.Support, info[7])
        end
        
        spawnSupportByProto(info[1], info[2], info[3], info[4], info[5], info[6], info[7], info[8])
    end)

  processRoeEmer_support(newRoeEmer)

end

function checkAttackerDestroyed(groupName, unitName)
  if general.postInitialized ~= true then
    return
  end
  
  local allAttackerNames = Util.getAttackerNames()
  if contains(allAttackerNames, groupName) then
    indexing.unitToGroup[unitName] = nil
    
    chain(general.attackers)
      .filter(function (attacker) return attacker.name == groupName and attacker.isAlive == true end)
      .doFirst(function (attacker)
          attacker.isAlive = false
          if Util.isAttackerLeft(attacker.axisIndex) then
            Util.notifyAX('msg_under_attack', attacker.axisIndex)
          else
            local text = Util.getAxisName(attacker.axisIndex) .. Msg.getText('msg_attacker_eliminated')
            Util.notifyOP('msg_attacker_eliminated', { altText = text })

            Util.updateAxisState(attacker.axisIndex, { failed = true })
            general.finishedAxis[attacker.axisIndex] = false
          end
          stopAttackers(attacker.axisIndex, true)
      end)

    if chain(general.axises).filter(function (axis, i) return axis.failed == false end).size() < postConfig.axisCntSuccess and general.isFailed == false then
      -- all_fail
      Util.notifyOP('msg_failure_msg')
      general.isFailed = true
    end
    
  end
end


function checkSupportDestroyed(groupName, unitName, isLanding)
  local fnName = 'checkSupportDestroyed'
  local allSupportNames = Util.getSupportNames()
  if contains(allSupportNames, groupName) then
    evtBroadcast('DESTROYED_SUP ' .. groupName)
    
    indexing.unitToGroup[unitName] = nil

    local bHappened = false
    local isAwacs = false
    chain(general.supports)
      .filter(function (support) return support.name == groupName and support.isAlive == true end)
      .doFirst(function (support)
          isAwacs = support.isAwacs
          
          if support.unitCnt > 0 then
            support.unitCnt = support.unitCnt - 1
            if support.unitCnt <= 0 then

              if support.spawnLeft == -99 or support.isAwacs == true or support.spawnLeft > 0 then
                if support.spawnCnt <= 0 then
                  if support.spawnLeft ~= -99 and support.isAwacs ~= true then
                    support.spawnLeft = support.spawnLeft - 1
                  end
                  if support.isAwacs == true then
                    support.spawnCnt = myConfig.const.periodSupportSpawnAwacs
                  else
                    support.spawnCnt = myConfig.const.periodSupportSpawn
                  end
                end
                
              else
                support.isAlive = false
              end
              bHappened = true
              if support.isAwacs ~= true then
                Util.broadcastBy(support.displayName .. Msg.getText('msg_squadron_lost'), Role.Operator)
              end
            else
              Util.notifySP('msg_squadron_member_lost', support.initialIndex)
            end
          end
      end)

    if isAwacs ~= true then
      rigid({ Unit.getByName(unitName) }).stage(fnName, 'unit null', function (unit)
                                                  unit:destroy()
      end)
    end
    
    
  end
end

function checkPatrolDestroyed(groupName, unitName)
  local fnName = 'checkPatrolDestroyed'
  local allPatrolNames = Util.getPatrolNames()
  if contains(allPatrolNames, groupName) then
    evtBroadcast('DESTROYED_PAT ' .. groupName)

    indexing.unitToGroup[unitName] = nil
    rigid({ Unit.getByName(unitName) }).stage(fnName, 'unit null', function (unit)
                                                unit:destroy()
    end)
    
    chain(general.patrols)
      .filter(function (patrol) return patrol.name == groupName end)
      .doFirst(function (patrol)
          if patrol.unitCnt > 0 then
            patrol.unitCnt = patrol.unitCnt - 1
            if patrol.unitCnt <= 0 and patrol.spawnCnt <= 0 then
              patrol.spawnCnt = myConfig.const.periodPatrolSpawn
            end
          end
      end)
  end
end

function checkDefenderDestroyed(groupName)

  local allDefenderNames = Util.getDefenderNames()

  if contains(allDefenderNames, groupName) then
    evtBroadcast('DESTROYED_DEF ' .. groupName)
    chain(general.defenders)
      .filter(function (defender) return defender.name == groupName and defender.isAlive == true end)
      .doFirst(function (defender)
          chain(general.vzones)
            .filter(function (vzone) return vzone.name == defender.zoneName end)
            .doFirst(function (vzone)
                defender.isAlive = false
                vzone.defenderLeft = vzone.defenderLeft - 1
                general.totalDestroyed = general.totalDestroyed + 1

                if TestFeature.successCheckOnDestroyed == true then
                  if Util.checkFinished(postConfig.axisCntSuccess) then
                    general.successCnt = Const.successCntMax
                  end
                end

                chain(general.axises).filter(function (axis, i) return i == vzone.axisIndex end)
                  .doFirst(function (axis)
                      if axis.alertCoolCnt <= 0 then
                        axis.alertCoolCnt = myConfig.const.alertCoolMax
                        evtBroadcast('ROLL_DISPATCH')
                        
                        if doRoll({axis.rollAlert, myConfig.const.rollAlertMultitude}, 'roll-alert') then
                          let({ Util.getNextPatrolIndex() },
                            function (patrolIndex)
                              if patrolIndex ~= -1 then
                                dispatchByAxis(patrolIndex, vzone.axisIndex)
                                Util.evtBroadcastT('patrol-dispatch ' .. patrolIndex .. ' ' .. vzone.axisIndex)
                              else
                                evtBroadcast('ALL_BUSY')
                              end
                          end)
                        end
                      else
                        evtBroadcast('COOL_TIME')
                      end
                  end)
            end)
      end)
  end
end

local function notifyPatrolDestroyed(initiatorUnitName)
  local fnName = 'notifyPatrolDestroyed'

  rigid({
    indexing.unitToGroup[initiatorUnitName],
    Util.getSupportNames(),
    Util.getAttackerNames(),
  }).stage(fnName, 'groupName not found', function (groupName, allSupportNames, allAttackerNames)
             
             if contains(allSupportNames, groupName) then
               chain(general.supports)
                 .filter(function (support) return support.name == groupName and support.isAlive == true end)
                 .doFirst(function (support)
                     Util.notifySP('msg_splashed_patrol', support.initialIndex)
                 end)
             end
             if contains(allAttackerNames, groupName) then
               chain(general.attackers)
                 .filter(function (attacker) return attacker.name == groupName and attacker.isAlive == true end)
                 .doFirst(function (attacker)
                     Util.notifyAX('msg_splashed_patrol', attacker.axisIndex)
                 end)
             end
  end)
  
end

function eHandler:onEvent(e)
  local fnName = 'onEvent'

  if e.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
    if TestFeature.msgEvent then
      Util.broadcast('S_EVENT_PLAYER_ENTER_UNIT')
    end
    rigid({
        e.initiator
    }).stage(fnName, 'S_EVENT_PLAYER_ENTER_UNIT initiator null', function (initiator)
               rigid({
                   initiator:getGroup()
               }).stage(fnName, 'S_EVENT_PLAYER_ENTER_UNIT group null', function (group)
                          local groupName = group:getName()
                          buildMenuMain()
               end)
    end)
  end
  if e.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
    if TestFeature.msgEvent then
      Util.broadcast('S_EVENT_PLAYER_LEAVE_UNIT')
    end
    rigid({
        e.initiator
    }).stage(fnName, 'S_EVENT_PLAYER_LEAVE_UNIT initiator null', function (initiator)
               rigid({
                   initiator:getGroup()
               }).stage(fnName, 'S_EVENT_PLAYER_LEAVE_UNIT group null', function (group)
                          local groupName = group:getName()
                          general.vote = chain(general.vote).filter(function (d) return d.groupName ~= groupName end).value()
                          myDebug('general.vote', general.vote)
                          buildMenuMain()
               end)
    end)
  end
  
  if e.id == world.event.S_EVENT_LAND then
    if TestFeature.msgEvent then
      Util.broadcast('S_EVENT_LAND')
    end
    local unitName, groupName
    rigid({
        e.initiator
    }).stage(fnName, 'S_EVENT_LAND initiator null', function (initiator)
               unitName = initiator:getName()
               groupName = indexing.unitToGroup[unitName]
    end)

    if groupName ~= nil then
      if TestFeature.msgEvent then
        Util.broadcast('landed group ' .. groupName)
      end
    
      checkPatrolDestroyed(groupName, unitName)
      checkSupportDestroyed(groupName, unitName, true)
      
    end

  end
  if e.id == world.event.S_EVENT_UNIT_LOST then
    if TestFeature.msgEvent then
      Util.broadcast('S_EVENT_UNIT_LOST')
    end
    local unitName, groupName
    rigid({
        e.initiator
    }).stage(fnName, 'S_EVENT_UNIT_LOST initiator null', function (initiator)
               unitName = initiator:getName()
               groupName = indexing.unitToGroup[unitName]
    end)

    myDebug('S_EVENT_UNIT_LOST')
    checkPatrolDestroyed(groupName, unitName)
    checkSupportDestroyed(groupName, unitName)
    
  end
  if e.id == world.event.S_EVENT_BDA then
    if TestFeature.msgEvent then
      Util.broadcast('S_EVENT_BDA')
    end
    local unitName, groupName
    rigid({
        e.target
    }).stage(fnName, 'S_EVENT_BDA target null', function (target)
               unitName = target:getName()
               groupName = indexing.unitToGroup[unitName]
    end)

    myDebug('S_EVENT_BDA')
    checkAttackerDestroyed(groupName, unitName)
    checkLunchDestroyed(groupName, unitName)

  end
  if e.id == world.event.S_EVENT_KILL then
    if TestFeature.msgEvent then
      Util.broadcast('S_EVENT_KILL')
    end
    myDebug('S_EVENT_KILL', e)
    local unitName, groupName
    rigid({
        e.target
    }).stage(fnName, 'S_EVENT_KILL target null', function (target)
               unitName = target:getName()
               groupName = indexing.unitToGroup[unitName]
    end)
    myDebug('S_EVENT_KILL', unitName)

    checkPatrolDestroyed(groupName, unitName)
    checkSupportDestroyed(groupName, unitName, false)

    local patrolUnitNames = chain(indexing.patrolUnitToIndex).map(function (d) return d.unitName end).value()
    if contains(patrolUnitNames, unitName) then
      local initiatorName
      rigid({
          e.initiator
      }).stage(fnName, 'initiator null', function (initiator)
                 initiatorName = initiator:getName()
      end)
      notifyPatrolDestroyed(initiatorName)
    end
    
  end
  if e.id == world.event.S_EVENT_DEAD then
    if TestFeature.msgEvent then
      Util.broadcast('S_EVENT_DEAD')
    end

    myDebug('S_EVENT_DEAD', e)
    
    local unitName, groupName
    rigid({
        e.initiator
    }).stage(fnName, 'S_EVENT_DEAD initiator null', function (initiator)
               unitName = initiator:getName()
               groupName = indexing.unitToGroup[unitName]
    end)
    
    checkAttackerDestroyed(groupName, unitName)
    checkLunchDestroyed(groupName, unitName)
    checkDefenderDestroyed(groupName)

  end
end

local function reportStatus()
  local fnName = 'reportStatus'
  
  local attackerLeft = Util.getAttackerLeft()
  
  local res = ''
  chain(general.axises).each(function (axis, axisIndex)
      rigid({
          Util.getCurVzoneForAxis(axisIndex)
      }).stage(fnName, 'curzone info null', function (curZone)
                 rigid({
                     curZone[1]
                 }).stage(fnName, 'vzone null', function (vzone)
                            res = res .. Util.getAxisName(axisIndex)
                            res = res .. ' [ ' .. axis.curStep
                            local strState, dispCnt
                            if TestFeature.useLeftCnt == true then
                              dispCnt = vzone.defenderLeft
                            else
                              dispCnt = vzone.defenderLeftMax - vzone.defenderLeft
                            end

                            if axis.failed == true then
                              strState = Msg.getText('msg_st_failed')
                            else
                              strState = Util.getStateStr(axis.state)
                            end
                            res = res .. ' / ' .. strState
                            res = res .. ' / ' .. attackerLeft[axisIndex] .. '-' .. dispCnt

                            if postConfig.useSmoke == true then
                              local strSmoked = vzone.isSmoked and 'O' or 'X'
                              res = res .. ' / ' .. strSmoked
                            end
                            
                            res = res .. ' ]'

                            if axisIndex ~= #general.axises then
                              res = res .. ', '
                            end
                 end)
      end)
      
  end)

  local header = Msg.getText('msg_reporting_status')
  Util.notifyOP('msg_reporting_status', { period = Const.broadcastLong })
  Util.broadcast(res, nil, Const.broadcastLong)
  
end


local function showCardPicked()
  if #general.cardPicked > 0 then
    local msg = Msg.getText('msg_show_card_header') .. ' ' .. chain(general.cardPicked)
      .reduce('', function (res, card, i)
                if i == #general.cardPicked then
                  return res .. Util.getCardName(card)
                else
                  return res .. Util.getCardName(card) .. ', '
                end
             end) 
    Util.broadcast(msg)
  end
  
end

local function setConfigFromDifficulty()
  if postConfig.curDifficulty == 'easy' then
    postConfig.useHardMode = false
    if (postConfig.axisCntSuccess <= Const.axisCntSuccessMax) then
      postConfig.axisCntSuccess = 1
    end
  elseif postConfig.curDifficulty == 'normal' then
    postConfig.useHardMode = false
    if (postConfig.axisCntSuccess <= Const.axisCntSuccessMax) then
      postConfig.axisCntSuccess = 2
    end
  elseif postConfig.curDifficulty == 'hard' then
    postConfig.useHardMode = true
    if (postConfig.axisCntSuccess <= Const.axisCntSuccessMax) then
      postConfig.axisCntSuccess = 2
    end
  end
  postConfig.axisCntSuccess = min(postConfig.axisCntSuccess, general.axisCnt)
end

local function onUserCommand(args)
  local fnName = 'onUserCommand'
  local cmdId = args.id
  local lc_args = args.args
  local text = ''

  if cmdId == 'CHANGE_OPT_EXTENDED' then
    postConfig.useStepLimit = not postConfig.useStepLimit
    text = Msg.getText('msg_option_changed')
    Util.broadcastDefS(text .. ' [ ' .. Util.getOptionTitle(cmdId, ' -> ') .. ' ]')
    buildMenuInit()
    
  elseif cmdId == 'CHANGE_OPT_LUNCHBOX' then
    postConfig.useLunchBox = not postConfig.useLunchBox
    text = Msg.getText('msg_option_changed')
    Util.broadcastDefS(text .. ' [ ' .. Util.getOptionTitle(cmdId, ' -> ') .. ' ]')
    buildMenuInit()
    
  elseif cmdId == 'CHANGE_OPT_SMOKE' then
    postConfig.useSmoke = not postConfig.useSmoke
    text = Msg.getText('msg_option_changed')
    Util.broadcastDefS(text .. ' [ ' .. Util.getOptionTitle(cmdId, ' -> ') .. ' ]')
    buildMenuInit()
    
  elseif cmdId == 'CHANGE_OPT_DIFFICULTY' then
    if postConfig.curDifficulty == 'normal' then
      postConfig.curDifficulty = 'easy'
    elseif postConfig.curDifficulty == 'easy' then
      postConfig.curDifficulty = 'hard'
    elseif postConfig.curDifficulty == 'hard' then
      postConfig.curDifficulty = 'normal'
    end
    text = Msg.getText('msg_option_changed')
    Util.broadcastDefS(text .. ' [ ' .. Util.getOptionTitle(cmdId, ' -> ') .. ' ]')
    buildMenuInit()
    
  elseif cmdId == 'CHANGE_OPT_LANG' then
    postConfig.langCd = lc_args
    Msg.setLangCd(postConfig.langCd)
    buildMenuInit()
    text = Msg.getText('msg_option_changed')
    Util.broadcastDefS(text .. ' [ ' .. Util.getOptionTitle(cmdId, ' -> ') .. ' ]')
    
  elseif cmdId == 'RESTART_OPERATION' then
    if lc_args.value == true then
      if (not chain(general.vote).filter(function (d) return d.groupName == lc_args.groupName end).isEmpty()) then
        return
      end
      
      general.vote = chain(general.vote).filter(function (d) return d.groupName ~= lc_args.groupName end).value()
      general.vote[#general.vote + 1] = {
        groupName = lc_args.groupName,
        value = true
      }
      myDebug('general.vote', general.vote)
      local clientIds = Util.getClientIds()
      local trueVotes = Util.getTrueVotes()
      myDebug('trueVotes', trueVotes)

      local msg = Msg.getText('msg_restart_requested') .. Util.curTotalStr(#trueVotes, #clientIds)
      Util.broadcast(msg) 
      Msg.notifyC('msg_restart_requested', { audioOnly = true })
      if #trueVotes >= #clientIds then
        general.restartCnt = myConfig.const.periodRestart
        local msg = general.restartCnt .. Msg.getText('msg_restart_announce')
        Util.broadcast(msg) 
      else
      end
    end
    
  elseif cmdId == 'START_OPERATION' then
    if general.blockPostInit then return end
    postInit()

  elseif cmdId == 'REPORT_STATUS' then
    reportStatus()
    
  elseif cmdId == 'TEST_MENU' then
    Util.broadcast('Done')
  elseif cmdId == 'TEST_MENU2' then
    Util.broadcast('Done2')
  elseif cmdId == 'MOVE_ATTACKER' then
    if lc_args == 'total' then
      range(general.axisCnt)
        .each(function (axisIndex)
            resumeAttackers(axisIndex, axisIndex < general.axisCnt)
        end)
    else
      resumeAttackers(lc_args)
    end
  elseif cmdId == 'STOP_ATTACKER' then
    if lc_args == 'total' then
      range(general.axisCnt)
        .each(function (axisIndex)
            stopAttackers(axisIndex, false, axisIndex < general.axisCnt)
        end)
    else
      stopAttackers(lc_args)
    end
  elseif cmdId == 'REQUEST_SUPPORT' then
    if not Util.isSupportAlive(lc_args.eleIndex) then
      Util.notifyOP('msg_support_unable_finally')
      return
    elseif Util.isSupportRestoring(lc_args.eleIndex) then
      Util.notifyOP('msg_support_unable_current')
      return
    elseif not Util.isSupportAvailable(lc_args.eleIndex) then
      Util.notifySP('msg_support_ondispatch', lc_args.eleIndex)
      return
    end
    
    dispatchByAxis(lc_args.eleIndex, lc_args.axisIndex, true)
  end
  
end

function test()
  myDebug('--- test start')
  local fnName = 'test'

  --testend
  myDebug('--- test end')
end

function setForFinish(axisIndex, noLeft)
  myDebug('finished: ' .. Util.getFinished() .. ', cntSuccess: ' .. postConfig.axisCntSuccess)
  if noLeft == true then
    Util.notifyAX('msg_axis_finished_no_left', axisIndex)
  else
    Util.notifyAX('msg_axis_finished', axisIndex)
  end

  local axisLeft = postConfig.axisCntSuccess - Util.getFinished()
  if axisLeft > 0 then
    local header = Msg.getText('msg_success_condition_header')
    local footer = Msg.getText('msg_success_condition')
    Util.broadcastBy(header .. axisLeft .. footer, Role.Operator)
  end
  
end

function showStatistics()
  local header1 = Msg.getText('msg_total_destroyed')
  local header2 = Msg.getText('msg_total_occupied')
  local msg = header1 .. ' - ' .. general.totalDestroyed .. ', ' .. header2 .. ' - ' .. general.totalOccupied
  Util.broadcast(msg)
end

function setForSuccess()
  if Util.getFinished() == general.axisCnt and general.axisCnt ~= postConfig.axisCntSuccess then
    if general.isSuccessComplete then
      return
    end

    general.isSuccessComplete = true
    Util.notifyOP('msg_success_msg_complete')
    showStatistics()
    showCardPicked()
  else
    if not Util.checkFinished(postConfig.axisCntSuccess) then
      evtBroadcast('SUCCESS CANCEL')
      return
    end
    
    if general.isSuccess then
      evtBroadcast('SUCCESS ALREADY')
      return
    end

    general.isSuccess = true
    trigger.action.setUserFlag('FLAG_WIN', true)
    
    Util.notifyOP('msg_success_msg')
    showStatistics()
    showCardPicked()
  end
end

function updateReveal()
  if postConfig.useSmoke ~= true then
    return
  end
  
  chain(general.defenders)
    .filter(function (defender) return defender.revealedPos ~= nil and defender.isAlive end)
    .doSize(function (size)
    end)
    .each(function (defender, i)
        makeSmoke(defender.revealedPos, myConfig.const.colorAttackerSearch)

    end)
end

function revealDefender(groupName, axisIndex, noNotify)
  local fnName = 'revealDefender'
  
  if not chain(general.defenders)
    .some(function (defender) return defender.name == groupName and defender.revealedPos == nil and defender.isAlive end) then
    evtBroadcast('REVEAL CANCEL')
  end
  
  return chain(general.defenders)
    .filter(function (defender) return defender.name == groupName and defender.revealedPos == nil and defender.isAlive end)
    .doFirst(function (defender)
        local pos = Util.getGroupPos(groupName)

        local smokePos = mist.getRandPointInCircle(pos, myConfig.const.smokeAccuracy)
        smokePos = Util.makeVec3GL(smokePos)
        defender.revealedPos = smokePos
        if postConfig.useSmoke == true then
          makeSmoke(smokePos, myConfig.const.colorAttackerSearch)
        end

        if noNotify ~= true then
            Util.notifyAX('msg_found_enemy', axisIndex)
        end

        rigid({
            Util.getCurVzoneForAxis(axisIndex)
        }).stage(fnName, 'curzone info null', function (curZone)
                   rigid({
                       curZone[1]
                   }).stage(fnName, 'vzone null', function (vzone)
                              vzone.isSmoked = true
                   end)
        end)

        return true
    end) or false
end

function revealAllDefenders(axis, axisIndex)
  local fnName = 'revealAllDefenders'
  
  evtBroadcast('REVEAL_ALL ' .. axisIndex)
  rigid({Util.getCurVzoneForAxis(axisIndex)})
    .stage(fnName, 'vzone info null', function (curZone)
             local zoneName = curZone[3]
             chain(general.defenders)
               .filter(function (defender) return defender.zoneName == zoneName and defender.revealedPos == nil and defender.isAlive end)
               .each(function (defender, i)
                   local pos = Util.getGroupPos(defender.name)

                   defender.revealedPos = pos
                   if postConfig.useSmoke == true then
                     makeSmoke(pos, myConfig.const.colorAttackerSearch)
                   end
                   
               end)
    end)
  
end

function processAxis()
  local fnName = 'processAxis'
  if general.successCnt > 0 then
    general.successCnt = general.successCnt - Const.minPPS
    if general.successCnt <= 0 then
      setForSuccess()
    end
  end
  if general.restartCnt > 0 then
    general.restartCnt = general.restartCnt - Const.minPPS
    if general.restartCnt <= 0 then
      trigger.action.setUserFlag('FLAG_RESTART', true)
    end
  end
  
  each(general.axises,
       function (axis, axisIndex)
         if axis.alertCoolCnt > 0 then
           axis.alertCoolCnt = axis.alertCoolCnt - Const.minPPS
         end

         if Util.isAttackerLeft(axisIndex) ~= true then
           return
         end
         if axis.state == 'occupying' then
           if axis.timeToOccupyCnt > 0 then
             axis.timeToOccupyCnt = axis.timeToOccupyCnt - Const.minPPS
           else
             if Util.isAttackerLeft(axisIndex) == false then
               myDebug3(fnName, 'occupying - isAttackerLeft false')
             else
               evtBroadcast('OCCUPY_DONE ' .. axisIndex)
               axis.state = 'garrison'

               rigid({Util.getCurVzoneForAxis(axisIndex)})
                 .stage(fnName, 'vzone info null',
                        function (curZone)
                          rigid({
                              curZone[1],
                              curZone[3],
                          }).stage(fnName, 'vzone null', function (zone, zoneName)
               
                                     if zone.defenderLeft <= 0 then
                                       zone.noLeft = true

                                       Util.notifyAX('msg_axis_occupied_no_left', axisIndex)
                                       
                                     else
                                       if axis.curStep == axis.maxStep then
                                         if postConfig.useSmoke == true then
                                           Util.notifyAX('msg_axis_occupied_2', axisIndex)
                                         else
                                           Util.notifyAX('msg_axis_occupied_nosmoke_2', axisIndex)
                                         end
                                       else
                                         if postConfig.useSmoke == true then
                                           Util.notifyAX('msg_axis_occupied', axisIndex)
                                         else
                                           Util.notifyAX('msg_axis_occupied_nosmoke', axisIndex)
                                         end
                                       end

                                     end
                          end)
                        end)
               

               revealAllDefenders(axis, axisIndex)
             end
           end
         elseif axis.state == 'garrison' then
           rigid({Util.getCurVzoneForAxis(axisIndex)})
             .stage(fnName, 'vzone info null',
                    function (curZone)
                      rigid({
                          curZone[1],
                          curZone[3],
                      }).stage(fnName, 'vzone null', function (zone, zoneName)
                                 if Util.isAttackerLeft(axisIndex) == false then
                                   myDebug3(fnName, 'garrison - isAttackerLeft false')
                                 elseif zone.defenderLeft <= 0 then
                                   general.totalOccupied = general.totalOccupied + 1
                                   if axis.curStep == axis.maxStep then
                                     axis.finished = true
                                     axis.state = 'finished'
                                     general.finishedAxis[axisIndex] = true
                                     setForFinish(axisIndex, zone.noLeft)
                                     checkCardPick(axisIndex, axis.curStep)
                                     if Util.checkFinished(postConfig.axisCntSuccess) then
                                       general.successCnt = Const.successCntMax
                                     end
                                   else
                                     evtBroadcast('MOVE_NEXT ' .. axisIndex)
                                     checkCardPick(axisIndex, axis.curStep)
                                     axis.curStep = axis.curStep + 1
                                     axis.state = 'moving'
                                     moveAttackers(axisIndex)
                                     Util.notifyAX('msg_to_next', axisIndex)
                                     
                                   end
                                   
                                 end
                      end)

                   end)
           
         end
       end
  )

end


function checkCardPick(axisIndex, vzoneIndex)
  local fnName = 'checkCardPick'
  myDebug3(fnName, 'axis/zone', { axisIndex = axisIndex, vzoneIndex = vzoneIndex })
  
  if general.cardList ~= nil then
    chain(general.cardList).doFind(
      function (card)
        return card.axisIndex == axisIndex and card.vzoneIndex == vzoneIndex
      end,
      function (card)
        general.cardPicked[#general.cardPicked + 1] = {
          cardShape = card.cardShape,
          cardNum = card.cardNum
        }
        local cardName = Util.getCardName(card)
        local msg = Msg.getText('msg_card_picked_header') .. '\'' .. cardName .. '\'' .. Msg.getText('msg_card_picked_footer')
        Util.broadcastBy(msg, Role.Axis, axisIndex, { msgId = 'msg_card_picked_header'})

        if Util.isDeckComplete() then
          Util.notifyOP('msg_card_deck_complete')
          showCardPicked()
        end
        
      end)
  end
end


function checkSearch()

  each(general.axises, function (axis, axisIndex)
         axis.searchCnt = axis.searchCnt + Const.minPPS
         if axis.searchCnt >= myConfig.const.periodSearch then
           axis.searchCnt = 0

           chain(general.attackers)
             .filter(function (attacker)
                 return attacker.axisIndex == axisIndex and attacker.isAlive
             end)
             .doFirst(function (attacker)
                 local attackerPos = Util.getGroupPos(attacker.name)

                 local volS = {
                   id = world.VolumeType.SPHERE,
                   params = {
                     point = attackerPos,
                     radius = mist.utils.NMToMeters(Const.distAttackerSearch),
                   }
                 }

                 local founds = {}
                 local cbFound = function (item)
                   local unitName = item:getName()
                   local groupName = indexing.unitToGroup[unitName]
                   founds[#founds + 1] = groupName
                 end

                 world.searchObjects(Object.Category.UNIT, volS, cbFound)

                 local defenders = filter(founds, function (d)
                                            return Util.isGroupDefender(d)
                 end)
                 
                 if #defenders > 0 and doRoll(myConfig.const.rollAttackerSearch) then
                   doByRoll(defenders,
                            function (d)
                              if revealDefender(d, axisIndex) == true then
                                stopAttackers(axisIndex, true)
                              end
                            end)
                 end
             end)
         end
  end)
  
end

function checkArrivalPatrol(isFriendly, fnName)
  fnName = fnName or 'checkArrivalPatrol'

  local alist = general.patrols
  if isFriendly == true then
    alist = general.supports
  end

  each(alist, function (patrol, i)
         branch({}, patrol.isAlive == true and patrol.spawnCnt <= 0, function ()
             rigid({
                 { patrol, 'wp' },
                 { patrol, 'wpIndex' },
                 { patrol, 'wpIndex' },
             }).shift(fnName, 'patrol info not found', function (wp, wpIndex, oldWpIndex)
               rigid({
                   { wp, wpIndex }
               }).shift(fnName, 'wp out of bound', function (curWp)
                 rigid({ Group.getByName(patrol.name) }).stage(fnName, 'group nil', function (group)
                   rigid({ group:getUnits() }).stage(fnName, 'units nil', function (units)
                     let({
                         chain(units).map(function (unit) return unit:getPosition().p end).value()
                     }, function (positions)
                       if some(positions, function (curPos)
                         return mist.utils.NMToMeters(Const.distCheckArrivalPatrol_Support) >
                           mist.utils.get3DDist(
                             mist.utils.makeVec3GL(curWp),
                             mist.utils.makeVec3GL(curPos))
                       end) then
                         if TestFeature.debugRoute then
                           Util.broadcast('routing for next - ' .. patrol.protoName)
                         end
                         
                         if patrol.destAction ~= '' then
                           if TestFeature.debugRoute then
                             Util.broadcast('destAction ' .. patrol.destAction)
                           end
                           patrol.roeState = patrol.destAction
                           Util.setRoeFromRoe(patrol)
             
                           patrol.destAction = ''
                         end

                         if patrol.patrolState == 'ready' then
                           patrol.patrolState = 'on'
                           evtBroadcast('PATROL ON ' .. patrol.protoName)
                         end
                         
                         patrol.wpIndex = patrol.wpIndex + 1
                         if patrol.wpIndex > #patrol.wp then
                           patrol.wpIndex = 1
                         end
                         setRouteAerial(patrol.name, patrol, {isFriendly = isFriendly, isHeli=patrol.isHeli, isAwacs=patrol.isAwacs})
                       end
                       if some(positions, function (curPos)
                         return mist.utils.NMToMeters(Const.distReroute) <
                           mist.utils.get3DDist(
                             mist.utils.makeVec3GL(curWp),
                             mist.utils.makeVec3GL(curPos))
                       end) then
                         if patrol.rerouteCnt <= 0 then
                           patrol.rerouteCnt = Const.periodReroute
                           if TestFeature.debugReroute then
                             Util.broadcast('re-routing - ' .. patrol.protoName)
                           end
                           setRouteAerial(patrol.name, patrol, {isFriendly = isFriendly, isHeli=patrol.isHeli, isAwacs=patrol.isAwacs})
                         else
                           patrol.rerouteCnt = patrol.rerouteCnt - Const.minPPS
                         end
                       end
             
                     end)
                   end)
                 end)
               end)
             end)
         end)
  end)
      
end

function checkArrivalSupport()
  checkArrivalPatrol(true, 'checkArrivalSupport')
end


function checkArrivalAttacker()
  local fnName = 'checkArrivalAttacker'
  each(general.axises, function (axis, i)
         if axis.state == 'moving' then

           rigid({
               Util.getCurVzoneForAxis(i)
           }).stage(fnName, 'vzone info null', function (info)
                      local zone = info[1]
                      local zonePos = info[2]
                      local volS = {
                        id = world.VolumeType.SPHERE,
                        params = {
                          point = zonePos,
                          radius = Const.distCheckArrivalAttacker,
                        }
                      }
                      local isFound = false
                      
                      local cbFound = function (item)
                        local unitName = item:getName()
                        local groupName = indexing.unitToGroup[unitName]
                        local isAttacker = find(general.attackers,
                                                function (d)
                                                  return d.name == groupName
                        end) ~= nil
                        if isAttacker then
                          isFound = true
                        end
                      end

                      world.searchObjects(Object.Category.UNIT, volS, cbFound)

                      if isFound then
                          Util.updateAxisState(i, {
                                                 state = 'occupying',
                                                 timeToOccupyCnt = myConfig.const.timeToOccupy,
                          })
                          evtBroadcast('OCCUPY_START ' .. i)
                          
                          Util.notifyAX('msg_start_occupy', i)
                      end
                      
                   end)

           
         end
  end)
  
end


function log2Sec()
  local fName = 'log2Sec'
  local patrol = general.patrols[1]
  rigid({ patrol }).stage(fnName, 'patrol nil', function (patrol, i)
    local oldWpIndex = patrol.wpIndex
    local curWp = patrol.wp[patrol.wpIndex]

    rigid({ Group.getByName(patrol.name) }).stage(fnName, 'group nil', function (group)
      local unit = group:getUnit(1)
        local curPos = unit:getPosition().p
        Util.broadcast('distance: ' .. mist.utils.get3DDist(
          mist.utils.makeVec3GL(curWp),
          mist.utils.makeVec3GL(curPos) )
        )
    end)
  end)
  
end


function onTimer()
  each(timerInfos,
       function (info)
         if info.enabled == false then
           return
         end
         if info.preInit ~= true and general.postInitialized == false then
           return
         end
         
         if info.cnt ~= nil then
           info.cnt = info.cnt + 1
         else
           info.cnt = 0
         end
         local period = 0
         if hasKey(info, 'period') then
           period = info.period
         else
           period = info.periodFn()
         end
         if info.periodName ~= nil then
           period = myConfig.const[info.periodName]
         end
         if info.cnt >= period then
           info.cnt = 0
           info.fn(info.params)
         end
  end)
end


function drawZoneLabel(vzoneName, axisIndex, zoneIndex)
  local fnName = 'drawZoneLabel'
  
  rigid({
      Util.getVzoneByName(vzoneName)
  }).stage(fnName, 'zone null', function (vzone)
             local pos = vzone.pos
             local radius = mist.utils.NMToMeters(Const.zoneLabelRadiusStatic)
             if Const.useZoneLabelRadiusStatic == false then
               radius = vzone.radius
             end
             local zoneColor = Util.getZoneColor(axisIndex)

             trigger.action.circleToAll(-1, Util.getNextId(general.fxId), pos, radius, zoneColor[1], zoneColor[2], 4)
             trigger.action.textToAll(-1, Util.getNextId(general.fxId), pos, Const.zoneLabelColor, {0, 0, 0, 0}, Const.zoneLabelTextSize, false, Util.getZoneName(axisIndex, zoneIndex))

  end)
  
end


function getConfig(config, configset)
  for k, v in pairs(ConfigSet[configset]) do
    if k == 'const' then
      config[k] = ConfigSet[configset][k]
    else
      config[k] = Config[k][v]
    end
  end

  config.bPreInit = true
end


function getConfigPost(config)
  
  config.bPostInit = true
end


function testByTimer()

  Util.generateLocsFromAxisesAuto(myConfig.bigZones)
  
end


function verifyZoneList(list, getter)
  local fnName = 'verifyZoneList'
  local res = chain(list).reduce({ failed = false }, function (state, ele)
      local currentRes = rigid({
          getter(ele)
      }).stage(fnName, 'zoneName null', function (zoneName)
                 return rigid({
                     trigger.misc.getZone(zoneName)
                 }).stage(fnName, 'Zone ' .. zoneName .. ' not found!', function (zone)
                            return true
                 end).value()
      end).value()

      if state.failed == true or currentRes == true then
        return state
      else
        return { failed = true }
      end
  end)

  return not res.failed
end


function verifyGroupList(list, getter)
  local fnName = 'verifyGroupList'
  local res = chain(list).reduce({ failed = false }, function (state, ele)
      local currentRes = rigid({
          getter(ele)
      }).stage(fnName, 'groupName null', function (groupName)
                 return rigid({
                     Group.getByName(groupName)
                 }).stage(fnName, 'Group ' .. groupName .. ' not found!', function (group)
                            return true
                 end).value()
      end).value()

      if state.failed == true or currentRes == true then
        return state
      else
        return { failed = true }
      end
  end)

  return not res.failed
end


function verify()
  local fnName = 'verify'
  local res = true
  myDebug3(fnName, 'enter')

  myDebug('Verifying patrol zones..')
  res = Util.unidirectFalse(res, 
                              verifyZoneList(myConfig.patrolZones, function (ele) return ele.name end)
  )

  myDebug('Verifying support zones..')
  res = Util.unidirectFalse(res, 
                              verifyZoneList(myConfig.supportZones, function (ele) return ele.name end)
  )

  myDebug('Verifying big zones..')
  res = Util.unidirectFalse(res, 
                              verifyZoneList(myConfig.bigZones, function (ele) return ele end)
  )

  myDebug('Verifying ground zones..')
  res = Util.unidirectFalse(res, 
                            verifyZoneList(
                              { Const.zoneGroundA, Const.zoneGroundD },
                              function (ele) return ele end)
  )

  myDebug('Verifying groups for types..')
  chain(myConfig.typeToProto).keys().each(function (ele)
      res = Util.unidirectFalse(res, 
                                  verifyGroupList(myConfig.typeToProto[ele], function (ele) return ele end)
      )
  end)
  
  return res
end


function preInit()
  local res = true
  rigid(nil).setUnexpected(Util.unexpected)
  rigid(nil).setPrint(myDebug)
  test()

  myRetail(AppInfo.appName .. ' v' .. AppInfo.ver .. ' by ' .. AppInfo.authorName)
  
  postConfig = objectMerge(postConfig, FixedOption)
  myDebug('postConfig', postConfig)

  Msg.init(myLog, MsgData.messages)
  Msg.setLangCd(postConfig.langCd)
  Msg.setDefaultAudio('beep.wav')
  --Msg.setForceDefaultAudio(true)
  Msg.setRollFn(getByRoll)
  
  getConfig(myConfig, myConfigSet)

  if verify() ~= true then
    return false
  end
  
  if myConfig.const.useAxisesManual then
    general.locs = Util.generateLocsFromAxisesManual(myConfig.axisesManual)
  else
    general.locs = Util.generateLocsFromAxisesAuto(myConfig.bigZones)
  end
  local axisVzones = generateVzonesFromLocs_axis(general.locs)
  general.axisCnt = #axisVzones

  each(axisVzones, function (vzones, i)
         doFirst(vzones, function (vzone)
                   spawnAttackerForVzone(vzone, i)
         end)
  end)

  local supportLocs
  if myConfig.const.useSupportManual then
    supportLocs = Util.generateLocsFromSupportZones(myConfig.supportZones)
  else
    supportLocs = Util.generateLocsFromSupportZoneAuto(myConfig.supportZoneAuto, #myConfig.supportZones)
  end
  general.vzonesSupport = {}
  local supportVzones = generateVzonesFromLocs_support(supportLocs, general.vzonesSupport)

  local exceptList = {}
  each(myConfig.supportZones, function (zone, i)
         local supportProto = generateProtoForType(zone.supportType, exceptList)
         exceptList[#exceptList + 1] = supportProto
         spawnSupportByProto(supportProto, supportVzones[i], zone.isAwacs, zone.unitName, zone.isHeli, zone.spawnLeft, i, zone.isCas)
  end)

  buildMenuInit()
  
  world.addEventHandler(eHandler)
  mist.scheduleFunction(onTimer, {}, timer.getTime() + Const.minPPS, Const.minPPS)

  return res
end


function clearAllMenu()
  chain(commandDb).each(function (command)
      if command.groupId ~= nil then
        missionCommands.removeItemForGroup(command.groupId, command.cmd)
      else
        missionCommands.removeItem(command.cmd)
      end
  end)
  commandDb = {}
end

function buildMenuInit()
  local profiles = {
    'CHANGE_OPT_DIFFICULTY',
    'CHANGE_OPT_EXTENDED',
    'CHANGE_OPT_LUNCHBOX',
    'CHANGE_OPT_SMOKE',     
  }

  clearAllMenu()
  commandDb[#commandDb + 1] = { cmd = missionCommands.addCommand(Msg.getText('msg_ready'), nil, onUserCommand, { id = 'START_OPERATION' }) }
  chain(profiles).each(function (cmdId, i)
      
      if cmdId == 'CHANGE_OPT_DIFFICULTY' and FixedOption.curDifficulty ~= nil then return end
      if cmdId == 'CHANGE_OPT_EXTENDED'   and FixedOption.useStepLimit ~= nil then return end
      if cmdId == 'CHANGE_OPT_LUNCHBOX'   and FixedOption.useLunchBox ~= nil then return end
      if cmdId == 'CHANGE_OPT_SMOKE'      and FixedOption.useSmoke ~= nil then return end
      
      local title = Util.getOptionTitle(cmdId, ': ')
      commandDb[#commandDb + 1] = { cmd = missionCommands.addCommand(title, nil, onUserCommand, { id = cmdId }) }

  end)
  if FixedOption.langCd ~= nil then return end
  if #myConfig.langSupports > 1 then
    local title = Util.getOptionTitle('CHANGE_OPT_LANG', ': ')
    commandDb[#commandDb + 1] = { cmd = missionCommands.addSubMenu(title) }
    appendSubMenuLang(commandDb[#commandDb].cmd)
  end

end


function appendSubMenuYesNo(subMenu, cmdId)
  local fnName = 'appendSubMenuYesNo'

  local options = { true, false }
  
  chain(options)
    .each(function (option, index)
        local title = Util.yesNoStr(option)
        local args = option
        missionCommands.addCommand(title, subMenu, onUserCommand, { id = cmdId, args = args })
    end)
end

function appendSubMenuYesNoForGroup(subMenu, cmdId, groupId, groupName)
  local fnName = 'appendSubMenuYesNoForGroup'

  local options = { true, false }
  
  chain(options)
    .each(function (option, index)
        local title = Util.yesNoStr(option)
        local args = {
          value = option,
          groupName = groupName,
        }
        missionCommands.addCommandForGroup(groupId, title, subMenu, onUserCommand, { id = cmdId, args = args })
    end)
end

function appendSubMenuLang(subMenu)
  local fnName = 'appendSubMenuLang'

  chain(myConfig.langSupports)
    .each(function (langInfo, index)
        local title = Util.getLangName(langInfo.langCd)
        local args = langInfo.langCd
        missionCommands.addCommand(title, subMenu, onUserCommand, { id = 'CHANGE_OPT_LANG', args = args })
    end)
end

function appendSubMenuMove(subMenu)
  chain(general.axises)
    .map(function (axis, axisIndex)
        return { axis, axisIndex }
    end)
    .filter(function (d) return Util.isStateForResumeMenu(d[1].state) end)
    .each(function (d)
        let({
            Util.getAxisName(d[2])
            }, function (title)
                missionCommands.addCommand(title, subMenu, onUserCommand, { id = 'MOVE_ATTACKER', args = d[2] })
            end
        )
    end)
  missionCommands.addCommand(Msg.getText('msg_total'), subMenu, onUserCommand, { id = 'MOVE_ATTACKER', args = 'total' })

end


function appendSubMenuStop(subMenu)
  chain(general.axises)
    .map(function (axis, axisIndex)
        return { axis, axisIndex }
    end)
    .filter(function (d) return Util.isStateForStopMenu(d[1].state) end)
    .each(function (d)
        let({
            Util.getAxisName(d[2])
            }, function (title)
                missionCommands.addCommand(title, subMenu, onUserCommand, { id = 'STOP_ATTACKER', args = d[2] })
            end
        )
    end)
  missionCommands.addCommand(Msg.getText('msg_total'), subMenu, onUserCommand, { id = 'STOP_ATTACKER', args = 'total' })
end


function appendSubSubMenuRequest(subMenu, supportIndex)
  chain(general.axises)
    .map(function (axis, axisIndex)
        return { axis, axisIndex }
    end)
    .each(function (d)
        let({
            Util.getAxisName(d[2])
            }, function (title)
                missionCommands.addCommand(title, subMenu, onUserCommand, { id = 'REQUEST_SUPPORT', args = { eleIndex = supportIndex, axisIndex = d[2] } })
            end
        )
    end)
end


function appendSubMenuRequest(subMenu)
  local fnName = 'appendSubMenuRequest'

  local supportCnt = chain(general.supports).filter(function (support) return support.isAwacs ~= true end).size()

  range(supportCnt).each(function (support, i)
      doFind(general.supports,
             function (support2)
               return support2.initialIndex == i
             end,
             function (support2)
               local subMenu2 = missionCommands.addSubMenu(support2.displayName, subMenu)
               appendSubSubMenuRequest(subMenu2, i)
             end
      )
  end)
  
end
  

function buildMenuMain()
  if general.postInitialized ~= true then
    return
  end

  local fnName = 'buildMenuMain'

  clearAllMenu()
  
  commandDb[#commandDb + 1] = { cmd = missionCommands.addSubMenu(Msg.getText('msg_move_unit')) }
  appendSubMenuMove(commandDb[#commandDb].cmd)
  commandDb[#commandDb + 1] = { cmd = missionCommands.addSubMenu(Msg.getText('msg_stop_unit')) }
  appendSubMenuStop(commandDb[#commandDb].cmd)
  commandDb[#commandDb + 1] = { cmd = missionCommands.addSubMenu(Msg.getText('msg_request_support')) }
  appendSubMenuRequest(commandDb[#commandDb].cmd)
  commandDb[#commandDb + 1] = { cmd = missionCommands.addCommand(Msg.getText('msg_report_status'), nil, onUserCommand, { id = 'REPORT_STATUS' }) }

  if Const.useRestartMenu then
    local clientIds = Util.getClientIds()
    myDebug('client ids', clientIds)
    
    chain(clientIds)
      .each(function (clientId)
          commandDb[#commandDb + 1] = {
            cmd = missionCommands.addSubMenuForGroup(clientId.id, Msg.getText('msg_restart_operation')),
            groupId = clientId.id
          }
          appendSubMenuYesNoForGroup(commandDb[#commandDb].cmd, 'RESTART_OPERATION', clientId.id, clientId.groupName)
      end)
  end

  if TestFeature.testMenu then
    commandDb[#commandDb + 1] = { cmd = missionCommands.addCommand(Msg.getText('msg_test_menu'), nil, onUserCommand, { id = 'TEST_MENU', args = 1 }) }
    commandDb[#commandDb + 1] = { cmd = missionCommands.addCommand(Msg.getText('msg_test_menu') .. ' 2', nil, onUserCommand, { id = 'TEST_MENU2', args = 1 }) }
  end
end


function generateVzonesFromLocs_axis(axisLocs)
  general.vzones = {}
  return map(axisLocs,
             function (locs, axisIndex)
               return map(locs,
                          function (loc, zoneIndex)
                            Util.addToList(general.vzones, Const.vzoneInitial,
                                           {
                                             name = Util.makeZoneKey_axis(axisIndex, zoneIndex),
                                             axisIndex = axisIndex,
                                             pos = loc.pos,
                                             radius = loc.radius,
                                           }
                            )
                            return Util.makeZoneKey_axis(axisIndex, zoneIndex)
                          end
               )
             end
  )
end


function generateVzonesFromLocs_support(locs, backList)
  return map(locs,
             function (loc, supportIndex)
               Util.addToList(general.vzones, Const.vzoneInitial,
                              {
                                name = Util.makeZoneKey_support(supportIndex),
                                pos = loc.pos,
                                radius = loc.radius,
                              }
               )
               if backList ~= nil then
                 Util.addToList(backList, Const.vzoneInitial,
                                {
                                  name = Util.makeZoneKey_support(supportIndex),
                                  pos = loc.pos,
                                  radius = loc.radius,
                                }
                 )
               end
               return Util.makeZoneKey_support(supportIndex)
             end)
end

function generateVzonesFromLocs_patrol(locs)
  return map(locs,
             function (loc, patrolIndex)
               Util.addToList(general.vzones, Const.vzoneInitial,
                              {
                                name = Util.makeZoneKey_patrol(patrolIndex),
                                pos = loc.pos,
                                radius = loc.radius,
                              }
               )
               return Util.makeZoneKey_patrol(patrolIndex)
             end)
end


function checkSlowMode()
  local fnName = 'checkSlowMode'
  
  return chain(myConfig.clients)
    .reduce({ use = true }, function (res, client)
        return let({
            Group.getByName(client.groupName)
        }, function (group)

            return branch({}, group ~= nil and client.isSlow ~= true, function ()
                return { use = false }
            end).value()
        end).value() or res    
    end)['use']
end

function checkHeliMode()
  local fnName = 'checkHeliMode'
  
  return chain(myConfig.clients)
    .reduce({ use = true }, function (res, client)
        return let({
            Group.getByName(client.groupName)
        }, function (group)

            return branch({}, group ~= nil and client.isHeli ~= true, function ()
                return { use = false }
            end).value()
        end).value() or res    
    end)['use']
end


function detectClient()
  local found = false
  chain(myConfig.clients)
    .each(function (client)
        return let({
            Group.getByName(client.groupName)
        }, function (group)
            branch({}, group ~= nil, function ()
                local msg = 'Client detected ' .. client.groupName
                if client.isSlow == true then
                  msg = msg .. '[SLOW]'
                end
                if client.isHeli == true then
                  msg = msg .. '[HELI]'
                end
                Util.broadcast(msg)
                found = true
            end)
        end)
    end)

  if found ~= true then
    Util.broadcast('Client NOT detected!')
  end
end


function generateCardList()
  local fnName = 'generateCardList'

  general.cardList = unpreferably('gen-card', {
                 function (context)
                   return {
                     anv = chain(general.axises)
                       .reduce({}, function (res, axis, axisIndex)
                           return tableConcat(res,
                                              chain(axis.vzones)
                                              .map(function (vzone, vzoneIndex)
                                                  return { axisIndex, vzoneIndex }
                                                  end).value()
                           )
                       end),
                     cards = range(#myConfig.const.cardShapes)
                       .reduce({}, function (res, cardShape)
                           return tableConcat(res,
                                              range(myConfig.const.cardRange)
                                              .map(function (cardNum)
                                                  return { cardShape, cardNum }
                                                  end).value()
                           )
                       end),
                   }
                 end,
                 function (context)
                   return rigid({
                       context.anv,
                       context.cards,
                   }).stage(fnName, 'generate selected anv, cards', function (anv, cards)
                              return let({
                                  Util.randomMulti(#anv, myConfig.const.cardNumMax),
                                  Util.randomMulti(#cards, myConfig.const.cardNumMax)
                              }, function (anvSelectedIndexes, cardsSelectedIndexes)
                                  return {
                                    anv = chain(anv).filter(function (d, i)
                                        return contains(anvSelectedIndexes, i)
                                    end).value(),
                                    cards = chain(cards).filter(function (d, i)
                                        return contains(cardsSelectedIndexes, i)
                                    end).value(),
                                  }
                              end).value()
                   end).value()
                 end,
                 function (context)
                   return rigid({
                       context.anv,
                       context.cards,
                   }).stage(fnName, 'merging selected anv, cards', function (anv, cards)
                              return range(myConfig.const.cardNumMax).map(function (i)
                                  return {
                                    axisIndex = anv[i][1],
                                    vzoneIndex = anv[i][2],
                                    cardShape = cards[i][1],
                                    cardNum = cards[i][2],
                                  }
                              end).value()
                   end).value()
                 end
  })

end


function postInit()
  local fnName = 'postInit'

  general.blockPostInit = true
  
  if TestFeature.useDetectClient == true then
    detectClient()
  end
  
  getConfigPost(myConfig)
  setConfigFromDifficulty()

  Util.generateAwacsName()
  Util.notifyOP('msg_start_operation')
  local msg = makeSpecialtyMsg()
  if not Util.isEmpty(msg) then
    Util.broadcast(msg)
  end
  
  local header = Msg.getText('msg_success_condition_header_initial')
  local footer = Msg.getText('msg_success_condition_initial')
  Util.broadcast(header .. postConfig.axisCntSuccess .. footer)

  myDebug('postConfig', postConfig)

  
  if myConfig.const.stepLimit > 0 and postConfig.useStepLimit then
    general.locs = map(general.locs,
                           function (locs, i)
                             return filter(locs, function (d, i) return i <= myConfig.const.stepLimit + 1 end) -- +1 for entry
    end)
  end
  
  local axisVzones = generateVzonesFromLocs_axis(general.locs)
  general.vzones = tableConcat(general.vzones, general.vzonesSupport)

  if myConfig.const.useSlowMode == true then
    general.slowMode = checkSlowMode()
  end
  if myConfig.const.useHeliMode == true then
    general.heliMode = checkHeliMode()
  end
  
  -- axises
  general.axises = map(axisVzones,
                       function (vzones)
                         local axis = deepcopy(Const.axisInitial)
                         axis.vzones = slice(vzones, 1)
                         axis.maxStep = #axis.vzones -- for checking axis complete
                         axis.searchCnt = mist.random(myConfig.const.periodSearch - 1)
                         axis.rollAlert = myConfig.const.rollAlertBasis - math.floor(myConfig.const.rollAlertDisperse / 2) + (mist.random(myConfig.const.rollAlertDisperse) - 1)
                         -- rollAlert : patrol dispatch chance on defender destroyed
                         if general.slowMode == true then
                           axis.rollAlert = axis.rollAlert * myConfig.const.diminishChanceRatio
                         end
                         axis.rollAlert = max(Const.rollAlertMin, axis.rollAlert)
                         axis.alertRadiuses = map(axis.vzones, function (vzoneName)
                                                    return rigid({
                                                        Util.getVzoneByName(vzoneName)
                                                    }).stage(fnName, 'vzone null', function (vzone)
                                                               return vzone.radius
                                                    end).value()
                         end)

                         return axis
  end)

  if Const.useCardPick == true then
    generateCardList()
  end

  if TestFeature.useTestCard == true then
    general.cardPicked = chain(general.cardList).slice(1).value()
    myDebug('cardPicked', general.cardPicked)
  end

  chain(general.axises)
    .map(function (axis, axisIndex)
        general.finishedAxis[axisIndex] = false
    end)

  -- zone label
  chain(general.axises)
    .map(function (axis, axisIndex)
        each(axis.vzones, function (vzone, zoneIndex)
               drawZoneLabel(vzone, axisIndex, zoneIndex)
        end)
    end)

  -- spawn defender
  chain(general.axises)
    .each(function (axis)
        each(axis.vzones, function (vzone, i)
               spawnDefenderForZone(vzone, i ,#axis.vzones)
        end)
    end)


  local patrolLocs
  if myConfig.const.usePatrolManual then
    patrolLocs = Util.generateLocsFromSupportZones(myConfig.patrolZones)
  else
    patrolLocs = Util.generateLocsFromSupportZoneAuto(myConfig.patrolZoneAuto, #myConfig.patrolZones)
  end
  
  local patrolVzones = generateVzonesFromLocs_patrol(patrolLocs)

  -- spawn patrol
  local exceptList = {}
  each(myConfig.patrolZones, function (zone, i)
         local patrolProto = generateProtoForType(zone.patrolType, exceptList)
         exceptList[#exceptList + 1] = patrolProto
         spawnPatrolByProto(patrolProto, patrolVzones[i], zone.isHeli, i)
  end)

  range(general.axisCnt).each(function (axisIndex)
      moveAttackers(axisIndex, axisIndex < general.axisCnt)
  end)

  general.postInitialized = true
  buildMenuMain()
  
end


if preInit() == true then
  Msg.notifyC('msg_init_guide')
else
  Util.broadcast('VERIFY FAILED')
end

myDebug('--- script loading end')



-- next: 
--
