local socket = require('socket')
local utf8 = require("utf8_validator")

local repeat_time = 1000000
local function benchmark(funcname, func, str)
    local start_time = socket.gettime()

    for i = 1, repeat_time do
        func(str)
    end
    local res = func(str)
    print(string.format("- %s took %f, result %s",
    	funcname, (socket.gettime() - start_time) * 1000, tostring(res)))
end

local test_cases = {
    { desc = 'very short ascii string', str = 'a', valid = true },
    { desc = 'somewhat longer ascii string', str = 'this is a much longer ascii string, hello', valid = true },
    { desc = 'utf8 stuff', str = '¢€𤭢', valid = true },
    { desc = 'mixed stuff', str = 'Pay in €. Thanks.', valid = true },
}

for _, case in ipairs(test_cases) do
    print(string.format("benchmark for: %s, string '%s'", case.desc, case.str))
    benchmark('validate', utf8.validate, case.str)
    benchmark('validate2', utf8.validate2, case.str)
    benchmark('ascii_only', utf8.ascii_only, case.str)
end
