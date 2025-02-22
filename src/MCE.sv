module MCE #(parameter WIDTH = 8)
            (input  logic [WIDTH-1:0] A  ,
             input  logic [WIDTH-1:0] B  ,
             output logic [WIDTH-1:0] MAX,
             output logic [WIDTH-1:0] MIN
);

assign MAX = (A > B) ? A : B ;
assign MIN = (A > B) ? B : A ;

endmodule