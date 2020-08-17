module  uart_rx_updated(
     input clk,
	  input rst,
	  input rxd,
	  input odd_ctrl,
	  input enable_ctrl,
	  input read_trigger,
	  output [7:0] data,
	  output reg error,
	  output reg received
);
parameter CLK_FRE = 50;               //系统时钟(Mhz)
parameter BAUD_RATE = 9600;          //波特率
localparam CYCLE = CLK_FRE * 1000000 / BAUD_RATE;  //计算计数值

parameter S_IDLE  = 4'd0;  //空闲状态
parameter S_START = 4'd1;  //起始位
parameter S_BIT0  = 4'd2;  //第一位
parameter S_BIT1  = 4'd3;  //第二位
parameter S_BIT2  = 4'd4;  //第三位
parameter S_BIT3  = 4'd5;  //第四位
parameter S_BIT4  = 4'd6;  //第五位
parameter S_BIT5  = 4'd7;  //第六位
parameter S_BIT6  = 4'd8;  //第七位
parameter S_BIT7  = 4'd9;  //第八位
parameter S_ODD  = 4'd10;  //奇偶校验位
parameter S_STOP  = 4'd11; //停止位

reg[3:0]  state = S_IDLE;      //状态寄存器
reg[15:0] bit_timer = 16'b0;   //波特率计数
reg[0:0]  read_flag = 1'b0;    //繁忙标志，如果其为1，则表示繁忙，当rxd的下降沿到来的时候，进入接收起始模式,busy_flag置为1。
reg[0:0]  read_trigger_flag =1'b0;
reg[0:0]  received_flag;
reg[7:0]  rx_data;                   //接收寄存器
assign  even_bit = ^rx_data;         //偶校验位
assign   odd_bit = ~even_bit;        //奇校验位   
assign      data =rx_data;
assign   read_odd =odd_bit;


always@(posedge read_trigger or posedge received_flag)
begin
   if(received_flag)
	 begin
       read_trigger_flag<=1'b0;
	 end
	else
    begin
	    read_trigger_flag<=1'b1;
	 end 
end

always@(negedge rxd or posedge received_flag)
begin
   if(received_flag)
	  begin
	  read_flag<=1'b0; //这表示received_flag在停止位被置为1，read_flag清零，避免反复触发
	  end	  
	else
	   if(read_trigger_flag&&enable_ctrl)//原来我把使能信号放在状态机的空闲状态中，后来发现为了使read_flag能够唯一
	    begin                            //表示系统已经开始发送（原来的写法还要考虑使能位情况），read_flag为1则表示
	    read_flag<=1'b1;                 //系统一定已经开始工作了
	     end
	  else
	     begin
	    read_flag<=1'b0;
	     end
end

always@(posedge read_flag or negedge received_flag)//这个函数想要完成的是在IDLE状态使received_flag恢复的时候对外给出一个
begin                                              //接收结构已经准备好了的信号，由于read_flag必然在received_flag归零
    if(read_flag)                                 //后至少一个回合之后才能够变为1（由于read_trigger_flag的影响）
	 begin                                        //而read_flag已在received_flag上升沿的时候已经清零...所以此处使用
		  received<=1'b0;                          //！read_flag必然只会指向received_flag归零，系统准备好这一状态
		end
	 else
	   begin
		  received<=1'b1;
		end

end

always@(posedge clk or negedge rst)
begin
    if (!rst)  
	begin 
		bit_timer <= 16'd0;
		state <= S_IDLE;       
	end 
	else
	begin
	    case(state)
		S_IDLE:
		    begin
			    error<=1'b0;
			    received_flag<=1'b0;
			    if(read_flag)
				begin 
				 state <= S_BIT0;  
				end 
				 else
				begin 
				 state <= state;
				end
		    end
		S_BIT0:
		   begin   
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT1;     //转换状态，准备开始发送第二位
					 rx_data[0] <= rxd  ;  
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
			
		 S_BIT1:
		   begin
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT2;     //转换状态，准备开始发送第二位
					 rx_data[1] <= rxd  ;     //转换状态，准备开始发送第一位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
			
		 S_BIT2:
		   begin
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT3;     //转换状态，准备开始发送第二位
			       rx_data[2] <= rxd  ;     //转换状态，准备开始发送第一位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
			
       S_BIT3:
		   begin
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT4;     //转换状态，准备开始发送第二位
		          rx_data[3] <= rxd  ;     //转换状态，准备开始发送第一位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
			
       S_BIT4:
		   begin
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT5;     //转换状态，准备开始发送第二位
                rx_data[4] <= rxd  ;     //转换状态，准备开始发送第一位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
			
       S_BIT5:
		   begin
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT6;     //转换状态，准备开始发送第二位
		          rx_data[5] <= rxd  ;     //转换状态，准备开始发送第一位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
			
       S_BIT6:
		   begin
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
					 state <= S_BIT7;     //转换状态，准备开始发送第二位
		          rx_data[6] <= rxd  ;     //转换状态，准备开始发送第一位
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;      //维持原先的状态
				end
			end
			
		 S_BIT7:
		   begin
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;
			       rx_data[7] <= rxd  ;     //转换状态，准备开始发送第一位 
					 if(odd_ctrl)
					  begin
					    state<=S_ODD; 
					  end
					 else
					  begin
						 received_flag<=1'b1;
						 state<=S_STOP; 
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
				if (bit_timer == CYCLE)
				begin
				    bit_timer <= 16'd0;					 			 
					 if(odd_bit==rxd)
					 begin
					     error<=1'b0;
					 end
					 else
					 begin
					     error<=1'b1;			    
					 end
					 received_flag<=1'b1;
					 state <= S_STOP;     
				end
				else
				begin
				    bit_timer <= bit_timer + 16'd1;
					 state <= state;     
				end
		  end
		  S_STOP:
			begin
			  received_flag<=1'b1;
			  state <= S_IDLE; 
			end
		endcase
	end
end

endmodule
