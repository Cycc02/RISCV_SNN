#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Test 2: forward jump, rd gets PC+4
  #-------------------------------------------------------------

  TEST_CASE( 2, x1, 0,
    jal x1, 1f;
    addi x1, x0, 1;    # skipped if jump taken
1:  add  x1, x0, x0   # x1 = 0 (rd overwritten by this, but ra was PC+4)
  )

  #-------------------------------------------------------------
  # Test 3: verify link register gets correct return address
  #-------------------------------------------------------------

  TEST_CASE( 3, x4, 4,
    la x1, 1f;
    jal x4, 1f;
1:  sub x4, x4, x1
  )

  #-------------------------------------------------------------
  # Test 4: backward jump
  #-------------------------------------------------------------

  TEST_CASE( 4, x3, 2,
    li  x3, 0;
    li  x2, 2;
1:  addi x3, x3, 1;
    blt  x3, x2, 1b
  )

  #-------------------------------------------------------------
  # Test 5: forward jump over several instructions
  #-------------------------------------------------------------

  TEST_CASE( 5, x6, 1,
    li  x6, 0;
    jal x0, 1f;
    addi x6, x6, 2;
    addi x6, x6, 4;
    addi x6, x6, 8;
1:  addi x6, x6, 1
  )

  #-------------------------------------------------------------
  # Test 6: jal to x0 — rd not written (x0 stays 0)
  #-------------------------------------------------------------

  TEST_CASE( 6, x0, 0,
    jal x0, 1f;
1:  add x0, x0, x0
  )

  #-------------------------------------------------------------
  # Bypass test: source register bypass through JAL rd
  #-------------------------------------------------------------

  TEST_JR_SRC1_BYPASS( 7, 0, jalr )
  TEST_JR_SRC1_BYPASS( 8, 1, jalr )
  TEST_JR_SRC1_BYPASS( 9, 2, jalr )

  TEST_JALR_SRC1_BYPASS( 10, 0, jalr )
  TEST_JALR_SRC1_BYPASS( 11, 1, jalr )
  TEST_JALR_SRC1_BYPASS( 12, 2, jalr )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
