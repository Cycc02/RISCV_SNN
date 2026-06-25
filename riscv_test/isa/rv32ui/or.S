#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Logical tests
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  or, 0xff00ff00, 0xff00ff00, 0x00000000 )
  TEST_RR_OP( 3,  or, 0xfff0fff0, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_OP( 4,  or, 0x0fff0fff, 0x00ff00ff, 0x0f0f0f0f )
  TEST_RR_OP( 5,  or, 0xffffffff, 0xff00ff00, 0x00ff00ff )
  TEST_RR_OP( 6,  or, 0xffffffff, 0x00000000, 0xffffffff )
  TEST_RR_OP( 7,  or, 0xffffffff, 0xffffffff, 0xffffffff )
  TEST_RR_OP( 8,  or, 0x00000000, 0x00000000, 0x00000000 )
  TEST_RR_OP( 9,  or, 0xffffffff, 0x0000000f, 0xffffffff )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 10, or, 0xfff0fff0, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_SRC2_EQ_DEST( 11, or, 0x0fff0fff, 0x00ff00ff, 0x0f0f0f0f )
  TEST_RR_SRC12_EQ_DEST( 12, or, 0xff00ff00, 0xff00ff00 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 13, 0, or, 0xff00ff00, 0xff00ff00, 0x00000000 )
  TEST_RR_DEST_BYPASS( 14, 1, or, 0xfff0fff0, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_DEST_BYPASS( 15, 2, or, 0x0fff0fff, 0x00ff00ff, 0x0f0f0f0f )

  TEST_RR_SRC12_BYPASS( 16, 0, 0, or, 0xff00ff00, 0xff00ff00, 0x00000000 )
  TEST_RR_SRC12_BYPASS( 17, 0, 1, or, 0xfff0fff0, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_SRC12_BYPASS( 18, 0, 2, or, 0x0fff0fff, 0x00ff00ff, 0x0f0f0f0f )
  TEST_RR_SRC12_BYPASS( 19, 1, 0, or, 0xff00ff00, 0xff00ff00, 0x00000000 )
  TEST_RR_SRC12_BYPASS( 20, 1, 1, or, 0xfff0fff0, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_SRC12_BYPASS( 21, 2, 0, or, 0x0fff0fff, 0x00ff00ff, 0x0f0f0f0f )

  TEST_RR_SRC21_BYPASS( 22, 0, 0, or, 0xff00ff00, 0xff00ff00, 0x00000000 )
  TEST_RR_SRC21_BYPASS( 23, 0, 1, or, 0xfff0fff0, 0x0ff00ff0, 0xf0f0f0f0 )
  TEST_RR_SRC21_BYPASS( 24, 0, 2, or, 0x0fff0fff, 0x00ff00ff, 0x0f0f0f0f )

  TEST_RR_ZEROSRC1( 25, or, 0xff00ff00, 0xff00ff00 )
  TEST_RR_ZEROSRC2( 26, or, 0xff00ff00, 0xff00ff00 )
  TEST_RR_ZEROSRC12( 27, or, 0 )
  TEST_RR_ZERODEST( 28, or, 0xff00ff00, 0x00ff00ff )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
