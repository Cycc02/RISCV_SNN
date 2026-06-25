#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  add, 0x00000000, 0x00000000, 0x00000000 )
  TEST_RR_OP( 3,  add, 0x00000002, 0x00000001, 0x00000001 )
  TEST_RR_OP( 4,  add, 0x0000000a, 0x00000003, 0x00000007 )
  TEST_RR_OP( 5,  add, 0xffff8000, 0x00000000, 0xffff8000 )
  TEST_RR_OP( 6,  add, 0x80000000, 0x80000000, 0x00000000 )
  TEST_RR_OP( 7,  add, 0x7fff8000, 0x80000000, 0xffff8000 )
  TEST_RR_OP( 8,  add, 0x00007fff, 0x00000000, 0x00007fff )
  TEST_RR_OP( 9,  add, 0x7fffffff, 0x7fffffff, 0x00000000 )
  TEST_RR_OP( 10, add, 0x80007fff, 0x80000000, 0x00007fff )
  TEST_RR_OP( 11, add, 0xffffffff, 0x00000000, 0xffffffff )
  TEST_RR_OP( 12, add, 0x00000000, 0xffffffff, 0x00000001 )
  TEST_RR_OP( 13, add, 0xfffffffe, 0xffffffff, 0xffffffff )
  TEST_RR_OP( 14, add, 0x80000000, 0x7fffffff, 0x00000001 )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 15, add, 24, 13, 11 )
  TEST_RR_SRC2_EQ_DEST( 16, add, 25, 14, 11 )
  TEST_RR_SRC12_EQ_DEST( 17, add, 26, 13 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 18, 0, add, 24, 13, 11 )
  TEST_RR_DEST_BYPASS( 19, 1, add, 25, 14, 11 )
  TEST_RR_DEST_BYPASS( 20, 2, add, 26, 15, 11 )

  TEST_RR_SRC12_BYPASS( 21, 0, 0, add, 24, 13, 11 )
  TEST_RR_SRC12_BYPASS( 22, 0, 1, add, 25, 14, 11 )
  TEST_RR_SRC12_BYPASS( 23, 0, 2, add, 26, 15, 11 )
  TEST_RR_SRC12_BYPASS( 24, 1, 0, add, 24, 13, 11 )
  TEST_RR_SRC12_BYPASS( 25, 1, 1, add, 25, 14, 11 )
  TEST_RR_SRC12_BYPASS( 26, 2, 0, add, 26, 15, 11 )

  TEST_RR_SRC21_BYPASS( 27, 0, 0, add, 24, 13, 11 )
  TEST_RR_SRC21_BYPASS( 28, 0, 1, add, 25, 14, 11 )
  TEST_RR_SRC21_BYPASS( 29, 0, 2, add, 26, 15, 11 )

  #-------------------------------------------------------------
  # Zero-register tests
  #-------------------------------------------------------------

  TEST_RR_ZEROSRC1( 30, add, 15, 15 )
  TEST_RR_ZEROSRC2( 31, add, 32, 32 )
  TEST_RR_ZEROSRC12( 32, add, 0 )
  TEST_RR_ZERODEST( 33, add, 16, 30 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
