% Estrazione dell'errore di predizione nell'algoritmo di rivelazione di
% fotomontaggi

function [errorePred]=predizione(immagine)

Hpred=[0, 1, 0;
       1,-4, 1;
       0, 1, 0]/4;
   
errorePred=imfilter(double(immagine),double(Hpred),'replicate');