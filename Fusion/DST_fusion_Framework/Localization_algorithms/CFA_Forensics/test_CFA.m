function [BPPM]=test_CFA(sorgente,N,Nb,Ns)

Bayer_G=[0,1;
         1,0];
    
Bayer_R=[1,0;
         0,0];
     
Bayer_B=[0,0; 
         0,1];


% generazione dell'immagine sintetica con CFA e demosaiking

%immagine=uint8(filtro_bilineare(sorgente,Bayer_R,Bayer_G,Bayer_B));
immagine=sorgente;

% calcolo delle mappe delle varianze dell'errore di predizione

% errore di predizione sull'immagine

predizione=bilin_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N);

% estrazione dell'errore di predizione sul canale verde

errorePred=predizione(:,:,2);

mappa_varianza=variance_map_generation(errorePred,Bayer_G,N);

% generazione della statistica

statistica=statistics_generation(mappa_varianza,Bayer_G,Nb);

% Stima dei parametri
[mu,sigma,mix_perc]=MoG_parameters_estimation(statistica);

% Calcolo della mappa di probabilità a posteriori

BPPM=BPPM_generation(statistica,mu,sigma,Ns);

