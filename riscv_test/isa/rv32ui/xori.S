#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Logical tests
  #-------------------------------------------------------------

  TEST_IMM_OP( 2,  xori, 0xff00ff00, 0xff00ff00, 0x000 )
  TEST_IMM_OP( 3,  xori, 0x0ff00f00, 0x0ff00ff0, 0x0f0 )
  TEST_IMM_OP( 4,  xori, 0x00ff000f, 0x00ff00ff, 0x0f0 )
  TEST_IMM_OP( 5,  xori, 0xff00ff0f, 0xff00ff00, 0x00f )
  TEST_IMM_OP( 6,  xori, 0x00ff00ff, 0xff00ff00, -1   )
  TEST_IMM_OP( 7,  xori, 0x000007ff, 0xfffff800, -1   )
  TEST_IMM_OP( 8,  xori, 0xfffff800, 0x000007ff, -1   )
  TEST_IMM_OP( 9,  xori, 0xfffff800, 0x00000000, -2048 )
  TEST_IMM_OP( 10, xori, 0x000007ff, 0x00000000, 2047 )
  TEST_IMM_OP( 11, xori, 0x00000000, 0x00000000, 0    )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_IMM_SRC1_EQ_DEST( 12, xori, 0x0ff00f00, 0x0ff00ff0, 0x0f0 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_IMM_DEST_BYPASS( 13, 0, xori, 0x0ff00f00, 0x0ff00ff0, 0x0f0 )
  TEST_IMM_DEST_BYPASS( 14, 1, xori, 0x0ff00f10, 0x0ff00ff0, 0x0e0 )
  TEST_IMM_DEST_BYPASS( 15, 2, xori, 0x0ff00f20, 0x0ff00ff0, 0x0d0 )

  TEST_IMM_SRC1_BYPASS( 16, 0, xori, 0x0ff00f00, 0x0ff00ff0, 0x0f0 )
  TEST_IMM_SRC1_BYPASS( 17, 1, xori, 0x0ff00f10, 0x0ff00ff0, 0x0e0 )
  TEST_IMM_SRC1_BYPASS( 18, 2, xori, 0x0ff00f20, 0x0ff00ff0, 0x0d0 )

  TEST_IMM_ZEROSRC1( 19, xori, 0x0f0, 0x0f0 )
  TEST_IMM_ZERODEST( 20, xori, 0xff00ff00, 0x0f0 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
