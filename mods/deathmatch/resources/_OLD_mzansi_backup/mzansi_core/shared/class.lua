-- Mzansi-ZA Shared Class System
-- OOP utility for Lua 5.1/JIT

class = {}

function class.new(base)
    local c = {}
    c.__index = c
    c.__super = base

    if base then
        setmetatable(c, { __index = base })
    end

    function c:constructor(...) end

    function c:new(...)
        local instance = setmetatable({}, c)
        instance:constructor(...)
        return instance
    end

    function c:super(...)
        if self.__super and self.__super.constructor then
            self.__super.constructor(self, ...)
        end
    end

    return c
end

-- Singleton pattern helper
function class.singleton(classTable)
    local instance = nil
    local mt = getmetatable(classTable) or {}
    mt.__call = function(self, ...)
        if not instance then
            instance = classTable:new(...)
        end
        return instance
    end
    setmetatable(classTable, mt)
    return classTable
end

-- Static class helper (no instantiation)
function class.static(classTable)
    classTable.new = function() error("Static class cannot be instantiated") end
    return classTable
end

-- Interface/trait-like composition
function class.mixin(target, ...)
    for _, source in ipairs({...}) do
        for k, v in pairs(source) do
            if k ~= "constructor" and k ~= "new" and k ~= "super" then
                target[k] = v
            end
        end
    end
    return target
end

-- EventEmitter mixin for classes
EventEmitter = {
    _listeners = {},
    on = function(self, event, callback)
        self._listeners[event] = self._listeners[event] or {}
        table.insert(self._listeners[event], callback)
        return self
    end,
    off = function(self, event, callback)
        if not self._listeners[event] then return self end
        for i, cb in ipairs(self._listeners[event]) do
            if cb == callback then
                table.remove(self._listeners[event], i)
                break
            end
        end
        return self
    end,
    emit = function(self, event, ...)
        if not self._listeners[event] then return self end
        for _, cb in ipairs(self._listeners[event]) do
            cb(...)
        end
        return self
    end,
    once = function(self, event, callback)
        local wrapper
        wrapper = function(...)
            callback(...)
            self:off(event, wrapper)
        end
        self:on(event, wrapper)
        return self
    end
}

-- Export for both client and server
_G.class = class
_G.EventEmitter = EventEmitter