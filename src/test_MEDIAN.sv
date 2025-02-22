module test_MEDIAN;
logic DSI,CLK,DSO,nRST,DSO_on ;
logic [7:0] DI,DO ;


MEDIAN MEDIAN1(.DSI(DSI),  .CLK(CLK),  .DI(DI),  .DO(DO),.nRST(nRST),.DSO(DSO));

always #10ns CLK = ~CLK;

initial begin: ENTREES
    int i, j, k, tmp;
    int v[0:8];

    nRST = 0;
    #100ns;
    nRST = 1;
    
    CLK = 0;
    DSI = 0;
    DSO_on = 0;

    repeat(1000) begin

        @(posedge CLK);
        DSI = 1;

        for (j = 0; j < 9; j++) begin

            v[j] = {$random} % 256;
            DI = v[j];

            @(posedge CLK);
        end

        DI = 0;
        DSI = 0;
        
        // median caluculation for verification
        for(j = 0; j < 8; j = j + 1)
        for(k = j + 1; k < 9; k = k + 1) 
          if(v[j] < v[k]) begin
            tmp = v[j];
            v[j] = v[k];
            v[k] = tmp;
          end
        
        for(int timer = 0 ; timer < 50; timer++) begin
            @(posedge CLK);
            if(v[4] != DO && DSO) 
            begin
            $display("erreur : DO = ", DO, " au lieu de ", v[4]);
            $stop;
            end
            if (DSO)
            begin
                DSO_on = 1;
                break;
            end
        end
        if(!DSO_on) begin
            $display("DSO never turn On");
            $stop;
        end
    end
    $display("Fin de la simulation sans aucune erreur"); 
    $finish;
end

endmodule