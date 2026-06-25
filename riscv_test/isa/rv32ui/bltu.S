#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Branch taken tests (unsigned less-than)
  #-------------------------------------------------------------

  TEST_BR2_OP_TAKEN( 2, bltu, 0x00000000, 0x00000001 )
  TEST_BR2_OP_TAKEN( 3, bltu, 0x7fffffff, 0x80000000 )
  TEST_BR2_OP_TAKEN( 4, bltu, 0x00000001, 0xffffffff )
  TEST_BR2_OP_TAKEN( 5, bltu, 0xfffffffe, 0xffffffff )

  #-------------------------------------------------------------
  # Branch not-taken tests
  #-------------------------------------------------------------

  TEST_BR2_OP_NOTTAKEN(  6, bltu, 0x00000000, 0x00000000 )
  TEST_BR2_OP_NOTTAKEN(  7, bltu, 0x00000001, 0x00000000 )
  TEST_BR2_OP_NOTTAKEN(  8, bltu, 0x80000000, 0x7fffffff )
  TEST_BR2_OP_NOTTAKEN(  9, bltu, 0xffffffff, 0x00000001 )
  TEST_BR2_OP_NOTTAKEN( 10, bltu, 0xffffffff, 0xffffffff )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_BR2_SRC12_BYPASS( 11, 0, 0, bltu, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 12, 0, 1, bltu, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 13, 0, 2, bltu, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 14, 1, 0, bltu, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 15, 1, 1, bltu, 0, 1 )
  TEST_BR2_SRC12_BYPASS( 16, 2, 0, bltu, 0, 1 )

  TEST_BR2_SRC21_BYPASS( 17, 0, 0, bltu, 0, 1 )
  TEST_BR2_SRC21_BYPASS( 18, 0, 1, bltu, 0, 1 )
  TEST_BR2_SRC21_BYPASS( 19, 0, 2, bltu, 0, 1 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
