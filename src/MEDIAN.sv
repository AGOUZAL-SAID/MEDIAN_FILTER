module MEDIAN(input  logic  DSI,
              input  logic  CLK,
              input  logic  nRST,
              input  logic [7:0] DI,
              output logic [7:0] DO,
              output logic DSO
              );

logic operating_reg;
logic DSI_ret;
logic BYP;
int counter_step ,counter_clk;
logic [7:0] DI_ret;

MED I_MED(.DI(DI_ret), .DSI(DSI_ret), .BYP(BYP), .CLK(CLK), .DO(DO));

// this block manages our counters
always_ff@(posedge CLK or negedge nRST) begin

    if(!nRST) begin
        counter_step <= 8;
        counter_clk <= 0;
    end

    else if (operating_reg) begin
        if (counter_clk == 8 && counter_step > 4) begin
            counter_step <= counter_step - 1;
            counter_clk <= 0;
        end
        else if (counter_clk == 4 && counter_step == 4) begin 
            counter_step <= 8;
            counter_clk <= 0;
        end
        else begin 
            counter_clk <= counter_clk + 1;
        end
        
    end

end

always_ff@(posedge CLK or negedge nRST) begin

    if(!nRST) begin
        DSI_ret <= 0;
        operating_reg <= 0;
    end
    else begin 

        //retarding inputs because the we are one cycle slow
        DI_ret <= DI;
        DSI_ret <= DSI;

        // managing operating_reg control signal
        if (DSI_ret && !DSI) begin
            operating_reg <= 1;
        end
        else if (DSO) begin
            operating_reg <= 0;
        end 
        else begin 
            operating_reg <= operating_reg;
        end

    end

end

always_comb begin
    
    // managing BYP
    if(operating_reg) begin
        if(counter_clk < counter_step) begin 
            BYP = 0;
        end
        else if(counter_step > 4) begin 
            BYP = 1;
        end
        else begin 
            BYP = 0;
        end
    end
    else if(DSI) begin
        BYP = 1;
    end
    else begin
        BYP = 1;
    end

    // managing DSO
    if(counter_step == 4 && counter_clk == 4) begin
        DSO = 1;
    end
    else begin
        DSO = 0;
    end

end

endmodule