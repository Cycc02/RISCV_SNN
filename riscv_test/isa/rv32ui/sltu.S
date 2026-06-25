#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests (unsigned compare)
  #-------------------------------------------------------------

  TEST_RR_OP( 2,  sltu, 0, 0x00000000, 0x00000000 )
  TEST_RR_OP( 3,  sltu, 1, 0x00000001, 0x00000002 )
  TEST_RR_OP( 4,  sltu, 0, 0x00000002, 0x00000001 )
  TEST_RR_OP( 5,  sltu, 0, 0xffffffff, 0x00000001 )
  TEST_RR_OP( 6,  sltu, 1, 0x00000001, 0xffffffff )
  TEST_RR_OP( 7,  sltu, 0, 0x80000000, 0x7fffffff )
  TEST_RR_OP( 8,  sltu, 1, 0x7fffffff, 0x80000000 )
  TEST_RR_OP( 9,  sltu, 1, 0x00000000, 0x80000000 )
  TEST_RR_OP( 10, sltu, 0, 0x80000000, 0x00000000 )
  TEST_RR_OP( 11, sltu, 0, 0x00000000, 0x00000000 )
  TEST_RR_OP( 12, sltu, 0, 0xffffffff, 0xffffffff )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 13, sltu, 0, 14, 13 )
  TEST_RR_SRC2_EQ_DEST( 14, sltu, 1, 11, 13 )
  TEST_RR_SRC12_EQ_DEST( 15, sltu, 0, 13 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 16, 0, sltu, 1, 11, 13 )
  TEST_RR_DEST_BYPASS( 17, 1, sltu, 1, 11, 14 )
  TEST_RR_DEST_BYPASS( 18, 2, sltu, 1, 11, 15 )

  TEST_RR_SRC12_BYPASS( 19, 0, 0, sltu, 1, 11, 13 )
  TEST_RR_SRC12_BYPASS( 20, 0, 1, sltu, 1, 11, 14 )
  TEST_RR_SRC12_BYPASS( 21, 0, 2, sltu, 1, 11, 15 )
  TEST_RR_SRC12_BYPASS( 22, 1, 0, sltu, 1, 11, 13 )
  TEST_RR_SRC12_BYPASS( 23, 1, 1, sltu, 1, 11, 14 )
  TEST_RR_SRC12_BYPASS( 24, 2, 0, sltu, 1, 11, 15 )

  TEST_RR_SRC21_BYPASS( 25, 0, 0, sltu, 1, 11, 13 )
  TEST_RR_SRC21_BYPASS( 26, 0, 1, sltu, 1, 11, 14 )
  TEST_RR_SRC21_BYPASS( 27, 0, 2, sltu, 1, 11, 15 )

  TEST_RR_ZEROSRC1( 28, sltu, 1, 1 )
  TEST_RR_ZEROSRC2( 29, sltu, 0, 32 )
  TEST_RR_ZEROSRC12( 30, sltu, 0 )
  TEST_RR_ZERODEST( 31, sltu, 11, 13 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
