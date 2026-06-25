#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Basic tests
  #-------------------------------------------------------------

  TEST_LD_OP( 2, lw, 0x00ff00ff,  0, tdat )
  TEST_LD_OP( 3, lw, 0xff00ff00,  4, tdat )
  TEST_LD_OP( 4, lw, 0x0ff00ff0,  8, tdat )
  TEST_LD_OP( 5, lw, 0xf00ff00f, 12, tdat )

  # Test with negative offset
  TEST_LD_OP( 6, lw, 0x00ff00ff, -12, tdat4 )
  TEST_LD_OP( 7, lw, 0xff00ff00,  -8, tdat4 )
  TEST_LD_OP( 8, lw, 0x0ff00ff0,  -4, tdat4 )
  TEST_LD_OP( 9, lw, 0xf00ff00f,   0, tdat4 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_LD_DEST_BYPASS( 10, 0, lw, 0xff00ff00, 4, tdat )
  TEST_LD_DEST_BYPASS( 11, 1, lw, 0x0ff00ff0, 8, tdat )
  TEST_LD_DEST_BYPASS( 12, 2, lw, 0xf00ff00f, 12, tdat )

  TEST_LD_SRC1_BYPASS( 13, 0, lw, 0xff00ff00, 4, tdat )
  TEST_LD_SRC1_BYPASS( 14, 1, lw, 0x0ff00ff0, 8, tdat )
  TEST_LD_SRC1_BYPASS( 15, 2, lw, 0xf00ff00f, 12, tdat )

  #-------------------------------------------------------------
  # Test that x0 is always 0
  #-------------------------------------------------------------

  TEST_CASE( 16, x0, 0, lw x0, 0(x0) )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA

tdat:
tdat1: .word 0x00ff00ff
tdat2: .word 0xff00ff00
tdat3: .word 0x0ff00ff0
tdat4: .word 0xf00ff00f

RVTEST_DATA_END
