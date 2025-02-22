module MED #(parameter WIDTH = 8, N_PIXELS = 9)
            (input  logic  BYP,      // Signal de bypass
             input  logic  DSI,      // Signal de sélection de données d'entrée
             input  logic  CLK,      // Horloge
             input  logic [WIDTH-1:0] DI, // Donnée d'entrée
             output logic [WIDTH-1:0] DO); // Donnée de sortie

// Déclaration des registres de stockage des pixels
logic [WIDTH-1:0] regs [N_PIXELS-1:0];
// Déclaration des signaux intermédiaires utilisés pour les comparaisons
logic [WIDTH-1:0] A, B, MAX, MIN, O_MUX1, O_MUX2;

// MUX pour sélectionner la donnée d'entrée ou le minimum selon DSI
assign O_MUX1 = DSI ? DI : MIN; // Si DSI est à 1, on prend DI, sinon MIN

// MUX pour sélectionner le registre ou le maximum selon BYP
assign O_MUX2 = BYP ? regs[N_PIXELS-2] : MAX; // Si BYP est à 1, on passe le pixel précédent, sinon MAX

// Assignation de A et B aux derniers pixels du registre pour le module de comparaison
assign A = regs[N_PIXELS-1]; // Dernier pixel
assign B = regs[N_PIXELS-2]; // Avant-dernier pixel

// La sortie DO correspond au dernier pixel du registre
assign DO = regs[N_PIXELS-1];

// Instance du module de comparaison MCE
MCE #(.WIDTH(WIDTH)) I_MCE(.A(A), .B(B), .MAX(MAX), .MIN(MIN));

// Processus synchronisé sur le front montant de l'horloge
always_ff @(posedge CLK) 
begin
    regs[0] <= O_MUX1; // Chargement de la nouvelle donnée dans le premier registre
    // Décalage des pixels dans le registre
    for( int i = 0; i < N_PIXELS-2; i++)
    begin
        regs[i+1] <= regs[i];
    end
    regs[N_PIXELS-1] <= O_MUX2; // Mise à jour du dernier registre avec la donnée sélectionnée par le MUX
end

endmodule
