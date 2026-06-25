/* End-to-end RISC-V + SNN demonstration.
 *
 * Flow:
 *   1. Image is statically placed in .data (DTCM) via mnist_img.h.
 *   2. CPU computes the DTCM word index of mnist_img and writes it to
 *      SNN_IMG_BASE (CSR 0xBC0).
 *   3. CPU kicks the SNN (SNN_KICK = 1, CSR 0xBC2).
 *   4. CPU performs a "parallel work" checksum while the SNN inferences,
 *      proving the two engines run concurrently.
 *   5. CPU polls SNN_KICK until hardware auto-clears it (done_layer2).
 *   6. CPU reads SNN_OUT (CSR 0xBC3) and prints the classification.
 *   7. CPU prints cycle counts: total, SNN-busy window, parallel work done.
 */

#include <stdint.h>
#include "mnist_img.h"

#define DTCM_BASE       0x00010000u
#define UART_TX         (*(volatile uint32_t *)0x40000000u)

/* CSR addresses */
#define CSR_SNN_IMG_BASE  0xBC0
#define CSR_SNN_KICK      0xBC2
#define CSR_SNN_OUT       0xBC3
#define CSR_SNN_HID_LO    0xBC4
#define CSR_SNN_HID_HI    0xBC5
#define CSR_MCYCLE        0xC00

#define csr_write(csr, val) __asm__ volatile ("csrw  %0, %1" :: "i"(csr), "r"(val))
#define csr_read(csr) ({ uint32_t __v;                                  \
        __asm__ volatile ("csrr %0, %1" : "=r"(__v) : "i"(csr));        \
        __v; })
#define csr_set(csr, val)  __asm__ volatile ("csrs  %0, %1" :: "i"(csr), "r"(val))

static void uart_putc(char c) { UART_TX = (uint32_t)c; }

static void uart_puts(const char *s) {
    while (*s) uart_putc(*s++);
}

static void uart_put_hex32(uint32_t v) {
    uart_puts("0x");
    for (int i = 7; i >= 0; --i) {
        uint32_t nyb = (v >> (i * 4)) & 0xF;
        uart_putc(nyb < 10 ? ('0' + nyb) : ('A' + nyb - 10));
    }
}

static void uart_put_dec(uint32_t v) {
    char buf[11];
    int  i = 0;
    if (v == 0) { uart_putc('0'); return; }
    while (v) { buf[i++] = '0' + (v % 10); v /= 10; }
    while (i--) uart_putc(buf[i]);
}

/* argmax over the 10 output spike bits — the predicted MNIST class. */
static int argmax10(uint32_t spikes) {
    int    best_idx = -1;
    /* The output is one-hot per neuron; if multiple bits are set we still
     * pick the lowest-index winner, but log it. */
    for (int i = 0; i < 10; ++i)
        if (spikes & (1u << i)) { best_idx = i; break; }
    return best_idx;
}

int main(void) {
    /* Word index into DTCM where mnist_img lives. */
    uint32_t img_addr  = (uint32_t)&mnist_img[0];
    uint32_t img_widx  = (img_addr - DTCM_BASE) >> 2;

    uart_puts("\n=== SNN end-to-end demo ===\n");
    uart_puts("Image word index in DTCM: ");
    uart_put_hex32(img_widx);
    uart_puts("\nTrue label: ");
    uart_put_dec(MNIST_TRUE_LABEL);
    uart_putc('\n');

    /* --- Configure + kick SNN --------------------------------------- */
    uint32_t t_kick = csr_read(CSR_MCYCLE);
    csr_write(CSR_SNN_IMG_BASE, img_widx);
    csr_write(CSR_SNN_KICK,     1);

    /* --- Parallel work: CPU computes a checksum while SNN runs ------ */
    /* xorshift over the same image data + a constant counter loop, so
     * the user can see CPU instructions retiring during SNN_busy. */
    volatile uint32_t cpu_work = 0;
    uint32_t          iters    = 0;
    while (csr_read(CSR_SNN_KICK)) {
        uint32_t x = cpu_work ^ (iters * 0x9E3779B9u);
        x ^= x << 13;
        x ^= x >> 17;
        x ^= x << 5;
        cpu_work = x + iters;
        iters++;
    }
    uint32_t t_done = csr_read(CSR_MCYCLE);

    /* --- Read SNN outputs ------------------------------------------- */
    uint32_t out_spikes = csr_read(CSR_SNN_OUT)    & 0x3FFu;
    uint32_t hid_lo     = csr_read(CSR_SNN_HID_LO);
    uint32_t hid_hi     = csr_read(CSR_SNN_HID_HI);
    int      pred       = argmax10(out_spikes);

    uart_puts("\n--- SNN result ---\n");
    uart_puts("Output spikes (10b): ");
    uart_put_hex32(out_spikes);
    uart_puts("\nHidden spikes hi/lo: ");
    uart_put_hex32(hid_hi);
    uart_putc(' ');
    uart_put_hex32(hid_lo);
    uart_puts("\nPredicted class: ");
    if (pred < 0) uart_puts("(none)");
    else          uart_put_dec((uint32_t)pred);
    uart_puts("\n\n--- Cycle accounting ---\n");
    uart_puts("SNN busy cycles  : ");
    uart_put_dec(t_done - t_kick);
    uart_puts("\nCPU parallel iters: ");
    uart_put_dec(iters);
    uart_puts("\nCPU checksum     : ");
    uart_put_hex32(cpu_work);
    uart_puts("\n=== Demo complete ===\n");

    return 0;
}
