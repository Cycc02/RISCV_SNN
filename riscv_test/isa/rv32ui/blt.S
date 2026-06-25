#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Branch taken tests (signed less-than)
  #-------------------------------------------------------------

  TEST_BR2_OP_TAKEN( 2, blt,  0,  1 )
  TEST_BR2_OP_TAKEN( 3, blt, -1,  1 )
  TEST_BR2_OP_TAKEN( 4, blt, -2, -1 )
  TEST_BR2_OP_TAKEN( 5, blt, 0x80000000, 0x7fffffff )

  #-------------------------------------------------------------
  # Branch not-taken tests
  #-------------------------------------------------------------

  TEST_BR2_OP_NOTTAKEN(  6, blt,  0,  0 )
  TEST_BR2_OP_NOTTAKEN(  7, blt,  1,  0 )
  TEST_BR2_OP_NOTTAKEN(  8, blt,  1, -1 )
  TEST_BR2_OP_NOTTAKEN(  9, blt, -1, -2 )
  TEST_BR2_OP_NOTTAKEN( 10, blt, 0x7fffffff, 0x80000000 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_BR2_SRC12_BYPASS( 11, 0, 0, blt, -1, 0 )
  TEST_BR2_SRC12_BYPASS( 12, 0, 1, blt, -1, 0 )
  TEST_BR2_SRC12_BYPASS( 13, 0, 2, blt, -1, 0 )
  TEST_BR2_SRC12_BYPASS( 14, 1, 0, blt, -1, 0 )
  TEST_BR2_SRC12_BYPASS( 15, 1, 1, blt, -1, 0 )
  TEST_BR2_SRC12_BYPASS( 16, 2, 0, blt, -1, 0 )

  TEST_BR2_SRC21_BYPASS( 17, 0, 0, blt, -1, 0 )
  TEST_BR2_SRC21_BYPASS( 18, 0, 1, blt, -1, 0 )
  TEST_BR2_SRC21_BYPASS( 19, 0, 2, blt, -1, 0 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
