module DigitalClock(CLK,RESET,PRESET,STOPWATCH,PAUSESTOPWATCH,RESETSTOPWATCH,ALARM,ONOFFALARM,TIMER,RESETTIMER,ONOFFTIMER,LEFT,RIGHT,UP,DOWN,Anode_Activate,LED_out,DP,beep,h1,h2);
input CLK;
input RESET;
input PRESET;
input LEFT,RIGHT,UP,DOWN;
input STOPWATCH,PAUSESTOPWATCH,RESETSTOPWATCH;
input ALARM,ONOFFALARM;
input TIMER,RESETTIMER,ONOFFTIMER;
output [3:0] Anode_Activate;
output [6:0] LED_out;
output DP;
output reg beep;
output reg [3:0] h1;
output reg [3:0] h2;

reg [2:0] xpos=0;   
reg [25:0] count=0;
reg [25:0] count2=0;
reg CLKOUT;
reg CLKOUT3MS;
reg beep1=0,beep2=0;
reg [6:0] countTimerBeep=0;

always @(posedge CLK) 
begin
    if (count == 50000000)
    begin // Adjust for 100 MHz input clock
        CLKOUT <= ~CLKOUT;
        count <= 0;
    end 
    else 
    begin
        count <= count + 1;
    end
    
    if (count2 == 15000000)
    begin // Adjust for 100 MHz input clock
        CLKOUT3MS <= ~CLKOUT3MS;
        count2 <= 0;
    end 
    else 
    begin
        count2 <= count2 + 1;
    end
end

reg [16:0] CountSec = 0;
reg [16:0] CountSec2 = 0;
reg [16:0] CountSec3 = 0;
reg [16:0] CountSec4 = 0;

reg [6:0] s;
reg [6:0] m;
reg [5:0] h;
reg [3:0] s1;
reg [3:0] s2;
reg [3:0] m1;
reg [3:0] m2;


always @(posedge CLKOUT3MS)
begin
    if(LEFT)
        if(xpos >=6)
            xpos<=0;
        else
            xpos <= xpos+1;
    else if(RIGHT)
        if(xpos<=0)
            xpos<=5;
        else     
            xpos <= xpos-1;
end

always@(posedge CLKOUT or posedge RESET)
begin
    if(RESET)
    begin
       CountSec<=0;
    end
    else
    begin
        if(PRESET && !STOPWATCH && !ALARM && !TIMER)
        begin
            if(UP)
                case(xpos)
                3'b000: CountSec <= CountSec + 1;
                3'b001: CountSec <= CountSec + 10;
                3'b010: CountSec <= CountSec + 60;
                3'b011: CountSec <= CountSec + 600;
                3'b100: CountSec <= CountSec + 3600;
                3'b101: CountSec <= CountSec + 36000;
            endcase
            else if(DOWN)
                case(xpos)
                3'b000: CountSec <= CountSec - 1;
                3'b001: CountSec <= CountSec - 10;
                3'b010: CountSec <= CountSec - 60;
                3'b011: CountSec <= CountSec - 600;
                3'b100: CountSec <= CountSec - 3600;
                3'b101: CountSec <= CountSec - 36000;
            endcase
        end
        else
        begin
           if(CountSec > (86400+36000))
                CountSec <= 0;
           else if(CountSec>=86400)
                CountSec<=0;
           else
                CountSec<=CountSec + 1; 
        end
    end
end

always @(posedge CLKOUT or posedge RESETSTOPWATCH)
begin
    if(RESETSTOPWATCH)
    begin
       CountSec2<=0;
    end
    else
    begin
    if(PAUSESTOPWATCH && STOPWATCH==1)
        CountSec2 <= (CountSec2+1)%86400;
    end
end

