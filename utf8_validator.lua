local utf8_validator = {
  __VERSION     = '0.0.2',
  __DESCRIPTION = 'Library for easily validating UTF-8 strings in pure Lua',
  __URL         = 'https://github.com/kikito/utf8_validator.lua',
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local find = string.find

-- Numbers taken from table 3-7 in www.unicode.org/versions/Unicode6.2.0/UnicodeStandard-6.2.pdf
-- find-based solution inspired by http://notebook.kulchenko.com/programming/fixing-malformed-utf8-in-lua
function utf8_validator.validate(str)
  local i, len = 1, #str
  while i <= len do
    if     i == find(str, "[%z\1-\127]", i) then i = i + 1
    elseif i == find(str, "[\194-\223][\128-\191]", i) then i = i + 2
    elseif i == find(str,        "\224[\160-\191][\128-\191]", i)
        or i == find(str, "[\225-\236][\128-\191][\128-\191]", i)
        or i == find(str,        "\237[\128-\159][\128-\191]", i)
        or i == find(str, "[\238-\239][\128-\191][\128-\191]", i) then i = i + 3
    elseif i == find(str,        "\240[\144-\191][\128-\191][\128-\191]", i)
        or i == find(str, "[\241-\243][\128-\191][\128-\191][\128-\191]", i)
        or i == find(str,        "\244[\128-\143][\128-\191][\128-\191]", i) then i = i + 4
    else
      return false, i
    end
  end

  return true
end

-- Accept range for second byte of utf8
local accept_range = {
  {lo = 0x80, hi = 0xBF},
  {lo = 0xA0, hi = 0xBF},
  {lo = 0x80, hi = 0x9F},
  {lo = 0x90, hi = 0xBF},
  {lo = 0x80, hi = 0x8F}
}

function utf8_validator.validate2(str)
  local i, n = 1, #str
  local first, byte, left_size, range_idx
  while i <= n do
    first = string.byte(str, i)
    if first >= 0x80 then
      range_idx = 1
      if first >= 0xC2 and first <= 0xDF then --2 bytes
        left_size = 1
      elseif first >= 0xE0 and first <= 0xEF then --3 bytes
        left_size = 2
        if first == 0xE0 then
          range_idx = 2
        elseif first == 0xED then
          range_idx = 3
        end
      elseif first >= 0xF0 and first <= 0xF4 then --4 bytes
        left_size = 3
        if first == 0xF0 then
          range_idx = 4
        elseif first == 0xF4 then
          range_idx = 5
        end
      else
        return false
      end

      if i + left_size  > n then
        return false
      end

      for j = 1, left_size do
        byte = string.byte(str, i + j, i + j)
        if byte < accept_range[range_idx].lo or byte > accept_range[range_idx].hi then
          return false
        end
        range_idx = 1
      end
      i = i + left_size
    end
    i = i + 1
  end
  return true
end


setmetatable(utf8_validator, {__call = function(_, ...) return utf8_validator.validate(...) end})

return utf8_validator
