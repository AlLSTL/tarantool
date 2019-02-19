test_run = require('test_run').new()
engine = test_run:get_cfg('engine')
box.sql.execute('pragma sql_default_engine=\''..engine..'\'')

-- gh-3735: make sure that integer overflows errors are
-- handled during VDBE execution.
--
box.sql.execute('SELECT (2147483647 * 2147483647 * 2147483647);')
box.sql.execute('SELECT (-9223372036854775808 / -1);')
box.sql.execute('SELECT (-9223372036854775808 - 1);')
box.sql.execute('SELECT (9223372036854775807 + 1);')
-- Literals are checked right after parsing.
--
box.sql.execute('SELECT 9223372036854775808;')
box.sql.execute('SELECT -9223372036854775809;')
box.sql.execute('SELECT 9223372036854775808 - 1;')
-- Test that CAST may also leads to overflow.
--
box.sql.execute('SELECT CAST(\'9223372036854775808\' AS INTEGER);')
-- Due to inexact represantation of large integers in terms of
-- floating point numbers, numerics with value < INT64_MAX
-- have INT64_MAX + 1 value in integer representation:
-- float 9223372036854775800 -> int (9223372036854775808),
-- with error due to conversion = 8.
--
box.sql.execute('SELECT CAST(9223372036854775807.0 AS INTEGER);')