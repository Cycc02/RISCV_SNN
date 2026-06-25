#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Logical tests
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  xor, 0x00000000, 0xff00ff00, 0xff00ff00 )
  TEST_RR_OP( 3,  xor, 0xff000000, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_OP( 4,  xor, 0x0f0f0f0f, 0x00ff00ff, 0x0f0f0f0f )
  TEST_RR_OP( 5,  xor, 0xffffffff, 0xff00ff00, 0x00ff00ff )
  TEST_RR_OP( 6,  xor, 0xffffffff, 0x00000000, 0xffffffff )
  TEST_RR_OP( 7,  xor, 0x00000000, 0xffffffff, 0xffffffff )
  TEST_RR_OP( 8,  xor, 0x00000000, 0x00000000, 0x00000000 )
  TEST_RR_OP( 9,  xor, 0xfffffff0, 0x0000000f, 0xffffffff )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 10, xor, 0xff000000, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_SRC2_EQ_DEST( 11, xor, 0x0f0f0f0f, 0x00ff00ff, 0x0f0f0f0f )
  TEST_RR_SRC12_EQ_DEST( 12, xor, 0x00000000, 0xff00ff00 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 13, 0, xor, 0x00000000, 0xff00ff00, 0xff00ff00 )
  TEST_RR_DEST_BYPASS( 14, 1, xor, 0xff000000, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_DEST_BYPASS( 15, 2, xor, 0x0f0f0f0f, 0x00ff00ff, 0x0f0f0f0f )

  TEST_RR_SRC12_BYPASS( 16, 0, 0, xor, 0x00000000, 0xff00ff00, 0xff00ff00 )
  TEST_RR_SRC12_BYPASS( 17, 0, 1, xor, 0xff000000, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_SRC12_BYPASS( 18, 0, 2, xor, 0x0f0f0f0f, 0x00ff00ff, 0x0f0f0f0f )
  TEST_RR_SRC12_BYPASS( 19, 1, 0, xor, 0x00000000, 0xff00ff00, 0xff00ff00 )
  TEST_RR_SRC12_BYPASS( 20, 1, 1, xor, 0xff000000, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_SRC12_BYPASS( 21, 2, 0, xor, 0x0f0f0f0f, 0x00ff00ff, 0x0f0f0f0f )

  TEST_RR_SRC21_BYPASS( 22, 0, 0, xor, 0x00000000, 0xff00ff00, 0xff00ff00 )
  TEST_RR_SRC21_BYPASS( 23, 0, 1, xor, 0xff000000, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_SRC21_BYPASS( 24, 0, 2, xor, 0x0f0f0f0f, 0x00ff00ff, 0x0f0f0f0f )

  TEST_RR_ZEROSRC1( 25, xor, 0xff00ff00, 0xff00ff00 )
  TEST_RR_ZEROSRC2( 26, xor, 0xff00ff00, 0xff00ff00 )
  TEST_RR_ZEROSRC12( 27, xor, 0 )
  TEST_RR_ZERODEST( 28, xor, 0xff00ff00, 0x00ff00ff )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
