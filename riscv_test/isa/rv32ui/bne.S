#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Branch taken tests
  #-------------------------------------------------------------

  TEST_BR2_OP_TAKEN( 2, bne,  0,  1 )
  TEST_BR2_OP_TAKEN( 3, bne,  1,  0 )
  TEST_BR2_OP_TAKEN( 4, bne, -1,  1 )
  TEST_BR2_OP_TAKEN( 5, bne,  1, -1 )

  #-------------------------------------------------------------
  # Branch not-taken tests
  #-------------------------------------------------------------

  TEST_BR2_OP_NOTTAKEN( 6,  bne,  0,  0 )
  TEST_BR2_OP_NOTTAKEN( 7,  bne,  1,  1 )
  TEST_BR2_OP_NOTTAKEN( 8,  bne, -1, -1 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_BR2_SRC12_BYPASS( 9,  0, 0, bne, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 10, 0, 1, bne, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 11, 0, 2, bne, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 12, 1, 0, bne, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 13, 1, 1, bne, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 14, 2, 0, bne, 0, 1 )

  TEST_BR2_SRC21_BYPASS( 15, 0, 0, bne, 0, 1 )
  TEST_BR2_SRC21_BYPASS( 16, 0, 1, bne, 0, 1 )
  TEST_BR2_SRC21_BYPASS( 17, 0, 2, bne, 0, 1 )

  #-------------------------------------------------------------
  # Test backwards branch
  #-------------------------------------------------------------

  TEST_CASE( 18, x3, 8,
    li  x3, 0;
    li  x4, 4;
1:  addi x3, x3, 4;
    bne  x3, x4, 2f;
    addi x3, x3, 4;
    j    3f;
2:  bne  x3, x4, 1b;
3:  addi x3, x3, 4
  )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
