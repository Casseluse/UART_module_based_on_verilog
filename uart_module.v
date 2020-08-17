module uart_module(
    input clk,
	 input rst,
	 input stop,
    input enable_ctrl,
    input trigger,
	 input odd_ctrl,
	 input rxd,
	 input [7:0] tx_data,
	 output[7:0] rx_data,
	 output error,
	 output received,
	 output sended,
	 output txd
);
wire [0:0] cord;
uart_tx_updated uart_tx_0 (
    .clk(clk),
	 .rst(rst),
	 .enable_ctrl(enable_ctrl),
	 .odd_ctrl(odd_ctrl),
	 .stop_ctrl(stop),
	 .send_trigger(trigger),
	 .tx_data(tx_data),
	 .txd(txd),
	 .sended(sended)
);
uart_rx_updated uart_rx_0(
    .clk(clk),
    .rst(rst),
	 .odd_ctrl(odd_ctrl),
	 .enable_ctrl(enable_ctrl),
	 .read_trigger(trigger),
	 .data(rx_data),
	 .error(error),
	 .received(received),
	 .rxd(rxd)
);
endmodule