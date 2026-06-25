#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Logical tests
  #-------------------------------------------------------------

  TEST_IMM_OP( 2,  ori, 0xff00ff00, 0xff00ff00, 0x000 )
  TEST_IMM_OP( 3,  ori, 0x0ff00ff0, 0x0ff00ff0, 0x000 )
  TEST_IMM_OP( 4,  ori, 0x00ff00ff, 0x00ff00ff, 0x000 )
  TEST_IMM_OP( 5,  ori, 0xff00ffff, 0xff00ff00, 0x0ff )
  TEST_IMM_OP( 6,  ori, 0xffffffff, 0xff00ff00, -1   )
  TEST_IMM_OP( 7,  ori, 0xfffff800, 0x00000000, -2048 )
  TEST_IMM_OP( 8,  ori, 0x000007ff, 0x00000000, 2047 )
  TEST_IMM_OP( 9,  ori, 0xffffffff, 0xffffffff, -1   )
  TEST_IMM_OP( 10, ori, 0x00000000, 0x00000000, 0    )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_IMM_SRC1_EQ_DEST( 11, ori, 0xff00ffff, 0xff00ff00, 0x0ff )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_IMM_DEST_BYPASS( 12, 0, ori, 0xff00ffff, 0xff00ff00, 0x0ff )
  TEST_IMM_DEST_BYPASS( 13, 1, ori, 0xff00fffe, 0xff00ff00, 0x0fe )
  TEST_IMM_DEST_BYPASS( 14, 2, ori, 0xff00fffd, 0xff00ff00, 0x0fd )

  TEST_IMM_SRC1_BYPASS( 15, 0, ori, 0xff00ffff, 0xff00ff00, 0x0ff )
  TEST_IMM_SRC1_BYPASS( 16, 1, ori, 0xff00fffe, 0xff00ff00, 0x0fe )
  TEST_IMM_SRC1_BYPASS( 17, 2, ori, 0xff00fffd, 0xff00ff00, 0x0fd )

  TEST_IMM_ZEROSRC1( 18, ori, 0x0ff, 0x0ff )
  TEST_IMM_ZERODEST( 19, ori, 0xff00ff00, 0x0ff )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
