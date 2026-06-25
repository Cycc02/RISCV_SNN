#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Basic tests — unsigned byte load (zero-extends)
  #-------------------------------------------------------------

  TEST_LD_OP( 2, lbu, 0x000000ff,  0, tdat )
  TEST_LD_OP( 3, lbu, 0x00000000,  1, tdat )
  TEST_LD_OP( 4, lbu, 0x000000f0,  2, tdat )
  TEST_LD_OP( 5, lbu, 0x0000000a,  3, tdat )

  # Test with negative offset
  TEST_LD_OP( 6, lbu, 0x000000ff, -3, tdat4 )
  TEST_LD_OP( 7, lbu, 0x00000000, -2, tdat4 )
  TEST_LD_OP( 8, lbu, 0x000000f0, -1, tdat4 )
  TEST_LD_OP( 9, lbu, 0x0000000a,  0, tdat4 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_LD_DEST_BYPASS( 10, 0, lbu, 0x00000000, 1, tdat )
  TEST_LD_DEST_BYPASS( 11, 1, lbu, 0x000000f0, 2, tdat )
  TEST_LD_DEST_BYPASS( 12, 2, lbu, 0x0000000a, 3, tdat )

  TEST_LD_SRC1_BYPASS( 13, 0, lbu, 0x00000000, 1, tdat )
  TEST_LD_SRC1_BYPASS( 14, 1, lbu, 0x000000f0, 2, tdat )
  TEST_LD_SRC1_BYPASS( 15, 2, lbu, 0x0000000a, 3, tdat )

  TEST_CASE( 16, x0, 0, lbu x0, 0(x0) )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA

tdat:
tdat1: .byte 0xff
tdat2: .byte 0x00
tdat3: .byte 0xf0
tdat4: .byte 0x0a

RVTEST_DATA_END
