function [residuo]=estimated_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N)

%errore di predizione sull'immagine

[ H1red, H1green, H1blue,  H2red, H2green, H2blue,  H3red, H3green, H3blue, Bayer_R, Bayer_G, Bayer_B , mask_R1, mask_R2, mask_R3]= CFA_estimation(immagine);

%errore di predizione sull'immagine regione per regione

f=[0, 0, 0, 0, 0, 0, 0;
   0, 0, 0, 0, 0, 0, 0;
   0, 0, 0, 0, 0, 0, 0;
   0, 0, 0, 1, 0, 0, 0;
   0, 0, 0, 0, 0, 0, 0;
   0, 0, 0, 0, 0, 0, 0;
   0, 0, 0, 0, 0, 0, 0];


HpredR1=f-(H1green);
HpredR2=f-(H2green);
HpredR3=f-(H3green);
   
errorePredR1=imfilter(double(immagine(:,:,2)),double(HpredR1),'replicate');
errorePredR2=imfilter(double(immagine(:,:,2)),double(HpredR2),'replicate');
errorePredR3=imfilter(double(immagine(:,:,2)),double(HpredR3),'replicate');

residuo=errorePredR1.*double(mask_R1(:,:,2))+errorePredR2.*double(mask_R2(:,:,2))+errorePredR3.*double(mask_R3(:,:,2));