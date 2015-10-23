% generazione della statistica di immagini con CFA

function [statistica,significative_blocks]=test_FA_soglia2(sorgente,N,Nb,Ns)

% Generazione del pattern di Bayer


Bayer_G=[0,1;
         1,0];
    
Bayer_R=[1,0;
         0,0];
     
Bayer_B=[0,0; 
         0,1];


immagine=sorgente;


% errore di predizione sull'immagine

predizione=bilin_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N);

% estrazione dell'errore di predizione sul canale verde

errorePred=predizione(:,:,2);

% generazione della mappa della varianza

mappa_varianza=variance_map_generation(errorePred,Bayer_G,N);

% generazione della statistica

statistica=statistics_generation(mappa_varianza,Bayer_G,Nb);

% calcolo dei blocchi significativi

[significative_blocks]=blocchi_significativi(immagine,Nb*Ns);

