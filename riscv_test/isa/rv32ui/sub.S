#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  sub, 0x00000000, 0x00000000, 0x00000000 )
  TEST_RR_OP( 3,  sub, 0x00000000, 0x00000001, 0x00000001 )
  TEST_RR_OP( 4,  sub, 0xfffffffc, 0x00000003, 0x00000007 )
  TEST_RR_OP( 5,  sub, 0x00008000, 0x00000000, 0xffff8000 )
  TEST_RR_OP( 6,  sub, 0x80000000, 0x80000000, 0x00000000 )
  TEST_RR_OP( 7,  sub, 0x80008000, 0x80000000, 0xffff8000 )
  TEST_RR_OP( 8,  sub, 0xffff8001, 0x00000000, 0x00007fff )
  TEST_RR_OP( 9,  sub, 0x7fffffff, 0x7fffffff, 0x00000000 )
  TEST_RR_OP( 10, sub, 0x7fff8001, 0x80000000, 0x00007fff )
  TEST_RR_OP( 11, sub, 0x00000001, 0x00000000, 0xffffffff )
  TEST_RR_OP( 12, sub, 0xfffffffe, 0xffffffff, 0x00000001 )
  TEST_RR_OP( 13, sub, 0x00000000, 0xffffffff, 0xffffffff )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 14, sub, 0, 13, 13 )
  TEST_RR_SRC2_EQ_DEST( 15, sub, 0, 13, 13 )
  TEST_RR_SRC12_EQ_DEST( 16, sub, 0, 13 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 17, 0, sub, 2, 13, 11 )
  TEST_RR_DEST_BYPASS( 18, 1, sub, 3, 14, 11 )
  TEST_RR_DEST_BYPASS( 19, 2, sub, 4, 15, 11 )

  TEST_RR_SRC12_BYPASS( 20, 0, 0, sub, 2, 13, 11 )
  TEST_RR_SRC12_BYPASS( 21, 0, 1, sub, 3, 14, 11 )
  TEST_RR_SRC12_BYPASS( 22, 0, 2, sub, 4, 15, 11 )
  TEST_RR_SRC12_BYPASS( 23, 1, 0, sub, 2, 13, 11 )
  TEST_RR_SRC12_BYPASS( 24, 1, 1, sub, 3, 14, 11 )
  TEST_RR_SRC12_BYPASS( 25, 2, 0, sub, 4, 15, 11 )

  TEST_RR_SRC21_BYPASS( 26, 0, 0, sub, 2, 13, 11 )
  TEST_RR_SRC21_BYPASS( 27, 0, 1, sub, 3, 14, 11 )
  TEST_RR_SRC21_BYPASS( 28, 0, 2, sub, 4, 15, 11 )

  TEST_RR_ZEROSRC1( 29, sub, 0xfffffff1, 15 )
  TEST_RR_ZEROSRC2( 30, sub, 32, 32 )
  TEST_RR_ZEROSRC12( 31, sub, 0 )
  TEST_RR_ZERODEST( 32, sub, 33, 1 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
