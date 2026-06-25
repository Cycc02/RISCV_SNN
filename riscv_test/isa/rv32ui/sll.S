#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  sll, 0x00000001, 0x00000001, 0  )
  TEST_RR_OP( 3,  sll, 0x00000002, 0x00000001, 1  )
  TEST_RR_OP( 4,  sll, 0x00000080, 0x00000001, 7  )
  TEST_RR_OP( 5,  sll, 0x00004000, 0x00000001, 14 )
  TEST_RR_OP( 6,  sll, 0x80000000, 0x00000001, 31 )
  TEST_RR_OP( 7,  sll, 0xffffffff, 0xffffffff, 0  )
  TEST_RR_OP( 8,  sll, 0xfffffffe, 0xffffffff, 1  )
  TEST_RR_OP( 9,  sll, 0xffffff80, 0xffffffff, 7  )
  TEST_RR_OP( 10, sll, 0xffffc000, 0xffffffff, 14 )
  TEST_RR_OP( 11, sll, 0x80000000, 0xffffffff, 31 )
  TEST_RR_OP( 12, sll, 0x21212121, 0x21212121, 0  )
  TEST_RR_OP( 13, sll, 0x42424242, 0x21212121, 1  )
  TEST_RR_OP( 14, sll, 0x90909080, 0x21212121, 7  )
  TEST_RR_OP( 15, sll, 0x48484000, 0x21212121, 14 )
  TEST_RR_OP( 16, sll, 0x80000000, 0x21212121, 31 )
  # Shift amount only uses low 5 bits
  TEST_RR_OP( 17, sll, 0x21212121, 0x21212121, 0xffffffe0 )
  TEST_RR_OP( 18, sll, 0x42424242, 0x21212121, 0xffffffe1 )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 19, sll, 0x00000080, 0x00000001, 7 )
  TEST_RR_SRC2_EQ_DEST( 20, sll, 0x00000002, 0x00000001, 1 )
  TEST_RR_SRC12_EQ_DEST( 21, sll, 0x00000000, 0 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 22, 0, sll, 0x00000002, 0x00000001, 1 )
  TEST_RR_DEST_BYPASS( 23, 1, sll, 0x00000004, 0x00000001, 2 )
  TEST_RR_DEST_BYPASS( 24, 2, sll, 0x00000008, 0x00000001, 3 )

  TEST_RR_SRC12_BYPASS( 25, 0, 0, sll, 0x00000002, 0x00000001, 1 )
  TEST_RR_SRC12_BYPASS( 26, 0, 1, sll, 0x00000004, 0x00000001, 2 )
  TEST_RR_SRC12_BYPASS( 27, 0, 2, sll, 0x00000008, 0x00000001, 3 )
  TEST_RR_SRC12_BYPASS( 28, 1, 0, sll, 0x00000002, 0x00000001, 1 )
  TEST_RR_SRC12_BYPASS( 29, 1, 1, sll, 0x00000004, 0x00000001, 2 )
  TEST_RR_SRC12_BYPASS( 30, 2, 0, sll, 0x00000008, 0x00000001, 3 )

  TEST_RR_SRC21_BYPASS( 31, 0, 0, sll, 0x00000002, 0x00000001, 1 )
  TEST_RR_SRC21_BYPASS( 32, 0, 1, sll, 0x00000004, 0x00000001, 2 )
  TEST_RR_SRC21_BYPASS( 33, 0, 2, sll, 0x00000008, 0x00000001, 3 )

  TEST_RR_ZEROSRC1( 34, sll, 0, 7 )
  TEST_RR_ZEROSRC2( 35, sll, 0x21212121, 0x21212121 )
  TEST_RR_ZEROSRC12( 36, sll, 0 )
  TEST_RR_ZERODEST( 37, sll, 0x21212121, 7 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
