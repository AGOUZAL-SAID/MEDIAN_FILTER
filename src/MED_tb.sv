`timescale 1ns/10ps

module MED_tb;  // Un environnement de simulation n'a ni entrees ni
                // sorties.

  logic [7:0] DI;      // On declare les variables qui seront connectees
  logic CLK, BYP, DSI; // aux entrees-sorties du module a tester.
  wire [7:0] DO;     // Les types doivent etre compatibles avec les
                     // ports du module et avec l'usage qu'on en fait.
                     // Les variables qui serviront d'entrees sont
                     // declares "logic" car leur valeur sera modifiee par
                     // des blocs "always" ou "initial".

  MED I_MED(.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO)); // On instancie le module a tester.

  always #10ns CLK = ~CLK; // On genere une horloge

  initial begin: ENTREES // Ici tout le reste est gere par un seul bloc
                         // "initial" que l'on nomme pour pouvoir y
                         // declarer des variables locales.

    integer j, k, v[0:8], tmp; // Cinq variables locales. j et k
                                  // seront utilisees comme indices de
                                  // boucles. La table de 9 entiers v
                                  // sera utilisee par le generateur
                                  // utilisee par le generateur
                                  // aleatoire pour creer les vecteurs
                                  // de test. tmp sera utilisee pour
                                  // echanger deux valeurs de la table v
                                  // lors de la verification des
                                  // resultats.

    CLK = 1'b0; // On initialise l'horloge a 0 en debut de simulation.
    DSI = 1'b0; // On initialise DSI a 0 en debut de simulation.
    repeat (1000) begin                   // Nous allons simuler 1000
                                          // vecteurs.
      @(posedge CLK); // On attend un front montant de CLK.
      DSI = 1'b1; // On leve DSI et BYP car on se prepare a entrer le
      BYP = 1'b1; // premier vecteur de test.
      for(j = 0; j < 9; j = j + 1) begin // Pour chacune des 9 valeurs
                                         // du vecteur ...
        v[j] = {$random} % 256;          // on initialise la table v
                                         // avec une valeur aleatoire
                                         // entre 0 et 255,
        DI = v[j];                      // on place la valeur sur le
                                         // bus DI ...
        @(posedge CLK);                  // et on attend un front
                                         // montant de CLK.
      end
      DSI = 1'b0; // Lorsque les 9 valeurs du vecteur sont entrees on
      BYP = 1'b0; // descend DSI et BYP.

/* La partie qui suit genere BYP pour que le module MED puisse extraire
   la valeur mediane. La sequence est la suivante :
   - 8 periodes a 0 : le max des 9 est dans le registre R8 de MED
   - 1 periode a 1 : le max est ecrase par le contenu de R7, R0 est non
     valide
   - 7 periodes a 0 : le max des 8 restants est dans R8, R7 est non
     valide
   - 2 periodes a 1 : le max des 8 est ecrase par le contenu de R7, puis
     R6, R0 et R1 sont non valides
   - 6 periodes a 0 : le max des 7 restants est dans R8, R7 et R6 sont
     non valides
   - 3 periode a 1 : le max des 7 est ecrase par le contenu de R7, R6
     puis R5, R0, R1 et R2 sont non valides
   - 5 periodes a 0 : le max des 6 restants est dans R8, R7, R6 et R5
     sont non valides
   - 4 periode a 1 : le max des 6 est ecrase par le contenu de R7, R6,
     R5, puis R4, R0, R1, R2 et R3 sont non valides
   - 4 periodes a 0 : le max des 5 restants, c'est a dire la valeur
     mediane recherchee est dans R8 */
      for(j = 0; j < 4; j = j + 1) begin
        for(k = 0; k < 8 - j; k = k + 1) @(posedge CLK);
        BYP = 1'b1;
        for(k = 0; k < j + 1; k = k + 1) @(posedge CLK);
        BYP = 1'b0;
      end
      for(j = 0; j < 4; j = j + 1)
        @(posedge CLK);

      @(posedge CLK); // On attend une demi periode pour etre sur que la
                      // sortie DO de MED est valide.
      for(j = 0; j < 8; j = j + 1)       // On calcule la valeur mediane
        for(k = j + 1; k < 9; k = k + 1) // attendue par un tri a bulle.
          if(v[j] < v[k]) begin
            tmp = v[j];
            v[j] = v[k];
            v[k] = tmp;
          end
      if(DO !== v[4]) begin // Si la sortie de MED est differente de la
                            // valeur attendue ...
        $display("erreur : DO = ", DO, " au lieu de ", v[4]);
               // On produit un message d'erreur.
        $stop; // Et on stoppe la simulation.
      end
    end
    // Lorsque la simulation est terminee on affiche un message.
    $display("Fin de la simulation sans aucune erreur"); 
    $finish; // Et on termine la simulation.
  end

endmodule