Mzansi = Mzansi or {}
Mzansi.Class = {}

local function class_new(cls, ...)
    local instance = setmetatable({}, cls)
    if cls.init then
        cls.init(instance, ...)
    end
    return instance
end

local function class_extend(parent)
    local child = setmetatable({}, { __index = parent })
    child.__index = child
    child.super = parent
    child.new = class_new
    return child
end

setmetatable(Mzansi.Class, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
})

function Mzansi.Class:new(...)
    local cls = setmetatable({}, self)
    cls.__index = cls
    return cls
end

function Mzansi.Class:extend()
    return class_extend(self)
end

function Mzansi.Class:isInstanceOf(parent)
    local mt = getmetatable(self)
    while mt do
        if mt == parent then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

Mzansi.Class.EventEmitter = Mzansi.Class:extend()

function Mzansi.Class.EventEmitter:init()
    self._listeners = {}
end

function Mzansi.Class.EventEmitter:on(event, callback)
    if not self._listeners[event] then
        self._listeners[event] = {}
    end
    table.insert(self._listeners[event], callback)
    return function()
        self:off(event, callback)
    end
end

function Mzansi.Class.EventEmitter:off(event, callback)
    if not self._listeners[event] then return end
    for i, cb in ipairs(self._listeners[event]) do
        if cb == callback then
            table.remove(self._listeners[event], i)
            return
        end
    end
end

function Mzansi.Class.EventEmitter:emit(event, ...)
    if not self._listeners[event] then return end
    for _, callback in ipairs(self._listeners[event]) do
        callback(...)
    end
end

function Mzansi.Class.EventEmitter:removeAllListeners(event)
    if event then
        self._listeners[event] = nil
    else
        self._listeners = {}
    end
end

Mzansi.Class.Model = Mzansi.Class:extend()

function Mzansi.Class.Model:init(data)
    self._data = data or {}
    self._dirty = false
end

function Mzansi.Class.Model:get(key, default)
    return self._data[key] or default
end

function Mzansi.Class.Model:set(key, value)
    if self._data[key] ~= value then
        self._data[key] = value
        self._dirty = true
    end
end

function Mzansi.Class.Model:toTable()
    local result = {}
    for k, v in pairs(self._data) do
        result[k] = v
    end
    return result
end

function Mzansi.Class.Model:isDirty()
    return self._dirty
end

function Mzansi.Class.Model:markClean()
    self._dirty = false
end

Mzansi.Class.Service = Mzansi.Class:extend()

function Mzansi.Class.Service:init(name)
    self.name = name
    self._running = false
end

function Mzansi.Class.Service:start()
    if self._running then return end
    self._running = true
    self:onStart()
end

function Mzansi.Class.Service:stop()
    if not self._running then return end
    self._running = false
    self:onStop()
end

function Mzansi.Class.Service:isRunning()
    return self._running
end

function Mzansi.Class.Service:onStart() end
function Mzansi.Class.Service:onStop() end
