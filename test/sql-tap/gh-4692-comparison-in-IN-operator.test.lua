#!/usr/bin/env tarantool
test = require("sqltester")
test:plan(11)

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

test:do_catchsql_test(
    "gh-4692-2.1",
    [[
        SELECT true IN (SELECT X'31');
    ]], {
        1, "Type mismatch: can not convert varbinary to boolean"
    })

test:do_catchsql_test(
    "gh-4692-2.2",
    [[
        SELECT X'31' IN (SELECT true);
    ]], {
        1, "Type mismatch: can not convert boolean to varbinary"
    })

test:do_catchsql_test(
    "gh-4692-2.3",
    [[
        SELECT (1, 'a') IN (SELECT 1, 2);
    ]], {
        1, "Type mismatch: can not convert integer to string"
    })

test:do_catchsql_test(
    "gh-4692-2.4",
    [[
        SELECT (SELECT 1, 'a') IN (SELECT 1, 2);
    ]], {
        1, "Type mismatch: can not convert integer to string"
    })

test:execsql([[
        CREATE TABLE t (i INT PRIMARY KEY, a BOOLEAN, b VARBINARY);
        INSERT INTO t VALUES(1, true, X'31');
    ]])

test:do_catchsql_test(
    "gh-4692-2.5",
    [[
        SELECT true IN (SELECT b FROM t);
    ]], {
        1, "Type mismatch: can not convert varbinary to boolean"
    })

test:do_catchsql_test(
    "gh-4692-2.6",
    [[
        SELECT X'31' IN (SELECT a FROM t);
    ]], {
        1, "Type mismatch: can not convert boolean to varbinary"
    })

test:do_catchsql_test(
    "gh-4692-2.7",
    [[
        SELECT (1, 'a') IN (SELECT i, a from t);
    ]], {
        1, "Type mismatch: can not convert boolean to string"
    })

test:do_catchsql_test(
    "gh-4692-2.8",
    [[
        SELECT (SELECT 1, 'a') IN (SELECT i, a from t);
    ]], {
        1, "Type mismatch: can not convert boolean to string"
    })

test:do_catchsql_test(
    "gh-4692-2.9",
    [[
        SELECT (SELECT i, a from t) IN (SELECT a, i from t);
    ]], {
        1, "Type mismatch: can not convert boolean to integer"
    })

test:finish_test()

