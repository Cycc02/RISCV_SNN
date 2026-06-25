/* Directed ISA test: localize the matrix/state CRC bug.
 * Exercises byte/halfword load-store at every lane, sign extension,
 * back-to-back store->load, soft multiply, shifts, compares.
 * Prints PASS/FAIL per check over the same UART as CoreMark. */

#define UART_TX     (*(volatile unsigned int *)0x40000000u)
#define UART_STATUS (*(volatile unsigned int *)0x40000004u)

static void putc1(char c)
{
    while (UART_STATUS & 1u);
    UART_TX = (unsigned int)(unsigned char)c;
}
static void puts1(const char *s) { while (*s) putc1(*s++); }
static void puthex(unsigned v)
{
    for (int i = 28; i >= 0; i -= 4) {
        unsigned d = (v >> i) & 0xf;
        putc1(d < 10 ? '0' + d : 'a' + d - 10);
    }
}
static int fails = 0;
static void check(const char *name, unsigned got, unsigned exp)
{
    puts1(name);
    if (got == exp) { puts1(" PASS\n"); }
    else {
        puts1(" FAIL got="); puthex(got);
        puts1(" exp=");      puthex(exp);
        putc1('\n');
        fails++;
    }
}

volatile short          h[8];
volatile unsigned short *uh = (volatile unsigned short *)h;
volatile signed char    b[8];
volatile unsigned char  *ub = (volatile unsigned char *)b;
volatile int            w[4];

int main(void)
{
    /* --- halfword store/load, both lanes --- */
    h[0] = (short)0xedcc;  h[1] = 0x5678;
    check("sh.lh.lane0 ", (unsigned)(int)h[0], 0xffffedcc);
    check("sh.lh.lane2 ", (unsigned)(int)h[1], 0x00005678);
    check("lhu.lane0   ", uh[0], 0x0000edcc);
    check("lhu.lane2   ", uh[1], 0x00005678);

    /* halfword store must not clobber neighbor halfword */
    w[0] = 0x11223344;
    *(volatile short *)&w[0] = (short)0xbeef;          /* lane 0 */
    check("sh.merge.lo ", (unsigned)w[0], 0x1122beef);
    w[0] = 0x11223344;
    *((volatile short *)&w[0] + 1) = (short)0xdead;    /* lane 2 */
    check("sh.merge.hi ", (unsigned)w[0], 0xdead3344);

    /* --- byte store/load, all 4 lanes --- */
    b[0] = (signed char)0x80; b[1] = 0x7f;
    b[2] = (signed char)0xff; b[3] = 0x01;
    check("lb.lane0    ", (unsigned)(int)b[0], 0xffffff80);
    check("lb.lane1    ", (unsigned)(int)b[1], 0x0000007f);
    check("lb.lane2    ", (unsigned)(int)b[2], 0xffffffff);
    check("lb.lane3    ", (unsigned)(int)b[3], 0x00000001);
    check("lbu.lane0   ", ub[0], 0x80);
    check("lbu.lane2   ", ub[2], 0xff);

    /* byte store must not clobber neighbors */
    w[1] = 0x11223344;
    ((volatile unsigned char *)&w[1])[2] = 0xaa;
    check("sb.merge.b2 ", (unsigned)w[1], 0x11aa3344);

    /* --- back-to-back store -> load (same address) --- */
    h[4] = (short)0x7bcd;
    check("sh.lh.b2b   ", (unsigned)(int)h[4], 0x00007bcd);
    b[5] = (signed char)0x9a;
    check("sb.lb.b2b   ", (unsigned)(int)b[5], 0xffffff9a);

    /* --- soft multiply (__mulsi3) --- */
    volatile int ma = -1234, mb = 5678;
    volatile short sa = -50, sb_ = 300;
    int ref = 0, aa = ma, bb = mb;          /* shift-add reference */
    for (int i = 0; i < 32; i++) { if ((bb >> i) & 1) ref += (aa << i); }
    check("mulsi3      ", (unsigned)(ma * mb), (unsigned)ref);
    check("mul.s16     ", (unsigned)(sa * sb_), (unsigned)(-15000));

    /* --- shifts / compares on negatives --- */
    volatile int n = -8;
    check("sra.neg     ", (unsigned)(n >> 2), 0xfffffffe);
    check("srl.neg     ", ((unsigned)n) >> 2, 0x3ffffffd);
    check("slt.neg     ", (n < 1) ? 1u : 0u, 1u);
    check("sltu.neg    ", (((unsigned)n) < 1u) ? 1u : 0u, 0u);

    puts1(fails ? "== ISA TEST: FAILURES ==\n" : "== ISA TEST: ALL PASS ==\n");
    return 0;
}
