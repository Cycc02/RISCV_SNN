#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Test 2: basic jalr forward jump, verify rd = PC+4
  #-------------------------------------------------------------

  TEST_CASE( 2, x4, 4,
    la   x1, 1f;
    jalr x4, x1, 0;
1:  sub  x4, x4, x1
  )

  #-------------------------------------------------------------
  # Test 3: jalr with positive offset
  #-------------------------------------------------------------

  TEST_CASE( 3, x4, 4,
    la   x1, 1f;
    addi x1, x1, -4;
    jalr x4, x1, 4;
1:  sub  x4, x4, x1;
    addi x4, x4, -4
  )

  #-------------------------------------------------------------
  # Test 4: jalr with negative offset
  #-------------------------------------------------------------

  TEST_CASE( 4, x4, 4,
    la   x1, 1f;
    addi x1, x1, 4;
    jalr x4, x1, -4;
1:  sub  x4, x4, x1;
    addi x4, x4, 4
  )

  #-------------------------------------------------------------
  # Test 5: jalr clears low bit of target (PC must be 4-byte aligned)
  #-------------------------------------------------------------

  TEST_CASE( 5, x4, 4,
    la   x1, 1f;
    ori  x1, x1, 1;     # set low bit — should be cleared by jalr
    jalr x4, x1, 0;
1:  sub  x4, x4, x1;
    addi x4, x4, 1      # compensate for the set bit we added
  )

  #-------------------------------------------------------------
  # Test 6: jalr x0 — rd not written
  #-------------------------------------------------------------

  TEST_CASE( 6, x0, 0,
    la  x1, 1f;
    jalr x0, x1, 0;
1:  add x0, x0, x0
  )

  #-------------------------------------------------------------
  # Bypass tests
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
