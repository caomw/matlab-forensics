% generazione della statistica di immagini con CFA che danno mancata rivelazione
%e delle rispettive varianze

function [data,significative_blocks]=modello_CFA_v3(sorgente,N,Nb)

% soglia della varianza per regioni uniformi
data=[];

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

mappa_varianza=variance_map_generation(errorePred,Bayer_G,N);

[significative_blocks,var]=blocchi_significativi(immagine,Nb);

% generazione della statistica

statistica=statistics_generation(mappa_varianza,Bayer_G,Nb);


data(:,1)=log(statistica(logical(significative_blocks)));
data(:,2)=var(logical(significative_blocks));

