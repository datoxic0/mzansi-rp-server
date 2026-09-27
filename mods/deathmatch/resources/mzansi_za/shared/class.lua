-- Lightweight class helper for Mzansi-ZA
Class = Class or {}

function Class:new()
    local instance = setmetatable({}, self)
    self.__index = self
    return instance
end

function Class:extend(parent)
    local child = setmetatable({}, parent or Class)
    child.__index = child
    child.super = parent
    return child
end

function Class:__call(...)
    return self:new(...)
end
