#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Basic tests — store halfword then load back
  #-------------------------------------------------------------

  TEST_ST_OP( 2, lhu, sh, 0x00ff,  0, tdat )
  TEST_ST_OP( 3, lhu, sh, 0xff00,  2, tdat )
  TEST_ST_OP( 4, lhu, sh, 0x0ff0,  4, tdat )
  TEST_ST_OP( 5, lhu, sh, 0xf00f,  6, tdat )

  # Test with negative offset
  TEST_ST_OP( 6, lhu, sh, 0x00ff, -6, tdat4 )
  TEST_ST_OP( 7, lhu, sh, 0xff00, -4, tdat4 )
  TEST_ST_OP( 8, lhu, sh, 0x0ff0, -2, tdat4 )
  TEST_ST_OP( 9, lhu, sh, 0xf00f,  0, tdat4 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_ST_SRC12_BYPASS( 10, 0, 0, lhu, sh, 0xaabb, 0, tdat )
  TEST_ST_SRC12_BYPASS( 11, 0, 1, lhu, sh, 0xccdd, 0, tdat )
  TEST_ST_SRC12_BYPASS( 12, 0, 2, lhu, sh, 0xeeff, 0, tdat )
  TEST_ST_SRC12_BYPASS( 13, 1, 0, lhu, sh, 0xaabb, 0, tdat )
  TEST_ST_SRC12_BYPASS( 14, 1, 1, lhu, sh, 0xccdd, 0, tdat )
  TEST_ST_SRC12_BYPASS( 15, 2, 0, lhu, sh, 0xeeff, 0, tdat )

  TEST_ST_SRC21_BYPASS( 16, 0, 0, lhu, sh, 0xaabb, 0, tdat )
  TEST_ST_SRC21_BYPASS( 17, 0, 1, lhu, sh, 0xccdd, 0, tdat )
  TEST_ST_SRC21_BYPASS( 18, 0, 2, lhu, sh, 0xeeff, 0, tdat )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA

tdat:
tdat1: .half 0xbeef
tdat2: .half 0xbeef
tdat3: .half 0xbeef
tdat4: .half 0xbeef

RVTEST_DATA_END
