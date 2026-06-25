#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Logical tests
  #-------------------------------------------------------------

  TEST_IMM_OP( 2,  andi, 0xff00ff00, 0xff00ff00, -256 )
  TEST_IMM_OP( 3,  andi, 0x00000f00, 0x0ff00ff0, 0x0f0 )
  TEST_IMM_OP( 4,  andi, 0x000000f0, 0x00ff00ff, 0x0f0 )
  TEST_IMM_OP( 5,  andi, 0x00000000, 0xff00ff00, 0x00f )
  TEST_IMM_OP( 6,  andi, 0x00000000, 0x00000000, -1  )
  TEST_IMM_OP( 7,  andi, 0x00000700, 0x00000fff, 0x700 )
  TEST_IMM_OP( 8,  andi, 0xfffff800, 0xffffffff, -2048 )
  TEST_IMM_OP( 9,  andi, 0x000007ff, 0xffffffff, 2047 )
  TEST_IMM_OP( 10, andi, 0x00000000, 0xffffffff, 0 )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_IMM_SRC1_EQ_DEST( 11, andi, 0x00000f00, 0x0ff00ff0, 0x0f0 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_IMM_DEST_BYPASS( 12, 0, andi, 0x00000700, 0x00000fff, 0x700 )
  TEST_IMM_DEST_BYPASS( 13, 1, andi, 0x00000600, 0x00000fff, 0x600 )
  TEST_IMM_DEST_BYPASS( 14, 2, andi, 0x00000500, 0x00000fff, 0x500 )

  TEST_IMM_SRC1_BYPASS( 15, 0, andi, 0x00000700, 0x00000fff, 0x700 )
  TEST_IMM_SRC1_BYPASS( 16, 1, andi, 0x00000600, 0x00000fff, 0x600 )
  TEST_IMM_SRC1_BYPASS( 17, 2, andi, 0x00000500, 0x00000fff, 0x500 )

  TEST_IMM_ZEROSRC1( 18, andi, 0, -1 )
  TEST_IMM_ZERODEST( 19, andi, 0x0ff00ff0, 0x0f0 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
