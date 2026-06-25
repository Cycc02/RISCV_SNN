#include "riscv_test.h"
#include "test_macros.h"

RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # AUIPC tests — result = PC + (imm << 12)
  #-------------------------------------------------------------

  # Test 2: auipc with 0 upper — result should equal PC of the instruction
  TEST_CASE( 2, x1, 0,
    la x2, 1f;
    auipc x1, 0;
1:  sub x1, x1, x2;
    addi x1, x1, 4
  )

  # Test 3: auipc non-zero upper immediate
  TEST_CASE( 3, x1, 0,
    la x2, 1f;
    auipc x1, 0x10;
1:  sub x1, x1, x2;
    addi x1, x1, 4;
    lui x2, 0x10;
    sub x1, x1, x2
  )

  # Test 4: auipc stores PC + imm (check lower 12 bits are 0 for the upper part)
  # Just verify auipc x0 writes nothing
  TEST_CASE( 4, x0, 0, auipc x0, 0xfffff )

  TEST_PASSFAIL

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
