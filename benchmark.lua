local utf8 = require("utf8_validator")

local repeat_time = 1000000
local function benchmark(func, str)
    ngx.update_time()
    local start_time = ngx.now()

    for i = 1, repeat_time do
        func(str)
    end
    ngx.update_time()
    ngx.say((ngx.now() - start_time) * 1000)
end

local test_cases = {
    { desc = 'plain ascii', str = 'Hello word',        valid = true },
    { desc = 'utf8 stuff',  str = '¢€𤭢',              valid = true },
    { desc = 'mixed stuff', str = 'Pay in €. Thanks.', valid = true },
}

for _, case in ipairs(test_cases) do
    ngx.say(string.format("benchmark for %s, string %s", case.desc, case.str))
    benchmark(utf8.validate, case.str)
    benchmark(utf8.validate2, case.str)
end
