function [statistica]=test_bil(immagine, N, Nb)

Bayer_G=[0,1;
         1,0];
    
Bayer_R=[1,0;
         0,0];
     
Bayer_B=[0,0; 
         0,1];

% calcolo delle mappe delle varianze dell'errore di predizione

% errore di predizione sull'immagine

predizione=bilin_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N);

%predizione=bicubic_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N);

%predizione=median_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N);

% estrazione dell'errore di predizione sul canale verde

errorePred=predizione(:,:,2);

mappa_varianza=variance_map_generation(errorePred,Bayer_G,N);

% generazione della statistica

statistica=statistics_generation(mappa_varianza,Bayer_G,Nb);