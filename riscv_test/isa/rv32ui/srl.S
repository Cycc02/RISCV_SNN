#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  srl, 0x80000000, 0x80000000, 0  )
  TEST_RR_OP( 3,  srl, 0x40000000, 0x80000000, 1  )
  TEST_RR_OP( 4,  srl, 0x01000000, 0x80000000, 7  )
  TEST_RR_OP( 5,  srl, 0x00020000, 0x80000000, 14 )
  TEST_RR_OP( 6,  srl, 0x00000001, 0x80000000, 31 )
  TEST_RR_OP( 7,  srl, 0xffffffff, 0xffffffff, 0  )
  TEST_RR_OP( 8,  srl, 0x7fffffff, 0xffffffff, 1  )
  TEST_RR_OP( 9,  srl, 0x01ffffff, 0xffffffff, 7  )
  TEST_RR_OP( 10, srl, 0x0003ffff, 0xffffffff, 14 )
  TEST_RR_OP( 11, srl, 0x00000001, 0xffffffff, 31 )
  TEST_RR_OP( 12, srl, 0x21212121, 0x21212121, 0  )
  TEST_RR_OP( 13, srl, 0x10909090, 0x21212121, 1  )
  TEST_RR_OP( 14, srl, 0x00424242, 0x21212121, 7  )
  TEST_RR_OP( 15, srl, 0x00008484, 0x21212121, 14 )
  TEST_RR_OP( 16, srl, 0x00000000, 0x21212121, 31 )
  # Shift amount only uses low 5 bits
  TEST_RR_OP( 17, srl, 0x21212121, 0x21212121, 0xffffffe0 )
  TEST_RR_OP( 18, srl, 0x10909090, 0x21212121, 0xffffffe1 )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 19, srl, 0x01000000, 0x80000000, 7 )
  TEST_RR_SRC2_EQ_DEST( 20, srl, 0x40000000, 0x80000000, 1 )
  TEST_RR_SRC12_EQ_DEST( 21, srl, 0x00000000, 31 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 22, 0, srl, 0x40000000, 0x80000000, 1 )
  TEST_RR_DEST_BYPASS( 23, 1, srl, 0x20000000, 0x80000000, 2 )
  TEST_RR_DEST_BYPASS( 24, 2, srl, 0x10000000, 0x80000000, 3 )

  TEST_RR_SRC12_BYPASS( 25, 0, 0, srl, 0x40000000, 0x80000000, 1 )
  TEST_RR_SRC12_BYPASS( 26, 0, 1, srl, 0x20000000, 0x80000000, 2 )
  TEST_RR_SRC12_BYPASS( 27, 0, 2, srl, 0x10000000, 0x80000000, 3 )
  TEST_RR_SRC12_BYPASS( 28, 1, 0, srl, 0x40000000, 0x80000000, 1 )
  TEST_RR_SRC12_BYPASS( 29, 1, 1, srl, 0x20000000, 0x80000000, 2 )
  TEST_RR_SRC12_BYPASS( 30, 2, 0, srl, 0x10000000, 0x80000000, 3 )

  TEST_RR_SRC21_BYPASS( 31, 0, 0, srl, 0x40000000, 0x80000000, 1 )
  TEST_RR_SRC21_BYPASS( 32, 0, 1, srl, 0x20000000, 0x80000000, 2 )
  TEST_RR_SRC21_BYPASS( 33, 0, 2, srl, 0x10000000, 0x80000000, 3 )

  TEST_RR_ZEROSRC1( 34, srl, 0, 7 )
  TEST_RR_ZEROSRC2( 35, srl, 0x21212121, 0x21212121 )
  TEST_RR_ZEROSRC12( 36, srl, 0 )
  TEST_RR_ZERODEST( 37, srl, 0x21212121, 7 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
