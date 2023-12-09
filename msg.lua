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

Msg = {
  langCd = 'kr',
  data = nil,
  logObj = nil,
  rollFn = nil,
  forceDefaultAudio = false,
  audioPrefix = '',
  defaultAudio = nil,
  lastTime = 0,
  ignoreTimePeriod = 2,
  syncAudio = nil,

  init = function (logObj, data)
    Msg.data = data
    Msg.logObj = logObj
    Msg.log('Msg - init success')
  end,
  getCurDb = function ()
    if Msg.data ~= nil then
      return Msg.data[Msg.langCd].content or {}
    end
    return {}
  end,
  setLangCd = function (langCd)
    Msg.langCd = langCd
    Msg.setSyncAudio(Msg.data[Msg.langCd].syncAudio)
  end,
  setForceDefaultAudio = function (value)
    Msg.forceDefaultAudio = value
  end,
  setDefaultAudio = function (value)
    Msg.defaultAudio = value
  end,
  setSyncAudio = function (value)
    Msg.syncAudio = value
  end,
  getText = function (msgId, retExtra)
    local curDb = Msg.getCurDb()
    if curDb ~= nil then
      local msgRow = curDb[msgId]
      if msgRow ~= nil and msgRow.text ~= nil then
        local info = Msg.rollFn(msgRow.text, true)
        if retExtra == true then
          return info
        else
          return info[1]
        end
      end
    end
    if retExtra == true then
      return {msgId, 1}
    else
      return msgId
    end
  end,
  getAudio = function (msgId, selIndex)
    local curDb = Msg.getCurDb()
    if curDb ~= nil then
      local msgRow = curDb[msgId]
      if msgRow ~= nil and msgRow.audio ~= nil then
        local audio
        if Msg.syncAudio == true then
          audio = msgRow.audio[selIndex]
        else
          audio = Msg.rollFn(msgRow.audio)
        end
        audio = audio or ''
        return Msg.audioPrefix .. audio
      end
    end
    return nil
  end,
  setRollFn = function (rollFn)
    Msg.rollFn = rollFn
  end,
  log = function (str)
    if Msg.logObj ~= nil then
      Msg.logObj:msg(str)
    end
  end,
  setAudioPrefix = function (prefix)
    Msg.audioPrefix = prefix
  end,
  notifyG = function (msgId, groupName, opt)
    local group = Group.getByName(groupName)
    if group ~= nil then
      opt.groupId = group[id]
      Msg.notifyCore(msgId, opt)
    end
  end,
  notifyC = function (msgId, opt)
    Msg.notifyCore(msgId, opt)
  end,
  checkNoIgnore = function (isDefault)
    --_todo : for each groups
    local curTime = timer.getTime()
    if curTime - Msg.lastTime >= 0 and curTime - Msg.lastTime < Msg.ignoreTimePeriod then
      return false
    end
    --if isDefault ~= true then
    Msg.lastTime = curTime
    --end
    return true
  end,
  notifyCore = function (msgId, opt)
    -- not set timer when default audio
    
    opt = opt or {}
    local groupId = opt.groupId
    local coalition = opt.coalition or 2 -- default blue
    local altText = opt.altText
    local audioOnly = opt.audioOnly
    local prefix = opt.prefix
    local text = nil
    local selIndex = 1
    if altText ~= nil then
      text = altText
    else
      local info = Msg.getText(msgId, true)
      text = info[1]
      selIndex = info[2]
    end
    if prefix ~= nil then
      text = prefix .. text
    end
    local audio = Msg.getAudio(msgId, selIndex)
    
    if text ~= nil and audioOnly ~= true then
      if groupId ~= nil then
        trigger.action.outTextForGroup(groupId, text .. '\n', 15)
      else
        trigger.action.outTextForCoalition(coalition, text .. '\n', 15)
      end
    end

    if audio == nil then
      if Msg.defaultAudio ~= nil then
        if groupId ~= nil then
          trigger.action.outSoundForGroup(groupId, Msg.defaultAudio)
        else
          if Msg.checkNoIgnore(true) then
            trigger.action.outSoundForCoalition(coalition, Msg.defaultAudio)
          end
        end
      end
    else
      if Msg.forceDefaultAudio and Msg.defaultAudio ~= nil then
        if groupId ~= nil then
          trigger.action.outSoundForGroup(groupId, Msg.defaultAudio)
        else
          if Msg.checkNoIgnore(true) then
            trigger.action.outSoundForCoalition(coalition, Msg.defaultAudio)
          end
        end
      else
        if groupId ~= nil then
          trigger.action.outSoundForGroup(groupId, audio)
        else
          if Msg.checkNoIgnore() then
            trigger.action.outSoundForCoalition(coalition, audio)
          end
        end
      end
    end
  end
}

