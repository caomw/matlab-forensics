% BPPM con stima della varianza locale

N=512;          % dimensione dell'immagine
Nt=200;         % dimensione della regione tamperata
Nb=2;           % dimensione del blocco della BPPM
N_window=7;     % dimensione della finestra di filtraggio
sigma=0.6;      % deviazione standard del fltro
rate=100;       % tasso di compressione dell'immagine 


% generazione di una immagine sintetica con CFA di Bayer e interpolazione
% bicubica

DSC1=imread('C:\Users\Pasquale\Desktop\NikonD90\DSC_0017.tif');
im1=DSC1(1:N,1:N,:);

immagine=im1(:,:,2);

figure;imshow(immagine);title('Immagine con CFA di Bayer');

immagine=DestroyCFA(immagine,immagine,Nt);
%immagine=CutAndCopyJPEG(immagine,immagine,Nt,50);

%imwrite(immagine,'immagine.jpg','Mode','lossy','Quality',rate);
%immagine=imread('immagine.jpg');

figure;imshow(immagine);title('Immagine Manipolata');


% generazione della maschera della stima

[x, y]=meshgrid(-(ceil(sigma*2)):4*sigma/(N_window-1):ceil(sigma*2));
window=(1/(2*pi*(sigma^2))).*exp(-0.5.*(x.^2+y.^2)./(sigma^2));
cost_norm=sum(sum(window));



%errore di predizione sull'immagine

[ H1red, H1green, H1blue,  H2red, H2green, H2blue,  H3red, H3green, H3blue, Bayer_R, Bayer_G, Bayer_B , mask_R1, mask_R2, mask_R3]= CFAestimation(im1);
   
pattern=kron(ones(N/2,N/2),Bayer_G);
pattern_blocco=kron(ones(Nb/2,Nb/2),Bayer_G);

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
   
errorePredR1=imfilter(double(immagine),double(HpredR1),'replicate');
errorePredR2=imfilter(double(immagine),double(HpredR2),'replicate');
errorePredR3=imfilter(double(immagine),double(HpredR3),'replicate');

errorePred=errorePredR1.*double(mask_R1(:,:,2))+errorePredR2.*double(mask_R2(:,:,2))+errorePredR3.*double(mask_R3(:,:,2));

% generazione delle mappe delle varianze


acquisiti=errorePred.*(pattern);
mappa_varianza_acquisiti=cost_norm*imfilter(acquisiti.^2,window,'replicate').*pattern;


interpolati=errorePred.*(1-pattern);
mappa_varianza_interpolati=cost_norm*imfilter(interpolati.^2,window,'replicate').*(1-pattern);

mappa_varianza=mappa_varianza_interpolati+mappa_varianza_acquisiti;


func= @(sigma) (prod(sigma(logical(pattern_blocco)))/prod(sigma(not(logical(pattern_blocco)))));

statistica=blkproc(mappa_varianza,[Nb Nb],func);


% Stima dei parametri

data=log(statistica(true(length(statistica))));

param.mu=[2;0];

param.Sigma=zeros(1,1,2);

param.Sigma(:,:,1)=0.5;
param.Sigma(:,:,2)=0.5;
 
param.PComponents=[0.5;0.5];

options=statset('MaxIter',500,'Display', 'final','TolX', 1e-4);


modMG=gmdistribution.fit(data,2,'Start',param,'Options',options);

sigma2=sqrt(modMG.Sigma(:,:,2));

sigma1=sqrt(modMG.Sigma(:,:,1));

mu1=modMG.mu(1);

mu2=modMG.mu(2);



BPPM=1./(1+(sigma1/sigma2).*exp(-0.5.*((((log(statistica)-mu2).^2)/sigma2^2)-(((log(statistica)-mu1).^2)/sigma1^2))));

func2= @(x) prod(x(true(4)))/(prod(x(true(4)))+(prod(1-x(true(4)))));

BPPM8x8=blkproc(BPPM,[4 4],func2);

figure;imagesc(BPPM,[0 1]);
figure;imagesc(BPPM8x8,[0 1]);
