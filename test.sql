SELECT
   col_a
   , col_b
   -- Newline present before column
   , col_c
   -- When inline, comma should still touch element before.
   , GREATEST(col_d, col_e) as col_f
FROM tbl_a
