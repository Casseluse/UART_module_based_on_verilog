module  uart_tx_updated(
     input clk,
	  input rst,
	  input enable_ctrl,
	  input odd_ctrl,
	  input stop_ctrl,
	  input send_trigger,
	  input [7:0] tx_data,
	  output reg txd,
	  output reg sended 

);
parameter CLK_FRE = 50;               //系统时钟(Mhz)
parameter BAUD_RATE = 9600;          //波特率
localparam CYCLE = CLK_FRE * 1000000 / BAUD_RATE;  //计算计数值
localparam CYCLE_2 =2*CYCLE;          

parameter S_IDLE = 4'd0;   //空闲状态
parameter S_START = 4'd1;  //起始位
parameter S_BIT0 = 4'd2;   //第一位
parameter S_BIT1 = 4'd3;   //第二位
parameter S_BIT2 = 4'd4;   //第三位
parameter S_BIT3 = 4'd5;   //第四位
parameter S_BIT4 = 4'd6;   //第五位
parameter S_BIT5 = 4'd7;   //第六位
parameter S_BIT6 = 4'd8;   //第七位
parameter S_BIT7 = 4'd9;   //第八位
parameter S_ODD  = 4'd10;   //奇偶校验位
parameter S_STOP1 = 4'd11;   //停止位
parameter S_STOP2 = 4'd12;   //停止位二

reg[0:0]  send_flag=0;             //发送准备标志
reg[0:0]  sended_flag;           //发送完成标志
reg[3:0]  state = S_IDLE;          //状态寄存器
reg[15:0] bit_timer = 16'b0;       //波特率计数
assign     even_bit = ^tx_data;        //偶校验位
assign      odd_bit = ~even_bit;        //奇校验位   
assign      send_odd = odd_bit;

always@(posedge send_trigger or posedge sended_flag)
begin
    if(sended_flag) //当发送成功后，将发送标志位置0，发送成功位置1，直到停止位结束以至于发送标志位置0，send_flag都无法被置1
	  begin
      send_flag<=1'b0;
		   sended<=1'b1;
	  end
	 else               
	  begin
	   send_flag<=1'b1;
		   sended<=1'b0;
	  end 
end 




always@(posedge clk or negedge rst)
begin
    if (!rst)
	begin 
	    state <= S_IDLE;
		bit_timer <= 16'd0;
		txd <= 1'b0;
	end 
	else
	begin
	    case(state)
		S_IDLE:
		 begin
		     sended_flag<=1'b0;
		     if(!enable_ctrl&&send_flag)
		     begin
			    bit_timer <= 16'd0;
			    state <= S_START;   //转换为开始状态
			    txd <= 1'b1;        //高电平，产生下降沿
			  end
		     else
			  begin
			    state<=state;
			  end
		  end
		S_START:
		    begin
			    txd <= 1'b0;
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT0;     //转换状态，准备开始发送第一位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
		S_BIT0:
		    begin
			    txd <= tx_data[0];
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT1;     //转换状态，准备开始发送第二位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
		S_BIT1:
		    begin
			    txd <= tx_data[1];
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT2;     //转换状态，准备开始发送第三位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
		S_BIT2:
		    begin
			    txd <= tx_data[2];
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT3;     //转换状态，准备开始发送第四位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
		S_BIT3:
		    begin
			    txd <= tx_data[3];
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT4;     //转换状态，准备开始发送第五位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
		S_BIT4:
		    begin
			    txd <= tx_data[4];
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT5;     //转换状态，准备开始发送第六位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
		S_BIT5:
		    begin
			    txd <= tx_data[5];
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT6;     //转换状态，准备开始发送第七位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
		S_BIT6:
		    begin
			    txd <= tx_data[6];
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT7;     //转换状态，准备开始发送第八位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
		    end
		S_BIT7:
		    begin
			    txd <= tx_data[7];
				if (bit_timer == CYCLE)
				  begin
				    bit_timer <= 16'd0;
					 
					 if(odd_ctrl)
					   begin
					  state <= S_ODD;    
						end
					 else
					   begin
						  if(stop_ctrl)
						    begin
							 state <= S_STOP2;	 
							 end	
	                  else
                       begin
		                state <= S_STOP1;
		                 end					  
					   end
					
				   end
				else			
				  begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				  end
			end
			
		 S_ODD:
		 begin	    
  		       txd <= odd_bit;
				if (bit_timer == CYCLE)
				     begin
				        bit_timer <= 16'd0;
                    if(stop_ctrl)
						    begin
							 state <= S_STOP2;
							 end	
	                  else
                       begin
		                state <= S_STOP1;
		                 end		
				     end
			   else
				  begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				  end
		  end	
			
			
		S_STOP1:
		    begin
			    txd <= 1'b1;
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_IDLE;     //转换到空闲状态
					 sended_flag<=1'd1;
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
			
		 S_STOP2:
		    begin
			    txd <= 1'b1;
				if (bit_timer == CYCLE_2)
				begin
				    bit_timer <= 16'd0;
					 state <= S_IDLE;     //转换到空闲状态
					 sended_flag<=1'd1;
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end			
					
			
		default:
			begin
				state <= S_IDLE;
			end
		endcase
	end
end

endmodule
