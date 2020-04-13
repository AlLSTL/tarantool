#!/usr/bin/env tarantool
test = require("sqltester")
test:plan(2)

--
-- gh-4679: Make sure that boolean precedes any number within
-- scalar. Result with order by indexed (using index) and
-- non-indexed (using no index) must be the same.
--
test:execsql [[
    CREATE TABLE test (s1 INTEGER PRIMARY KEY, s2 SCALAR UNIQUE, s3 SCALAR);
    INSERT INTO test VALUES (0, 1, 1);
    INSERT INTO test VALUES (1, 1.1, 1.1);
    INSERT INTO test VALUES (2, true, true);
]]

test:do_execsql_test(
    "scalar-bug-1.0",
    [[
        SELECT s2, typeof(s2) FROM test ORDER BY s2;
    ]], {
        -- <scalar-bug-1.0>
        true,"boolean",1,"integer",1.1,"double"
    })

test:do_execsql_test(
    "scalar-bug-2.0",
    [[
        SELECT s3, typeof(s3) FROM test ORDER BY s3;
    ]], {
        -- <scalar-bug-2.0>
        true,"boolean",1,"integer",1.1,"double"
    })

test:finish_test()
