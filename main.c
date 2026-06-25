#define UART_TX     ((volatile unsigned int *)0x40000000u)
#define UART_STATUS ((volatile unsigned int *)0x40000004u)

static void uart_putc(char c)
{
    while (*UART_STATUS & 1u);
    *UART_TX = (unsigned int)(unsigned char)c;
}

int main(void)
{
    uart_putc('H');
    uart_putc('i');
    uart_putc('\r');
    uart_putc('\n');
    while (1);
    return 0;
}