always @(posedge CLKOUT) begin
    if (ALARM) begin
    CountSec3 = CountSec3 %86400;
        if (UP) begin
            case (xpos)
                3'b000: CountSec3 <= CountSec3 + 1;
                3'b001: CountSec3 <= CountSec3 + 10;
                3'b010: CountSec3 <= CountSec3 + 60;
                3'b011: CountSec3 <= CountSec3 + 600;
                3'b100: CountSec3 <= CountSec3 + 3600;
                3'b101: CountSec3 <= CountSec3 + 36000;
            endcase
        end else if (DOWN) begin
            case (xpos)
                3'b000: CountSec3 <= CountSec3 - 1;
                3'b001: CountSec3 <= CountSec3 - 10;
                3'b010: CountSec3 <= CountSec3 - 60;
                3'b011: CountSec3 <= CountSec3 - 600;
                3'b100: CountSec3 <= CountSec3 - 3600;
                3'b101: CountSec3 <= CountSec3 - 36000;
            endcase
        end
    end
    
    if (ONOFFALARM && CLKOUT && (CountSec > CountSec3) && (CountSec < (CountSec3 + 60))) begin
        beep1 <= 1;
    end else begin
        beep1 <= 0;
    end
end


always @(posedge CLKOUT or posedge RESETTIMER) begin
    if(RESETTIMER)
    begin
        CountSec4<=0;
        beep2<=0;    
        countTimerBeep<=0;
    end
    else
    begin
        if (TIMER) begin
            CountSec4 = CountSec4 %86400;
            if (UP) begin
                case (xpos)
                    3'b000: CountSec4 <= CountSec4 + 1;
                    3'b001: CountSec4 <= CountSec4 + 10;
                    3'b010: CountSec4 <= CountSec4 + 60;
                    3'b011: CountSec4 <= CountSec4 + 600;
                    3'b100: CountSec4 <= CountSec4 + 3600;
                    3'b101: CountSec4 <= CountSec4 + 36000;
                endcase
            end else if (DOWN) begin
                case (xpos)
                    3'b000: CountSec4 <= CountSec4 - 1;
                    3'b001: CountSec4 <= CountSec4 - 10;
                    3'b010: CountSec4 <= CountSec4 - 60;
                    3'b011: CountSec4 <= CountSec4 - 600;
                    3'b100: CountSec4 <= CountSec4 - 3600;
                    3'b101: CountSec4 <= CountSec4 - 36000;
                endcase
            end
        end
        if(ONOFFTIMER)
        begin
            if(CountSec4>0)
            CountSec4<=(CountSec4-1)%86400;
            else if (CLKOUT && CountSec4==0 && countTimerBeep<15 ) begin
                beep2 <= 1;
                countTimerBeep<=countTimerBeep+1;
            end else begin
                beep2 <= 0;
            end
        end
    end
end

always @(CLKOUT or STOPWATCH or CountSec or CountSec2 or CountSec3 or CountSec4)
begin
    if(STOPWATCH)
    begin
        s <= CountSec2 % 60;
        m <= ((CountSec2 % 3600) / 60);
        h <= CountSec2 / 3600; 
        s2 = s / 10;  
        s1 = s % 10; 
        m2 = m / 10;  
        m1 = m % 10; 
        h2 = h / 10;  
        h1 = h % 10;    
    end
    else if(ALARM)
    begin
        s <= CountSec3 % 60;
        m <= ((CountSec3 % 3600) / 60);
        h <= CountSec3 / 3600; 
        s2 = s / 10;  
        s1 = s % 10; 
        m2 = m / 10;  
        m1 = m % 10; 
        h2 = h / 10;  
        h1 = h % 10;
    end
    else if(TIMER)
    begin
        s <= CountSec4 % 60;
        m <= ((CountSec4 % 3600) / 60);
        h <= CountSec4 / 3600; 
        s2 = s / 10;  
        s1 = s % 10; 
        m2 = m / 10;  
        m1 = m % 10; 
        h2 = h / 10;  
        h1 = h % 10;
    end
    else
    begin
        s <= CountSec % 60;
        m <= ((CountSec % 3600) / 60);
        h <= CountSec / 3600; 
        s2 = s / 10;  
        s1 = s % 10; 
        m2 = m / 10;  
        m1 = m % 10; 
        h2 = h / 10;  
        h1 = h % 10;
    end
end

always @(*)
begin
    beep <= ( ( beep1 || beep2 )&& CLKOUT);
end

sseg(CLK,s1,s2,m1,m2,xpos,Anode_Activate,LED_out,DP);

endmodule





