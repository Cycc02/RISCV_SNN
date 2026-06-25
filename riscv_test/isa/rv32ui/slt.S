#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  slt, 0, 0x00000000, 0x00000000 )
  TEST_RR_OP( 3,  slt, 1, 0x00000001, 0x00000002 )
  TEST_RR_OP( 4,  slt, 0, 0x00000002, 0x00000001 )
  TEST_RR_OP( 5,  slt, 1, 0xffffffff, 0x00000001 )
  TEST_RR_OP( 6,  slt, 0, 0x00000001, 0xffffffff )
  TEST_RR_OP( 7,  slt, 1, 0x80000000, 0x7fffffff )
  TEST_RR_OP( 8,  slt, 0, 0x7fffffff, 0x80000000 )
  TEST_RR_OP( 9,  slt, 0, 0x00000000, 0x80000000 )
  TEST_RR_OP( 10, slt, 1, 0x80000000, 0x00000000 )
  TEST_RR_OP( 11, slt, 0, 0x00000000, 0x00000000 )
  TEST_RR_OP( 12, slt, 0, 0xffffffff, 0xffffffff )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 13, slt, 0, 14, 13 )
  TEST_RR_SRC2_EQ_DEST( 14, slt, 1, 11, 13 )
  TEST_RR_SRC12_EQ_DEST( 15, slt, 0, 13 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 16, 0, slt, 1, 11, 13 )
  TEST_RR_DEST_BYPASS( 17, 1, slt, 1, 11, 14 )
  TEST_RR_DEST_BYPASS( 18, 2, slt, 1, 11, 15 )

  TEST_RR_SRC12_BYPASS( 19, 0, 0, slt, 1, 11, 13 )
  TEST_RR_SRC12_BYPASS( 20, 0, 1, slt, 1, 11, 14 )
  TEST_RR_SRC12_BYPASS( 21, 0, 2, slt, 1, 11, 15 )
  TEST_RR_SRC12_BYPASS( 22, 1, 0, slt, 1, 11, 13 )
  TEST_RR_SRC12_BYPASS( 23, 1, 1, slt, 1, 11, 14 )
  TEST_RR_SRC12_BYPASS( 24, 2, 0, slt, 1, 11, 15 )

  TEST_RR_SRC21_BYPASS( 25, 0, 0, slt, 1, 11, 13 )
  TEST_RR_SRC21_BYPASS( 26, 0, 1, slt, 1, 11, 14 )
  TEST_RR_SRC21_BYPASS( 27, 0, 2, slt, 1, 11, 15 )

  TEST_RR_ZEROSRC1( 28, slt, 0, 0 )
  TEST_RR_ZEROSRC2( 29, slt, 0, 0 )
  TEST_RR_ZEROSRC12( 30, slt, 0 )
  TEST_RR_ZERODEST( 31, slt, 11, 13 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
