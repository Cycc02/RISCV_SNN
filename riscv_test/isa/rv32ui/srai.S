#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests (sign-extending shift)
  #-------------------------------------------------------------

  TEST_IMM_OP( 2,  srai, 0x80000000, 0x80000000,  0 )
  TEST_IMM_OP( 3,  srai, 0xc0000000, 0x80000000,  1 )
  TEST_IMM_OP( 4,  srai, 0xff000000, 0x80000000,  7 )
  TEST_IMM_OP( 5,  srai, 0xfffe0000, 0x80000000, 14 )
  TEST_IMM_OP( 6,  srai, 0xffffffff, 0x80000000, 31 )
  TEST_IMM_OP( 7,  srai, 0x7fffffff, 0x7fffffff,  0 )
  TEST_IMM_OP( 8,  srai, 0x3fffffff, 0x7fffffff,  1 )
  TEST_IMM_OP( 9,  srai, 0x00ffffff, 0x7fffffff,  7 )
  TEST_IMM_OP( 10, srai, 0x0001ffff, 0x7fffffff, 14 )
  TEST_IMM_OP( 11, srai, 0x00000000, 0x7fffffff, 31 )
  TEST_IMM_OP( 12, srai, 0xffffffff, 0xffffffff,  0 )
  TEST_IMM_OP( 13, srai, 0xffffffff, 0xffffffff,  1 )
  TEST_IMM_OP( 14, srai, 0xffffffff, 0xffffffff,  7 )
  TEST_IMM_OP( 15, srai, 0xffffffff, 0xffffffff, 14 )
  TEST_IMM_OP( 16, srai, 0xffffffff, 0xffffffff, 31 )
  TEST_IMM_OP( 17, srai, 0x21212121, 0x21212121,  0 )
  TEST_IMM_OP( 18, srai, 0x10909090, 0x21212121,  1 )
  TEST_IMM_OP( 19, srai, 0x00424242, 0x21212121,  7 )
  TEST_IMM_OP( 20, srai, 0x00008484, 0x21212121, 14 )
  TEST_IMM_OP( 21, srai, 0x00000000, 0x21212121, 31 )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_IMM_SRC1_EQ_DEST( 22, srai, 0xff000000, 0x80000000, 7 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_IMM_DEST_BYPASS( 23, 0, srai, 0xc0000000, 0x80000000, 1 )
  TEST_IMM_DEST_BYPASS( 24, 1, srai, 0xe0000000, 0x80000000, 2 )
  TEST_IMM_DEST_BYPASS( 25, 2, srai, 0xf0000000, 0x80000000, 3 )

  TEST_IMM_SRC1_BYPASS( 26, 0, srai, 0xc0000000, 0x80000000, 1 )
  TEST_IMM_SRC1_BYPASS( 27, 1, srai, 0xe0000000, 0x80000000, 2 )
  TEST_IMM_SRC1_BYPASS( 28, 2, srai, 0xf0000000, 0x80000000, 3 )

  TEST_IMM_ZEROSRC1( 29, srai, 0, 7 )
  TEST_IMM_ZERODEST( 30, srai, 0x80000000, 0 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