module sseg(
   input clk_100MHz,     
   input [3:0] ones,  
	input [3:0] tens,  
	input [3:0] hundreds,
	input [3:0] thousands ,
	input [2:0] xpos,
    output reg [3:0] AN,
    output reg [6:0] SEG,
    output reg DP       
    );
    // Parameters for segment patterns
    parameter ZERO  = 7'b000_0001;  // 0
    parameter ONE   = 7'b100_1111;  // 1
    parameter TWO   = 7'b001_0010;  // 2
    parameter THREE = 7'b000_0110;  // 3
    parameter FOUR  = 7'b100_1100;  // 4
    parameter FIVE  = 7'b010_0100;  // 5
    parameter SIX   = 7'b010_0000;  // 6
    parameter SEVEN = 7'b000_1111;  // 7
    parameter EIGHT = 7'b000_0000;  // 8
    parameter NINE  = 7'b000_0100;  // 9

    // To select each digit in turn
    reg [1:0] anode_select;        
    reg [16:0] anode_timer;             
    // Logic for controlling digit select and digit timer
    always @(posedge clk_100MHz) begin  // 1ms x 4 displays = 4ms refresh period
        if(anode_timer == 99_999) begin         // The period of 100MHz clock is 10ns (1/100,000,000 seconds)
            anode_timer <= 0;                   // 10ns x 100,000 = 1ms
            anode_select <=  anode_select + 1;
        end
        else
            anode_timer <=  anode_timer + 1;
    end
    
    // Logic for driving the 4 bit anode output based on digit select
    always @(anode_select) begin
        case(anode_select) 
            2'b00 : AN = 4'b1110;   // Turn on ones digit
            2'b01 : AN = 4'b1101;   // Turn on tens digit
            2'b10 : AN = 4'b1011;   // Turn on hundreds digit
            2'b11 : AN = 4'b0111;   // Turn on thousands digit
        endcase
    end
    
    always @(*) begin
        case(anode_select)
            2'b00 : begin 				
								case(ones)
                            4'b0000 : SEG = ZERO;
                            4'b0001 : SEG = ONE;
                            4'b0010 : SEG = TWO;
                            4'b0011 : SEG = THREE;
                            4'b0100 : SEG = FOUR;
                            4'b0101 : SEG = FIVE;
                            4'b0110 : SEG = SIX;
                            4'b0111 : SEG = SEVEN;
                            4'b1000 : SEG = EIGHT;
                            4'b1001 : SEG = NINE;
                        endcase
                    end
                        
            2'b01 : begin 
								case(tens)
                            4'b0000 : SEG = ZERO;
                            4'b0001 : SEG = ONE;
                            4'b0010 : SEG = TWO;
                            4'b0011 : SEG = THREE;
                            4'b0100 : SEG = FOUR;
                            4'b0101 : SEG = FIVE;
                            4'b0110 : SEG = SIX;
                            4'b0111 : SEG = SEVEN;
                            4'b1000 : SEG = EIGHT;
                            4'b1001 : SEG = NINE;
                        endcase
                    end
				
                    
            2'b10 : begin       
                        case(hundreds)
                            4'b0000 : SEG = ZERO;
                            4'b0001 : SEG = ONE;
                            4'b0010 : SEG = TWO;
                            4'b0011 : SEG = THREE;
                            4'b0100 : SEG = FOUR;
                            4'b0101 : SEG = FIVE;
                            4'b0110 : SEG = SIX;
                            4'b0111 : SEG = SEVEN;
                            4'b1000 : SEG = EIGHT;
                            4'b1001 : SEG = NINE;
                        endcase
                    end
                    
            2'b11 : begin      
                        case(thousands)
                            4'b0000 : SEG = ZERO;
                            4'b0001 : SEG = ONE;
                            4'b0010 : SEG = TWO;
                            4'b0011 : SEG = THREE;
                            4'b0100 : SEG = FOUR;
                            4'b0101 : SEG = FIVE;
                            4'b0110 : SEG = SIX;
                            4'b0111 : SEG = SEVEN;
                            4'b1000 : SEG = EIGHT;
                            4'b1001 : SEG = NINE;
                        endcase
                    end
        endcase
   end
   
    always @(*)
    begin
        if(xpos!=anode_select)
        begin
            DP=1;
        end
    end
    
endmodule

