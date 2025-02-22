/* L'environnement de simulation de MEDIAN est plus simple que celui de
   MED car nous n'avons pas generer le signal de controle BYP et car
   nous savons quand la sortie de MEDIAN est valide grace au signal DSO.
   Le reste est tres similaire ... */
`timescale 1ns/10ps

// Testbench for MEDIAN_IMAGE module
module MEDIAN_IMAGE_tb;

  // Déclaration des signaux
  logic [7:0] DI;         // Donnée d'entrée (8 bits)
  logic CLK, nRST, DSI;   // Horloge, reset actif bas et signal DSI
  wire [7:0] DO;          // Donnée de sortie (8 bits)
  wire DSO;               // Signal de sortie DSO

  // Instance du module MEDIAN_IMAGE
  MEDIAN I_MEDIAN(.DI(DI), .DSI(DSI), .nRST(nRST), .CLK(CLK), .DO(DO), .DSO(DSO));

  // Génération de l'horloge : inversion toutes les 10 ns
  always #10ns CLK = ~CLK;

  // Bloc initial pour simuler les entrées et tester le module
  initial begin: ENTREES

    // Déclaration des variables locales
    integer x, y, rx, ry, i, j, v[0:8], tmp, of;
    logic [7:0] img[0:256*256-1]; // Tableau représentant une image 256x256 pixels

    // Ouverture du fichier de sortie pour enregistrer l'image filtrée
    of = $fopen("bogart_filtre.pgm");
    // Ecriture de l'en-tête PGM (format P2)
    $fdisplay(of, "P2 256 256 255");
    // Lecture de l'image bruitée depuis un fichier hexadécimal
    $readmemh("bogart_bruite.hex", img);
    
    // Initialisation des signaux
    CLK = 1'b0;
    DSI = 1'b0;
    nRST = 1'b0;
    @(negedge CLK);
    nRST = 1'b1;  // Désactivation du reset

    // Parcours de l'image pixel par pixel
    for(y = 0; y < 256; y = y + 1)
      for(x = 0; x < 256; x = x + 1) begin
        // Extraction de la fenêtre 3x3 autour du pixel courant
        for(i = - 1; i < 2; i = i + 1)
          for(j = - 1; j < 2; j = j + 1) begin
            rx = x + j;  // Coordonnée x du pixel voisin
            ry = y + i;  // Coordonnée y du pixel voisin
            // Gestion des bords de l'image
            rx = (rx == -1) ? 0 : rx;
            rx = (rx == 256) ? 255 : rx;
            ry = (ry == -1) ? 0 : ry;
            ry = (ry == 256) ? 255 : ry;
            // Stockage du pixel dans le tableau temporaire v
            v[3 * (i + 1) + j + 1] = img[256 * ry + rx];
          end
        @(negedge CLK);
        DSI = 1'b1; // Activation de DSI pour indiquer le début de l'envoi des pixels
        // Envoi des 9 pixels de la fenêtre au module MEDIAN_IMAGE
        for(i = 0; i < 9; i = i + 1) begin
          DI = v[i];
          @(negedge CLK);
        end
        DSI = 1'b0; // Désactivation de DSI

        // Attente de la disponibilité de la sortie (DSO passe à 1)
        while(DSO == 1'b0)
          @(posedge CLK);
        
        // Tri des pixels pour déterminer la valeur médiane
        for(i = 0; i < 8; i = i + 1)
          for(j = i + 1; j < 9; j = j + 1)
            if(v[i] < v[j]) begin
              tmp = v[i];
              v[i] = v[j];
              v[j] = tmp;
            end
        
        // Vérification : la sortie DO doit correspondre à la valeur médiane (5ème élément après tri)
        if(DO !== v[4]) begin
          $display("erreur : DO = ", DO, " au lieu de ", v[4]);
          $stop;
        end
        // Ecriture de la valeur filtrée dans le fichier de sortie
        $fdisplay(of, "%d", DO);
      end

    // Fermeture du fichier de sortie et fin de simulation
    $fclose(of);
    $display("Fin de simulation sans aucune erreur");
    $finish;
  end

endmodule
