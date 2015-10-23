% generazione della statistica di immagini con CFA

function [data,significative_blocks]=modello_CFA_v2(sorgente,N,Nb)

% soglia della varianza per regioni uniformi


Bayer_G=[0,1;
         1,0];
    
Bayer_R=[1,0;
         0,0];
     
Bayer_B=[0,0; 
         0,1];


% generazione dell'immagine sintetica con CFA e demosaiking

%immagine=uint8(filtro_bicubico(sorgente,Bayer_R,Bayer_G,Bayer_B));
immagine=sorgente;

%immagine=imresize(immagine,2);

%immagine(:,:,2)=medfilt2(immagine(:,:,2),[3 3]);

%immagine=imresize(immagine,0.5);


% calcolo delle mappe delle varianze dell'errore di predizione

% errore di predizione sull'immagine

predizione=bilin_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N);

% estrazione dell'errore di predizione sul canale verde

errorePred=predizione(:,:,2);

mappa_varianza=variance_map_generation(errorePred,Bayer_G,N);

% generazione della statistica

statistica=statistics_generation(mappa_varianza,Bayer_G,Nb);

[significative_blocks,var]=blocchi_significativi(immagine,Nb);


data=log(statistica(logical(significative_blocks)));
data=data(not(isnan(data)|isinf(data)));


