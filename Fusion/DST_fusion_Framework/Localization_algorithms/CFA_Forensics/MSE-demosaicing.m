%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programma per il calcolo del MSE tra immagini originali e reinterpolate
% con algoritmi noti in letteratura, provenienti da differenti
% fotocamere

 
Datasets = dir('/users/ferrara/Desktop/Datasets');

cartelle = {Datasets.name};

Bayer_R = [1, 0;
           0, 0];
       
Bayer_G = [0, 1;
           1, 0];
       
Bayer_B = [0, 0;
           0, 1];
       

for i=6:6
    calcolo_MSE(['/users/ferrara/Desktop/Datasets/',char(cartelle(i))],Bayer_R, Bayer_G, Bayer_B);
end
