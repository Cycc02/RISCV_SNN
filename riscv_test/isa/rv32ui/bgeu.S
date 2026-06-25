#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Branch taken tests (unsigned greater-than-or-equal)
  #-------------------------------------------------------------

  TEST_BR2_OP_TAKEN( 2, bgeu, 0x00000000, 0x00000000 )
  TEST_BR2_OP_TAKEN( 3, bgeu, 0x00000001, 0x00000001 )
  TEST_BR2_OP_TAKEN( 4, bgeu, 0xffffffff, 0xffffffff )
  TEST_BR2_OP_TAKEN( 5, bgeu, 0x00000001, 0x00000000 )
  TEST_BR2_OP_TAKEN( 6, bgeu, 0x80000000, 0x7fffffff )
  TEST_BR2_OP_TAKEN( 7, bgeu, 0xffffffff, 0x00000001 )
  TEST_BR2_OP_TAKEN( 8, bgeu, 0xffffffff, 0xfffffffe )

  #-------------------------------------------------------------
  # Branch not-taken tests
  #-------------------------------------------------------------

  TEST_BR2_OP_NOTTAKEN(  9, bgeu, 0x00000000, 0x00000001 )
  TEST_BR2_OP_NOTTAKEN( 10, bgeu, 0x7fffffff, 0x80000000 )
  TEST_BR2_OP_NOTTAKEN( 11, bgeu, 0x00000001, 0xffffffff )
  TEST_BR2_OP_NOTTAKEN( 12, bgeu, 0xfffffffe, 0xffffffff )

  #-------------------------------------------------------------
  # Bypass tests
  #-------------------------------------------------------------

  TEST_BR2_SRC12_BYPASS( 13, 0, 0, bgeu, 1, 0 )
  TEST_BR2_SRC12_BYPASS( 14, 0, 1, bgeu, 1, 0 )
  TEST_BR2_SRC12_BYPASS( 15, 0, 2, bgeu, 1, 0 )
  TEST_BR2_SRC12_BYPASS( 16, 1, 0, bgeu, 1, 0 )
  TEST_BR2_SRC12_BYPASS( 17, 1, 1, bgeu, 1, 0 )
  TEST_BR2_SRC12_BYPASS( 18, 2, 0, bgeu, 1, 0 )

  TEST_BR2_SRC21_BYPASS( 19, 0, 0, bgeu, 1, 0 )
  TEST_BR2_SRC21_BYPASS( 20, 0, 1, bgeu, 1, 0 )
  TEST_BR2_SRC21_BYPASS( 21, 0, 2, bgeu, 1, 0 )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
