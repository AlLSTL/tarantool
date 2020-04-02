#!/usr/bin/env tarantool
test = require("sqltester")
test:plan(2)

--
-- If left value of IN and NOT IN operators is not a vector with
-- length more that one, make sure that it cannot be compared to
-- right values in case they are not comparable.
--

test:do_catchsql_test(
    "gh-4692-1.1",
    [[
        SELECT true in (true, false, 1);
    ]], {
        1, "Type mismatch: can not convert 1 to boolean"
    })

test:do_catchsql_test(
    "gh-4692-1.2",
    [[
        SELECT X'3132' in (X'31', X'32', 3);
    ]], {
        1, "Type mismatch: can not convert 3 to varbinary"
    })

test:finish_test()

