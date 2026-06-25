#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_IMM_OP( 2,  addi, 0x00000000, 0x00000000,   0  )
  TEST_IMM_OP( 3,  addi, 0x00000002, 0x00000001,   1  )
  TEST_IMM_OP( 4,  addi, 0x0000000a, 0x00000003,   7  )
  TEST_IMM_OP( 5,  addi, 0xfffff800, 0x00000000, -2048 )
  TEST_IMM_OP( 6,  addi, 0x000007ff, 0x00000000,  2047 )
  TEST_IMM_OP( 7,  addi, 0xffffffff, 0x00000000,  -1  )
  TEST_IMM_OP( 8,  addi, 0x00000000, 0xffffffff,   1  )
  TEST_IMM_OP( 9,  addi, 0x7ffffffe, 0x7fffffff,  -1  )
  TEST_IMM_OP( 10, addi, 0x80000000, 0x7fffffff,   1  )
  TEST_IMM_OP( 11, addi, 0x7fffffff, 0x80000000,  -1  )
  TEST_IMM_OP( 12, addi, 0x80000001, 0x80000000,   1  )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_IMM_SRC1_EQ_DEST( 13, addi, 24, 13, 11 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_IMM_DEST_BYPASS( 14, 0, addi, 24, 13, 11 )
  TEST_IMM_DEST_BYPASS( 15, 1, addi, 23, 13, 10 )
  TEST_IMM_DEST_BYPASS( 16, 2, addi, 22, 13,  9 )

  TEST_IMM_SRC1_BYPASS( 17, 0, addi, 24, 13, 11 )
  TEST_IMM_SRC1_BYPASS( 18, 1, addi, 23, 13, 10 )
  TEST_IMM_SRC1_BYPASS( 19, 2, addi, 22, 13,  9 )

  #-------------------------------------------------------------
  # Zero-result tests
  #-------------------------------------------------------------

  TEST_IMM_ZEROSRC1( 20, addi, 32, 32 )
  TEST_IMM_ZERODEST( 21, addi, 50, -17 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
