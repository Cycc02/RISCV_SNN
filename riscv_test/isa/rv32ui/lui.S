#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # LUI tests
  #-------------------------------------------------------------

  TEST_CASE( 2, x1, 0x00000000, lui x1, 0x00000 )
  TEST_CASE( 3, x1, 0x000d0000, lui x1, 0x000d0 )
  TEST_CASE( 4, x1, 0xfffff000, lui x1, 0xfffff )
  TEST_CASE( 5, x1, 0x7ffff000, lui x1, 0x7ffff )
  TEST_CASE( 6, x1, 0x80000000, lui x1, 0x80000 )
  TEST_CASE( 7, x1, 0xabcde000, lui x1, 0xabcde )
  TEST_CASE( 8, x1, 0x00001000, lui x1, 0x00001 )
  TEST_CASE( 9, x1, 0xfffff000, lui x1, 0xfffff )

  # Writing to x0 should give 0
  TEST_CASE( 10, x0, 0x00000000, lui x0, 0xfffff )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
