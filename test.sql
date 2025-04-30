-- GROUP BY: Explicit
SELECT
    foo,
    bar,
    sum(baz) AS sum_value
FROM fake_table
GROUP BY
    foo, bar;

-- ORDER BY: Explicit
SELECT
    foo,
    bar
FROM fake_table
ORDER BY
    foo, bar;
-- GROUP BY: Implicit
SELECT
    foo,
    bar,
    sum(baz) AS sum_value
FROM fake_table
GROUP BY
    1, 2;
-- ORDER BY: Implicit
--SELECT
--    foo,
--    bar
--FROM fake_table
--ORDER BY
--    1, 2;
