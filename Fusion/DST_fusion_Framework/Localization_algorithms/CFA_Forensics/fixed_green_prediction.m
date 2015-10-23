% Estrazione  dell'errore di predizione sul canale verde

function [residuo]=fixed_green_prediction(immagine,N)

% filtro di predizione bilineare 

Hpred=[0, 1, 0;
       1,-4, 1;
       0, 1, 0]/4;
   
residuo=imfilter(double(immagine),double(Hpred),'replicate');