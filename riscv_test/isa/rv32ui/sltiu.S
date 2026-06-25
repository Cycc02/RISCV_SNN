#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests (unsigned compare with sign-extended immediate)
  #-------------------------------------------------------------

  TEST_IMM_OP( 2,  sltiu, 0, 0x00000000,    0 )
  TEST_IMM_OP( 3,  sltiu, 1, 0x00000000,    1 )
  TEST_IMM_OP( 4,  sltiu, 0, 0x00000001,    1 )
  TEST_IMM_OP( 5,  sltiu, 0, 0xffffffff,    1 )
  TEST_IMM_OP( 6,  sltiu, 1, 0x00000001, 0xfff )
  # -1 sign-extends to 0xffffffff, so 0x7fffffff < 0xffffffff
  TEST_IMM_OP( 7,  sltiu, 1, 0x00000000,   -1  )
  TEST_IMM_OP( 8,  sltiu, 0, 0x80000000,   -1  )
  TEST_IMM_OP( 9,  sltiu, 0, 0xffffffff,   -1  )
  TEST_IMM_OP( 10, sltiu, 1, 0x7fffffff,   -1  )
  TEST_IMM_OP( 11, sltiu, 1, 0x00000000, 2047   )
  TEST_IMM_OP( 12, sltiu, 0, 0xffffffff, 2047   )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_IMM_SRC1_EQ_DEST( 13, sltiu, 1, 11, 13 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_IMM_DEST_BYPASS( 14, 0, sltiu, 1, 11, 13 )
  TEST_IMM_DEST_BYPASS( 15, 1, sltiu, 1, 11, 14 )
  TEST_IMM_DEST_BYPASS( 16, 2, sltiu, 1, 11, 15 )

  TEST_IMM_SRC1_BYPASS( 17, 0, sltiu, 1, 11, 13 )
  TEST_IMM_SRC1_BYPASS( 18, 1, sltiu, 1, 11, 14 )
  TEST_IMM_SRC1_BYPASS( 19, 2, sltiu, 1, 11, 15 )

  TEST_IMM_ZEROSRC1( 20, sltiu, 1, 1 )
  TEST_IMM_ZERODEST( 21, sltiu, 0, 1 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
