% generazione della statistica di immagini senza CFA

function [data]=modello_senza_CFA(sorgente,N,Nb)

Bayer_G=[0,1;
         1,0];
    
Bayer_R=[1,0;
         0,0];
     
Bayer_B=[0,0; 
         0,1];


% generazione dell'immagine sintetica senza CFA 

immagine(:,:,1)=medfilt2(sorgente(:,:,1),[5 5]);
immagine(:,:,2)=medfilt2(sorgente(:,:,2),[5 5]);
immagine(:,:,3)=medfilt2(sorgente(:,:,3),[5 5]);


% calcolo delle mappe delle varianze dell'errore di predizione

% errore di predizione sull'immagine

predizione=bilin_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N);

% estrazione dell'errore di predizione sul canale verde

errorePred=predizione(:,:,2);

mappa_varianza=variance_map_generation(errorePred,Bayer_G,N);

% generazione della statistica

statistica=statistics_generation(mappa_varianza,Bayer_G,Nb);

data=log(statistica(not(isnan(statistica)|isinf(statistica))));


