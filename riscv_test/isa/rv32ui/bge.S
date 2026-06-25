#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Branch taken tests (signed greater-than-or-equal)
  #-------------------------------------------------------------

  TEST_BR2_OP_TAKEN( 2, bge,  0,  0 )
  TEST_BR2_OP_TAKEN( 3, bge,  1,  1 )
  TEST_BR2_OP_TAKEN( 4, bge, -1, -1 )
  TEST_BR2_OP_TAKEN( 5, bge,  1,  0 )
  TEST_BR2_OP_TAKEN( 6, bge,  1, -1 )
  TEST_BR2_OP_TAKEN( 7, bge, -1, -2 )
  TEST_BR2_OP_TAKEN( 8, bge, 0x7fffffff, 0x80000000 )

  #-------------------------------------------------------------
  # Branch not-taken tests
  #-------------------------------------------------------------

  TEST_BR2_OP_NOTTAKEN(  9, bge,  0,  1 )
  TEST_BR2_OP_NOTTAKEN( 10, bge, -1,  1 )
  TEST_BR2_OP_NOTTAKEN( 11, bge, -2, -1 )
  TEST_BR2_OP_NOTTAKEN( 12, bge, 0x80000000, 0x7fffffff )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_BR2_SRC12_BYPASS( 13, 0, 0, bge, 0, -1 )
  TEST_BR2_SRC12_BYPASS( 14, 0, 1, bge, 0, -1 )
  TEST_BR2_SRC12_BYPASS( 15, 0, 2, bge, 0, -1 )
  TEST_BR2_SRC12_BYPASS( 16, 1, 0, bge, 0, -1 )
  TEST_BR2_SRC12_BYPASS( 17, 1, 1, bge, 0, -1 )
  TEST_BR2_SRC12_BYPASS( 18, 2, 0, bge, 0, -1 )

  TEST_BR2_SRC21_BYPASS( 19, 0, 0, bge, 0, -1 )
  TEST_BR2_SRC21_BYPASS( 20, 0, 1, bge, 0, -1 )
  TEST_BR2_SRC21_BYPASS( 21, 0, 2, bge, 0, -1 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
