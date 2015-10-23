% predizione di un filtro gradient based

function [residuo] = gradient_prediction(immagine,Bayer_R,Bayer_G,Bayer_B,N)

immagine=double(immagine);

pattern_R=kron(ones(N/2),Bayer_R);
pattern_G=kron(ones(N/2),Bayer_G);
pattern_B=kron(ones(N/2),Bayer_B);

acquisiti_R=immagine(:,:,1).*pattern_R;
acquisiti_G=immagine(:,:,2).*pattern_G;
acquisiti_B=immagine(:,:,3).*pattern_B;

acquisiti=zeros(N,N,3);
acquisiti(:,:,1)=acquisiti_R;
acquisiti(:,:,2)=acquisiti_G;
acquisiti(:,:,3)=acquisiti_B;


interpolati_R=immagine(:,:,1).*(1-pattern_R);
interpolati_G=immagine(:,:,2).*(1-pattern_G);
interpolati_B=immagine(:,:,3).*(1-pattern_B);

interpolati=zeros(N,N,3);
interpolati(:,:,1)=interpolati_R;
interpolati(:,:,2)=interpolati_G;
interpolati(:,:,3)=interpolati_B;

Bayer_Rf = [0, 1;
            0, 0];
        
Bayer_Bf = [0, 0;
            1, 0];      


predizione_interpolati=interpolati-double(filtro_gradientbased(acquisiti,Bayer_R,Bayer_G,Bayer_B));
predizione_acquisiti=acquisiti-double(filtro_gradientbased(interpolati,Bayer_Rf,1-Bayer_G,Bayer_Bf));

% separiamo gli errori di predizioni delle 2 classi

predizione_interpolati(:,:,1)=predizione_interpolati(:,:,1).*(1-pattern_R);
predizione_interpolati(:,:,2)=predizione_interpolati(:,:,2).*(1-pattern_G);
predizione_interpolati(:,:,3)=predizione_interpolati(:,:,3).*(1-pattern_B);

predizione_acquisiti(:,:,1)=predizione_acquisiti(:,:,1).*(pattern_R);
predizione_acquisiti(:,:,2)=predizione_acquisiti(:,:,2).*(pattern_G);
predizione_acquisiti(:,:,3)=predizione_acquisiti(:,:,3).*(pattern_B);

residuo=predizione_acquisiti+predizione_interpolati;