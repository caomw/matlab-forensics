% BPPM con stima della varianza locale

N=1024;         % dimensione dell'immagine
Nt=200;         % dimensione della regione tamperata
Nb=2;           % dimensione del blocco della statistica
Ns=1;           % dimensioni dei blocchi della BPPM
rate=100;

% generazione di una immagine sintetica con CFA di Bayer e interpolazione
% bicubica

sorgente=imread('C:\Users\Pasquale\Desktop\Dataset_Nikon\DSC_0066.tif');
sorgente=sorgente(1:N,1:N,:);

Bayer_G=[0,1;
         1,0];
    
Bayer_R=[1,0;
         0,0];
     
Bayer_B=[0,0; 
         0,1];


% generazione dell'immagine sintetica con interpolazione bicubica

%immagine=uint8(filtro_bilineare(sorgente,Bayer_R,Bayer_G,Bayer_B));
immagine=sorgente;
figure;imshow(immagine);title('Immagine con CFA di Bayer e interpolazione Bilineare');

immagine=imresize(immagine,2);
immagine(:,:,2)=medfilt2(immagine(:,:,2),[5 5]);
immagine=imresize(immagine,0.5);

%immagine_tamperata=DestroyCFA(immagine,immagine,Nt);

%immagine_tamperata=CopyAndPaste_JPEG(immagine,immagine,Nt,50);

immagine_tamperata=immagine;

%imwrite(immagine,'immagine.jpg','Mode','lossy','Quality',rate);
%immagine_tamperata=imread('immagine.jpg');

figure;imshow(immagine_tamperata);%title('Immagine manipolata');


% calcolo delle mappe delle varianze dell'errore di predizione

%errore di predizione sull'immagine


predizione=bilin_prediction(immagine_tamperata,Bayer_R,Bayer_G,Bayer_B,N);

errorePred=predizione(:,:,2);

mappa_varianza=variance_map_generation(errorePred,Bayer_G,N);

%blocks=blocchi_significativi(immagine_tamperata,Nb);

statistica=statistics_generation(mappa_varianza,Bayer_G,Nb);

%statistica=statistica(not(logical(blocks)));

data=statistica(not(isnan(statistica)));
logdata=log(data);
logdata=logdata(not(isnan(logdata)|isinf(logdata)));

%appa_varianza=mappa_varianza(not(isnan(logdata)|isinf(logdata)));

%scatterhist(mappa_varianza,logdata);


% Stima dei parametri

%[mu,sigma,mix_perc]=MoG_parameters_estimation_v2(statistica);


% Calcolo della mappa di probabilità a posteriori

%BPPMap=BPPM_generation(statistica,mu,sigma,Ns);

%figure;imagesc(BPPMap,[0 1]);

