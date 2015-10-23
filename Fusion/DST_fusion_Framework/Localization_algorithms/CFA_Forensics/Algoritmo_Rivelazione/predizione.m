% Estrazione dell'errore di predizione attraverso un predittore bilineare

function [errorePred]=predizione(immagine)

Hpred=[0, 1, 0;
       1,-4, 1;
       0, 1, 0]/4;
   
errorePred=imfilter(double(immagine),double(Hpred),'replicate');