#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Basic tests — store byte then load back (unsigned)
  #-------------------------------------------------------------

  TEST_ST_OP( 2, lbu, sb, 0xaa,  0, tdat )
  TEST_ST_OP( 3, lbu, sb, 0xbb,  1, tdat )
  TEST_ST_OP( 4, lbu, sb, 0xcc,  2, tdat )
  TEST_ST_OP( 5, lbu, sb, 0xdd,  3, tdat )

  # Test with negative offset
  TEST_ST_OP( 6, lbu, sb, 0xaa, -3, tdat4 )
  TEST_ST_OP( 7, lbu, sb, 0xbb, -2, tdat4 )
  TEST_ST_OP( 8, lbu, sb, 0xcc, -1, tdat4 )
  TEST_ST_OP( 9, lbu, sb, 0xdd,  0, tdat4 )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_ST_SRC12_BYPASS( 10, 0, 0, lbu, sb, 0xab, 0, tdat )
  TEST_ST_SRC12_BYPASS( 11, 0, 1, lbu, sb, 0xcd, 0, tdat )
  TEST_ST_SRC12_BYPASS( 12, 0, 2, lbu, sb, 0xef, 0, tdat )
  TEST_ST_SRC12_BYPASS( 13, 1, 0, lbu, sb, 0xab, 0, tdat )
  TEST_ST_SRC12_BYPASS( 14, 1, 1, lbu, sb, 0xcd, 0, tdat )
  TEST_ST_SRC12_BYPASS( 15, 2, 0, lbu, sb, 0xef, 0, tdat )

  TEST_ST_SRC21_BYPASS( 16, 0, 0, lbu, sb, 0xab, 0, tdat )
  TEST_ST_SRC21_BYPASS( 17, 0, 1, lbu, sb, 0xcd, 0, tdat )
  TEST_ST_SRC21_BYPASS( 18, 0, 2, lbu, sb, 0xef, 0, tdat )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA

tdat:
tdat1: .byte 0xde
tdat2: .byte 0xad
tdat3: .byte 0xbe
tdat4: .byte 0xef

RVTEST_DATA_END
