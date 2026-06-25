#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests (sign-extending shift)
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  sra, 0x80000000, 0x80000000, 0  )
  TEST_RR_OP( 3,  sra, 0xc0000000, 0x80000000, 1  )
  TEST_RR_OP( 4,  sra, 0xff000000, 0x80000000, 7  )
  TEST_RR_OP( 5,  sra, 0xfffe0000, 0x80000000, 14 )
  TEST_RR_OP( 6,  sra, 0xffffffff, 0x80000000, 31 )
  TEST_RR_OP( 7,  sra, 0x7fffffff, 0x7fffffff, 0  )
  TEST_RR_OP( 8,  sra, 0x3fffffff, 0x7fffffff, 1  )
  TEST_RR_OP( 9,  sra, 0x00ffffff, 0x7fffffff, 7  )
  TEST_RR_OP( 10, sra, 0x0001ffff, 0x7fffffff, 14 )
  TEST_RR_OP( 11, sra, 0x00000000, 0x7fffffff, 31 )
  TEST_RR_OP( 12, sra, 0xffffffff, 0xffffffff, 0  )
  TEST_RR_OP( 13, sra, 0xffffffff, 0xffffffff, 1  )
  TEST_RR_OP( 14, sra, 0xffffffff, 0xffffffff, 7  )
  TEST_RR_OP( 15, sra, 0xffffffff, 0xffffffff, 14 )
  TEST_RR_OP( 16, sra, 0xffffffff, 0xffffffff, 31 )
  TEST_RR_OP( 17, sra, 0x21212121, 0x21212121, 0  )
  TEST_RR_OP( 18, sra, 0x10909090, 0x21212121, 1  )
  TEST_RR_OP( 19, sra, 0x00424242, 0x21212121, 7  )
  TEST_RR_OP( 20, sra, 0x00008484, 0x21212121, 14 )
  TEST_RR_OP( 21, sra, 0x00000000, 0x21212121, 31 )
  # Shift amount only uses low 5 bits
  TEST_RR_OP( 22, sra, 0xffffffff, 0x80000000, 0xffffffe0 )
  TEST_RR_OP( 23, sra, 0xc0000000, 0x80000000, 0xffffffe1 )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 24, sra, 0xff000000, 0x80000000, 7 )
  TEST_RR_SRC2_EQ_DEST( 25, sra, 0xc0000000, 0x80000000, 1 )
  TEST_RR_SRC12_EQ_DEST( 26, sra, 0x00000000, 31 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 27, 0, sra, 0xc0000000, 0x80000000, 1 )
  TEST_RR_DEST_BYPASS( 28, 1, sra, 0xe0000000, 0x80000000, 2 )
  TEST_RR_DEST_BYPASS( 29, 2, sra, 0xf0000000, 0x80000000, 3 )

  TEST_RR_SRC12_BYPASS( 30, 0, 0, sra, 0xc0000000, 0x80000000, 1 )
  TEST_RR_SRC12_BYPASS( 31, 0, 1, sra, 0xe0000000, 0x80000000, 2 )
  TEST_RR_SRC12_BYPASS( 32, 0, 2, sra, 0xf0000000, 0x80000000, 3 )
  TEST_RR_SRC12_BYPASS( 33, 1, 0, sra, 0xc0000000, 0x80000000, 1 )
  TEST_RR_SRC12_BYPASS( 34, 1, 1, sra, 0xe0000000, 0x80000000, 2 )
  TEST_RR_SRC12_BYPASS( 35, 2, 0, sra, 0xf0000000, 0x80000000, 3 )

  TEST_RR_SRC21_BYPASS( 36, 0, 0, sra, 0xc0000000, 0x80000000, 1 )
  TEST_RR_SRC21_BYPASS( 37, 0, 1, sra, 0xe0000000, 0x80000000, 2 )
  TEST_RR_SRC21_BYPASS( 38, 0, 2, sra, 0xf0000000, 0x80000000, 3 )

  TEST_RR_ZEROSRC1( 39, sra, 0, 7 )
  TEST_RR_ZEROSRC2( 40, sra, 0x21212121, 0x21212121 )
  TEST_RR_ZEROSRC12( 41, sra, 0 )
  TEST_RR_ZERODEST( 42, sra, 0x21212121, 7 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
