create_clock -name source_clk -period 20.0 [get_ports clk_i]

## UART TX — connect to USB-UART chip on your board
## TODO: replace J_UART_TX with the actual pin from your board schematic
#set_property PACKAGE_PIN J_UART_TX [get_ports uart_tx_o]
#set_property IOSTANDARD LVCMOS33  [get_ports uart_tx_o]

