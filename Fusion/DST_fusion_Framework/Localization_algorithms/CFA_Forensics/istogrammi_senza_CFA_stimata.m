% generazione degli istogrammi delle varianze a partire da un dataset di
% foto
 
 function [ris]=istogrammi_senza_CFA_stimata(Nimmagini,N)
 
 % Parametri

 N_window=7;     % dimensione della finestra di filtraggio
 sigma=1;        % deviazione standard del fltro

 Nb=2;
 start_path='C:\Users\Pasquale\Desktop\NikonD90 - Copia\';
 
 % generazione della maschera della stima

[x, y]=meshgrid(-(ceil(sigma*2)):4*sigma/(N_window-1):ceil(sigma*2));
window=(1/(2*pi*(sigma^2))).*exp(-0.5.*(x.^2+y.^2)./(sigma^2));


% Bin e Istogrammi 

passo_var=0.2;
bin_var=0:passo_var:50;

passo2=0.2 ;
bin2=0:passo2:100;

h_var_A=zeros(length(bin_var),1);
h_var_I=zeros(length(bin_var),1);

h2=zeros(length(bin2),1);


% Generazione degli istogrammi
 
for i=1:Nimmagini

DSC=imread([start_path,int2str(i),'.tif']);
im=DSC(1:N,1:N,:);
im=imresize(im,0.5);
immagine=im(:,:,2);

[ H1red, H1green, H1blue,  H2red, H2green, H2blue,  H3red, H3green, H3blue, Bayer_R, Bayer_G, Bayer_B , mask_R1, mask_R2, mask_R3]= CFAestimation(im);
   
pattern=kron(ones(N/4,N/4),Bayer_G);
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

% Stima della varianza

acquisiti=errorePred.*(pattern);
mappa_varianza_acquisiti=(sum(sum(window)))*imfilter(acquisiti.^2,window,'replicate').*pattern;

interpolati=errorePred.*(1-pattern);
mappa_varianza_interpolati=(sum(sum(window)))*imfilter(interpolati.^2,window,'replicate').*(1-pattern);

mappa_varianza=mappa_varianza_interpolati+mappa_varianza_acquisiti;


% Funzione sui blocchi 2x2
func= @(sigma) (mean(sigma(logical(pattern_blocco)))/mean(sigma(not(logical(pattern_blocco)))));


h_var_A=h_var_A+(1/passo_var)*(1/length(mappa_varianza(logical(pattern))))*histc(mappa_varianza(logical(pattern)),bin_var);
h_var_I=h_var_I+(1/passo_var)*(1/length(mappa_varianza(not(logical(pattern)))))*histc(mappa_varianza(not(logical(pattern))),bin_var);


statistica_M1=blkproc(mappa_varianza,[Nb Nb],func);

h2=h2+(1/length(statistica_M1(not(logical(isnan(statistica_M1)+isinf(statistica_M1)))))).*(1/passo2).*histc((statistica_M1(not(logical(isnan(statistica_M1)+isinf(statistica_M1))))),bin2);

data(:,i)=statistica_M1(true(length(statistica_M1)));
end

% Normalizzazione degli istogrammi

h_var_A=h_var_A/Nimmagini;
h_var_I=h_var_I/Nimmagini;

h2=h2/Nimmagini;

figure;plot(bin_var,h_var_A);title('Istogramma della varianza sui pixel acquisiti M2');
figure;plot(bin_var,h_var_I);title('Istogramma della varianza sui pixel interpolati M2');

figure;plot(bin2,h2);title('Distribuzione del rapporto di varianze in assenza di CFA');

ris=data;