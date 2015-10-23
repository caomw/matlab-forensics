% BPPM con varianza locale e filtro di predizione bilineare

N=1024;         % dimensione dell'immagine
Nt=200;         % dimensione della regione tamperata
Nb=2;

N_window=7;     % dimensione della finestra di filtraggio
sigma=1;        % deviazione standard del fltro
rate=100;       % tasso di compressione dell'immagine 



% generazione di una immagine sintetica con CFA di Bayer e interpolazione
% bicubica

DSC1=imread('C:\Users\Pasquale\Desktop\NikonD90\DSC_0062.tif');
immagine=DSC1(1:N,1:N,2);

Bayer=[0,1;
       1,0];

pattern=kron(ones(N/2,N/2),Bayer);
pattern_blocco=kron(ones(Nb/2,Nb/2),Bayer);


% generazione dell'immagine sintetica con interpolazione bicubica


figure;imshow(immagine);title('Immagine con CFA di Bayer');

immagine=DestroyCFA(immagine,immagine,Nt);
%immagine=CutAndCopyJPEG(immagine,immagine,Nt,50);


figure;imshow(immagine);title('Immagine Tampered');


% generazione della maschera della stima

[x, y]=meshgrid(-(ceil(sigma*2)):4*sigma/(N_window-1):ceil(sigma*2));
window=(1/(2*pi*(sigma^2))).*exp(-0.5.*(x.^2+y.^2)./(sigma^2));
cost_norm=(sum(sum(window)));


% calcolo delle mappe delle varianze dell'errore di predizione

%errore di predizione sull'immagine

Hpred=[0, 1, 0;
       1,-4, 1;
       0, 1, 0]/4;
   
errorePred=imfilter(double(immagine),double(Hpred),'replicate');


acquisiti=errorePred.*(pattern);
mappa_varianza_acquisiti=cost_norm*imfilter(acquisiti.^2,window,'replicate').*pattern;



interpolati=errorePred.*(1-pattern);
mappa_varianza_interpolati=cost_norm*imfilter(interpolati.^2,window,'replicate').*(1-pattern);

mappa_varianza=mappa_varianza_interpolati+mappa_varianza_acquisiti;

func= @(sigma) (prod(sigma(logical(pattern_blocco)))/prod(sigma(not(logical(pattern_blocco)))));

statistica=blkproc(mappa_varianza,[Nb Nb],func);


% Stima dei parametri

data=log(statistica(true(length(statistica))));

data=data(not(isnan(data)|isinf(data)));

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

% Calcolo della mappa di probabilità a posteriori

BPPM=1./(1+(sigma1/sigma2).*exp(-0.5.*((((log(statistica)-mu2).^2)/sigma2^2)-(((log(statistica)-mu1).^2)/sigma1^2))));

func2= @(x) prod(x(true(2)))/(prod(x(true(2)))+(prod(1-x(true(2)))));

BPPM8x8=blkproc(BPPM,[8 8],func2);

figure;imagesc(BPPM,[0 1]);title('BPPM');
figure;imagesc(BPPM8x8,[0 1]);title('BPPM 4x4');

BPPM=medfilt2(BPPM, [7 7]);
BPPM8x8=medfilt2(BPPM8x8, [3 3]);

figure;imagesc(BPPM,[0 1]);title('BPPM con filtro mediano');
figure;imagesc(BPPM8x8,[0 1]);title('BPPM 4x4 con filtro mediano');



