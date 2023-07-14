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

MrInfo = {
  ver = '1.00.000'
}

function map(list, func, chained)
  local mapped = {}
  for i=1,#list do
    mapped[#mapped+1] = func(list[i], i)
  end 
  if chained == true then
    return chain(mapped)
  else
    return mapped
  end
end

function reduce(list, memo, func)   
  local startPos = 1

  if memo == nil then
    memo = list[1]
    startPos = 2
  end
  for i=startPos,#list do
    memo = func(memo, list[i], i)
  end
  return memo
end

function each(list, func, chained)
  for i=1,#list do
    func(list[i], i)
  end 
  if chained == true then
    return chain(list)
  else
    return list
  end
end

function reverse(list, chained)
  local selected = {}
  for i=#list,1,-1 do
    selected[#selected+1] = list[i]
  end
  if chained == true then
    return chain(selected)
  else
    return selected
  end
end

function slice(list, n,chained)
  local selected = {}
  for i=1+n,#list do
    selected[#selected+1] = list[i]
  end
  if chained == true then
    return chain(selected)
  else
    return selected
  end
end

function filter(list, func, chained)
  local selected = {}
  for i=1,#list do
    if func(list[i], i) then selected[#selected+1] = list[i] end
  end
  if chained == true then
    return chain(selected)
  else
    return selected
  end
end

function find(list, func)
  for i=1,#list do
    if func(list[i], i) then return list[i] end
  end
  return nil
end

function every(list, func)
  for i=1,#list do
    if not func(list[i], i) then return false end
  end
  return true
end

function some(list, func)
  for i=1,#list do
    if func(list[i], i) then return true end
  end
  return false
end

function doSize(list, func, chained)
  func(#list)
  if chained == true then
    return chain(list)
  else
    return list
  end
end

function doFirst(list, func)
  if #list > 0 then
    return func(list[1], 1)
    --return list[1]
  end
  return nil
end

function doLast(list, func)
  if #list > 0 then
    return func(list[#list], #list)
    --return list[#list]
  end
  return nil
end

function doRandom(list, func)
  if #list > 0 then
    local rand = math.random(#list)
    func(list[rand], rand)
    return list[rand]
  end
  return nil
end

function doFind(list, funcFind, funcDo, funcError)
  for i=1,#list do
    if funcFind(list[i], i) then
      return funcDo(list[i], i)
    end
  end
  if funcError ~= nil then
    funcError()
  end
  return nil
end

function doNext(list, funcFind, funcDo)
  for i=1,#list do
    if funcFind(list[i], i) and i < #list then
      return funcDo(list[i+1], i+1)
    end
  end
  return nil
end

function doPrev(list, funcFind, funcDo)
  for i=1,#list do
    if funcFind(list[i], i) and i > 1 then
      return funcDo(list[i-1], i-1)
    end
  end
  return nil
end

function get(table, key)
  if type(key) == 'function' then
    return table[key()]
  else
    return table[key]
  end
end

function hasValue(table, value)
  for k,v in pairs(table) do
    if v == value then return true end
  end
  return false
  --for i=1,#list do
  --  if list[i] == value then return true end
  --end
  --return false
end

function hasKey(table, key)
  for k,v in pairs(table) do
    if k == key then return true end
  end
  return false
end

function size(list)
  return #list
end

--function sizeT(table)
--  local size = 0
--  for k,v in pairs(table) do
--    size = size + 1
--  end
--  return size
--end

function keys(table, chained)
	local keys = {}
	for k,v in pairs(table) do
		keys[#keys+1] = k
	end
  if chained == true then
    return chain(keys)
  else
    return keys
  end
end

function isEmpty(table)
  for k,v in pairs(table) do
    return false
  end
  return true
end

function reject(list, func, chained)
  local selected = {}
  for i=1,#list do
    if not func(list[i], i) then selected[#selected+1] = list[i] end
  end
  if chained == true then
    return chain(selected)
  else
    return selected
  end
end

function multiple(list, n, chained)
  local multipled = deepcopy(list)
  for i=1,n-1 do
    for j=1,#list do
      multipled[#multipled+1] = list[j]
    end
  end
  if chained == true then
    return chain(multipled)
  else
    return multipled
  end
end

function double(list, chained)
  return multiple(list, 2, chained)
end

function limit(list, n, chained)
  local endPos = #list
  local selected = {}
  if n > 0 and endPos > 0 then
    if endPos > n then endPos = n end

    for i=1,endPos do
      selected[#selected+1] = list[i]
    end
  end
  if chained == true then
    return chain(selected)
  else
    return selected
  end
end

contains = hasValue

function chain(list)
  return {
    map = function (func) return map(list, func, true) end,
    reduce = function (memo, func) return reduce(list, memo, func) end,
    each = function (func) return each(list, func, true) end,
    filter = function (func) return filter(list, func, true) end,
    reject = function (func) return reject(list, func, true) end,
    value = function () return list end,
    find = function (func) return find(list, func) end,
    every = function (func) return every(list, func) end,
    some = function (func) return some(list, func) end,
    doFirst = function (func) return doFirst(list, func) end,
    doLast = function (func) return doLast(list, func) end,
    doRandom = function (func) return doRandom(list, func) end,
    doSize = function (func) return doSize(list, func, true) end,
    doFind = function (funcFind, funcDo) return doFind(list, funcFind, funcDo) end,
    get = function (key) return get(list, key) end,
    hasKey = function (func, value) return hasKey(list, func, value) end,
    hasValue = function (func, value) return hasValue(list, func, value) end,
    contains = function (func, value) return contains(list, func, value) end,
    keys = function () return keys(list, true) end,
    isEmpty = function () return isEmpty(list) end,
    size = function () return size(list) end,
    double = function () return double(list, true) end,
    multiple = function (n) return multiple(list, n, true) end,
    limit = function (n) return limit(list, n, true) end,
    reverse = function () return reverse(list, true) end,
    slice = function (n) return slice(list, n, true) end,
  }
end

function range(startPos, endPos, step, chained)
  chained = chained or true
  step = step or 1
  ret = {}
  if startPos == nil then
    return ret
  end

  if endPos == nil then
    endPos = startPos
    startPos = 1
  end
  
  for i = startPos, endPos, step do
    ret[#ret + 1] = i
  end
  if chained == true then
    return chain(ret)
  else
    return ret
  end
end


-----------------------------------------------------------------

_rigid_unexpected = nil
_rigid_print = nil

function tableConcatOW(t1,t2) -- overwrite first
  local s1 = #t1
  local s2 = #t2
  local j = #t1+1
  for i=1,#t2 do
    t1[j] = t2[i]
    j = j + 1
    --t1[#t1+1] = t2[i]
  end
  return t1
end

function tableConcat(t1,t2) -- number indexed element only
  local s1 = #t1
  local s2 = #t2
  local j = #t1+1
  local merged = {}
  for i=1,#t1 do
    merged[i] = t1[i]
  end
  for i=1,#t2 do
    merged[j] = t2[i]
    j = j + 1
    --t1[#t1+1] = t2[i]
  end
  return merged
end

function objectMerge(o1,...) -- both non-number and number indexed element
  -- 첫번째 외 오브젝트는 deepcopy되지 않음에 유의!! (특히 변수일 경우)
  o1 = o1 or {}
  local merged = deepcopy(o1)
  for i=1,#arg do
    local o2 = arg[i]
    for k,v in pairs(o2) do merged[k] = v end
  end

  return merged
end

function objectOmit(o1,list) -- both non-number and number indexed element
  local res = {}
  local copied = deepcopy(o1)
  for k,v in pairs(copied) do
    if not contains(list, k) then
      res[k] = v
    end
  end

  return res
end

function objectPick(o1,list) -- both non-number and number indexed element
  local res = {}
  local copied = deepcopy(o1)
  for k,v in pairs(copied) do
    if contains(list, k) then
      res[k] = v
    end
  end

  return res
end

function checkDuplicate(list)
  local checkSet = {}
  for i=1,#list do
    if contains(checkSet, list[i]) then
      return { true, list[i] }
    else
      checkSet[#checkSet + 1] = list[i]
    end
  end
  return { false, nil }
end

function tableEmpty(t)
  if next(t) == nil then return true else return false end
end

function stage(param, name, reason, func, module, rigided, ignore, shift)
  
  if ignore ~= true then

    local errorMsg = nil
    local selected = {}
    if type(param) ~= 'table' then
      errorMsg = 'not a table'
    elseif tableEmpty(param) then
      errorMsg = reason
    else

      if shift ~= true then
        selected = param
      else
        local j = 1
        for i=1,#param do
          if type(param[i]) == 'table' and #param[i] == 1 then
            errorMsg = "shift: keyword nil ('" .. i .. "')"
            break
          elseif type(param[i]) == 'table' and #param[i] == 2 then
            if type(param[i][1]) ~= 'table' then
              errorMsg = "shift: not a table ('" .. i .. "')"
              break
            end
            selected[j] = param[i][1][ param[i][2] ]
            j = j + 1
          else
            selected[j] = param[i]
            j = j + 1
          end
        end
      end

      if errorMsg == nil then
        for i=1,#selected do
          if selected[i] == nil then
            errorMsg = reason .. ' (' .. i ..')'
          end
        end
      end
    end

    if errorMsg ~= nil then
      if _rigid_unexpected ~= nil then
        _rigid_unexpected(name, errorMsg, module)
      end
    else
      if rigided == true then
        return rigid({func(unpack(selected))})
      else
        return func(unpack(selected))
      end
    end
  end
    
  if rigided == true then
    return rigid({nil}, true)
  else
    return nil
  end
end

function shift(param, name, reason, func, module, rigided, ignore)
  return stage(param, name, reason, func, module, rigided, ignore, true)
end

function condition(param, name, reason, cond, func, module, rigided, ignore)
  -- /cancel/ finalize call only
  if ignore ~= true then
    if not cond then
      if _rigid_unexpected ~= nil then
        _rigid_unexpected(name, reason, module)
      end
    else
      if rigided == true then
        return rigid({func(unpack(param))})
      else
        return func(unpack(param))
      end
    end
  end
  
  if rigided == true then
    return rigid({nil}, true)
  else
    return nil
  end
end

function rigid(param, ignore)
  return {
    setPrint = function (aprint)
      _rigid_print = aprint
      return rigid(param, ignore)
    end,
    setUnexpected = function (unexpected)
      _rigid_unexpected = unexpected
      return rigid(param, ignore)
    end,
    stage = function (name, reason, func, module) return stage(param, name, reason, func, module, true, ignore) end,
    shift = function (name, reason, func, module) return shift(param, name, reason, func, module, true, ignore) end,
    value = function ()
      return param[1]
    end,
    prn = function ()
      if ignore ~= true and _rigid_print then
        _rigid_print(param)
      end
      return rigid(param, ignore)
    end,
    condition = function (name, reason, cond, func, module) return condition(param, name, reason, cond, func, module, true, ignore) end,
  }
end

function let(param, func)
  return rigid({func(unpack(param))})
end

function branch(param, cond, funcThen, funcElse)
  if cond then
    return rigid({funcThen(unpack(param))})
  else
    if funcElse ~= nil then
      return rigid({funcElse(unpack(param))})
    end
  end
  return rigid({nil})
end

-----------------------------------------------------------------

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function preferablyVal(list)
  local res = nil
  for i=1,#list do
    if i ~= nil then
      res = i
      break
    end
  end

  return res
end

Pref = {
  stop = {},
  continue = nil
}

Unpref = {
  stop = nil,
  continue = {}
}

function preferably(list, context)
  context = context or {}
  local res = nil
  for i=1,#list do
    local func = list[i]
    res = func(context)
    if res ~= nil then
      break
    end
  end

  return res
end

function unpreferably(name, list, context)
  --todo: consider finalizer(or funcReject)

  context = context or {}
  local res = nil
  for i=1,#list do
    local func = list[i]
    res = func(context)
    if res == nil then
      break
    end
    if type(res) ~= 'table' then
      -- unexpected
      break
    end
    for k,v in pairs(res) do
      context[k] = v
    end
    
  end

  return res
end

arrow = unpreferably

function hardarrow(name, list)
  -- assert each values in result is not null
end

function min(a, b)
  if a < b then
    return a
  end
  return b
end

function max(a, b)
  if a > b then
    return a
  end
  return b
end

nextUntil = preferably

--function nextUntil(list)
--end

function nextWhile(list)
end

