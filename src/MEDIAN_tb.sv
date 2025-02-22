/* L'environnement de simulation de MEDIAN est plus simple que celui de
   MED car nous n'avons pas generer le signal de controle BYP et car
   nous savons quand la sortie de MEDIAN est valide grace au signal DSO.
   Le reste est tres similaire ... */
`timescale 1ns/10ps

// Testbench for the MEDIAN module
module MEDIAN_tb;

  // Déclaration des signaux de test
  logic [7:0] DI;       // Donnée d'entrée (8 bits)
  logic CLK, nRST, DSI; // Horloge, reset actif bas et signal de sélection DSI
  wire  [7:0] DO;       // Donnée de sortie (8 bits)
  wire  DSO;            // Signal de sortie indiquant la disponibilité de DO

  // Instance du module MEDIAN
  MEDIAN I_MEDIAN(  .DI(DI),.DO(DO),
                    .CLK(CLK), .DSI(DSI), 
                    .nRST(nRST), .DSO(DSO)
                 );

  // Génération de l'horloge : inversion toutes les 10 ns
  always #10ns CLK = ~CLK;

  // Bloc initial pour simuler et vérifier le fonctionnement du module MEDIAN
  initial begin: ENTREES

    // Déclaration des variables locales
    int i, j, k, v[0:8], tmp;

    // Initialisation des signaux
    CLK  = 1'b0;
    DSI  = 1'b0;
    nRST = 1'b0;
    @(negedge CLK);
    nRST = 1'b1; // Désactivation du reset

    // Répéter le test 1000 fois
    repeat(1000) begin
      @(negedge CLK);
      DSI = 1'b1; // Activation du signal DSI pour indiquer le début de l'envoi des pixels

      // Envoi de 9 valeurs aléatoires vers le module
      for(j = 0; j < 9; j = j + 1) begin
        v[j] = {$random} % 256;
        DI   = v[j];
        @(negedge CLK);
      end
      DSI = 1'b0; // Fin de l'envoi des pixels

      // Attente que le module indique que la sortie est prête via DSO
      forever begin
        @(posedge CLK);
        if (DSO == 1'b1) break;
      end

      // Tri du tableau v par ordre décroissant pour trouver la médiane
      for(j = 0; j < 8; j = j + 1)
        for(k = j + 1; k < 9; k = k + 1)
          if(v[j] < v[k]) begin
            tmp = v[j];
            v[j] = v[k];
            v[k] = tmp;
          end

      // Vérification que la sortie DO correspond à la médiane (5ème valeur après tri)
      if(DO !== v[4]) begin
        $display("erreur : DO = ", DO, " au lieu de ", v[4]);
        $stop;
      end
    end

    // Fin de la simulation, affichage du message de succès
    $display("Fin de simulation sans aucune erreur");
    $finish;
  end

endmodule
