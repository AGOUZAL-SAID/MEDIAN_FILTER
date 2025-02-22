module test_MED;

logic BYP,DSI,CLK ;
logic [7:0] DI,DO ;

MED MED1(.BYP(BYP)  ,.DSI(DSI),  .CLK(CLK),  .DI(DI),  .DO(DO));

always #10ns CLK = ~CLK;

initial begin: ENTREES

    int v[0:8];
    int i, j, k, tmp;

    CLK = 0;
    DSI = 0;
    BYP = 0;

    repeat(1000) begin

        @(posedge CLK);
        DSI = 1;
        BYP = 1;

        for (j = 0; j < 9; j++) begin

            v[j] = {$random} % 256;
            DI = v[j];

            @(posedge CLK);
        end

        DI = 0;

        for (i = 8; i > 4; i--) begin

            BYP = 0;
            DSI = 0;
            for (j = 0; j < i; j++) @(posedge CLK);
            
            BYP = 1;
            DSI = 1;
            for (j = i; j < 9; j++) @(posedge CLK);
        end

        BYP = 0;
        DSI = 0;
        for (j = 0; j < 4; j++) @(posedge CLK);

        // median caluculation for verification
        for(j = 0; j < 8; j = j + 1)
        for(k = j + 1; k < 9; k = k + 1) 
          if(v[j] < v[k]) begin
            tmp = v[j];
            v[j] = v[k];
            v[k] = tmp;
          end
        
        @(posedge CLK);

        if(v[4] != DO) begin
            $display("erreur : DO = ", DO, " au lieu de ", v[4]);
            $stop;
        end

    end
    $display("Fin de la simulation sans aucune erreur"); 
    $finish;

end
endmodule