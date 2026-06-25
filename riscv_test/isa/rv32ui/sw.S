#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Basic tests — store then load back
  #-------------------------------------------------------------

  TEST_ST_OP( 2, lw, sw, 0x00ff00ff,  0, tdat )
  TEST_ST_OP( 3, lw, sw, 0xff00ff00,  4, tdat )
  TEST_ST_OP( 4, lw, sw, 0x0ff00ff0,  8, tdat )
  TEST_ST_OP( 5, lw, sw, 0xf00ff00f, 12, tdat )

  # Test with negative offset
  TEST_ST_OP( 6, lw, sw, 0x00ff00ff, -12, tdat4 )
  TEST_ST_OP( 7, lw, sw, 0xff00ff00,  -8, tdat4 )
  TEST_ST_OP( 8, lw, sw, 0x0ff00ff0,  -4, tdat4 )
  TEST_ST_OP( 9, lw, sw, 0xf00ff00f,   0, tdat4 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_ST_SRC12_BYPASS( 10, 0, 0, lw, sw, 0xaabbccdd, 0, tdat )
  TEST_ST_SRC12_BYPASS( 11, 0, 1, lw, sw, 0xddeeffaa, 0, tdat )
  TEST_ST_SRC12_BYPASS( 12, 0, 2, lw, sw, 0x11223344, 0, tdat )
  TEST_ST_SRC12_BYPASS( 13, 1, 0, lw, sw, 0xaabbccdd, 0, tdat )
  TEST_ST_SRC12_BYPASS( 14, 1, 1, lw, sw, 0xddeeffaa, 0, tdat )
  TEST_ST_SRC12_BYPASS( 15, 2, 0, lw, sw, 0x11223344, 0, tdat )

  TEST_ST_SRC21_BYPASS( 16, 0, 0, lw, sw, 0xaabbccdd, 0, tdat )
  TEST_ST_SRC21_BYPASS( 17, 0, 1, lw, sw, 0xddeeffaa, 0, tdat )
  TEST_ST_SRC21_BYPASS( 18, 0, 2, lw, sw, 0x11223344, 0, tdat )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA

tdat:
tdat1: .word 0xdeadbeef
tdat2: .word 0xdeadbeef
tdat3: .word 0xdeadbeef
tdat4: .word 0xdeadbeef

RVTEST_DATA_END
