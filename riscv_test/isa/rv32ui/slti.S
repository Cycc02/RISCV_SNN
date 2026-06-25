#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_IMM_OP( 2,  slti, 0, 0x00000000,    0 )
  TEST_IMM_OP( 3,  slti, 1, 0x00000000,    1 )
  TEST_IMM_OP( 4,  slti, 0, 0x00000001,    1 )
  TEST_IMM_OP( 5,  slti, 1, 0xfffffffe,    0 )
  TEST_IMM_OP( 6,  slti, 0, 0x00000000,   -1 )
  TEST_IMM_OP( 7,  slti, 1, 0x80000000,    0 )
  TEST_IMM_OP( 8,  slti, 0, 0x7fffffff,    0 )
  TEST_IMM_OP( 9,  slti, 0, 0x7fffffff,  -1  )
  TEST_IMM_OP( 10, slti, 1, 0x80000000, -1   )
  TEST_IMM_OP( 11, slti, 1, 0x80000000, 2047 )
  TEST_IMM_OP( 12, slti, 0, 0x7fffffff, -2048 )

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_IMM_SRC1_EQ_DEST( 13, slti, 1, 11, 13 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_IMM_DEST_BYPASS( 14, 0, slti, 1, 11, 13 )
  TEST_IMM_DEST_BYPASS( 15, 1, slti, 1, 11, 14 )
  TEST_IMM_DEST_BYPASS( 16, 2, slti, 1, 11, 15 )

  TEST_IMM_SRC1_BYPASS( 17, 0, slti, 1, 11, 13 )
  TEST_IMM_SRC1_BYPASS( 18, 1, slti, 1, 11, 14 )
  TEST_IMM_SRC1_BYPASS( 19, 2, slti, 1, 11, 15 )

  TEST_IMM_ZEROSRC1( 20, slti, 0, 0 )
  TEST_IMM_ZERODEST( 21, slti, 0, 1 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
