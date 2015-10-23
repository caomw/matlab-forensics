% generazione degli istogrammi delle varianze a partire da un dataset di
% foto
 
 function [ris]=istogrammi_senza_CFA(Nimmagini,N)
 
 % Parametri

 N_window=7;     % dimensione della finestra di filtraggio
 sigma=1;        % varianza del fltro
 Nb=2;
 start_path='C:\Users\Pasquale\Desktop\NikonD90 - Copia\';
 
 % generazione della maschera della stima

[x, y]=meshgrid(-(ceil(sigma*2)):4*sigma/(N_window-1):ceil(sigma*2));
window=(1/(2*pi*sigma)).*exp(-0.5.*(x.^2+y.^2)./sigma);

% Filtro di predizione

Hpred=[0, 0, 0, 1, 0, 0, 0;
       0, 0,-9, 0,-9, 0, 0;
       0,-9, 0,81, 0,-9, 0;
       1, 0,81,-256,81,0,1;
       0,-9, 0, 81, 0,-9,0;
       0, 0,-9,  0, -9,0,0;
       0, 0, 0, 1, 0, 0, 0]/256;
 
 % Generazione Pattern
 
 Bayer=[0,1;
        1,0];
pattern=kron(ones(N/4,N/4),Bayer);
pattern_blocco=kron(ones(Nb/2,Nb/2),Bayer);

% Bin e Istogrammi 

passo_var=0.2;
bin_var=0:passo_var:50;

passo2=0.2 ;
bin2=0:passo2:100;

h_var_A=zeros(length(bin_var),1);
h_var_I=zeros(length(bin_var),1);

h2=zeros(length(bin2),1);

% Funzione sui blocchi 2x2
func= @(sigma) (mean(sigma(logical(pattern_blocco)))/mean(sigma(not(logical(pattern_blocco)))));

% Generazione degli istogrammi
 
for i=1:Nimmagini

DSC=imread([start_path,int2str(i),'.tif']);
im=DSC(1:N,1:N,2);
immagine=imresize(im,0.5);

errorePred=imfilter(double(immagine),double(Hpred),'replicate');

acquisiti=errorePred.*(pattern);
mappa_varianza_acquisiti=(sum(sum(window)))*imfilter(acquisiti.^2,window,'replicate').*pattern;

interpolati=errorePred.*(1-pattern);
mappa_varianza_interpolati=(sum(sum(window)))*imfilter(interpolati.^2,window,'replicate').*(1-pattern);

mappa_varianza=mappa_varianza_interpolati+mappa_varianza_acquisiti;


h_var_A=h_var_A+(1/passo_var)*(1/length(mappa_varianza(logical(pattern))))*histc(mappa_varianza(logical(pattern)),bin_var);
h_var_I=h_var_I+(1/passo_var)*(1/length(mappa_varianza(not(logical(pattern)))))*histc(mappa_varianza(not(logical(pattern))),bin_var);


statistica_M1=blkproc(mappa_varianza,[Nb Nb],func);

h2=h2+(1/length(statistica_M1(not(logical(isnan(statistica_M1)+isinf(statistica_M1)))))).*(1/passo2).*histc((statistica_M1(not(logical(isnan(statistica_M1)+isinf(statistica_M1))))),bin2);


end

% Normalizzazione degli istogrammi

h_var_A=h_var_A/Nimmagini;
h_var_I=h_var_I/Nimmagini;

h2=h2/Nimmagini;

figure;plot(bin_var,h_var_A);title('Istogramma della varianza sui pixel acquisiti M2');
figure;plot(bin_var,h_var_I);title('Istogramma della varianza sui pixel interpolati M2');

figure;plot(bin2,h2);title('Distribuzione del rapporto di varianze in assenza di CFA');

ris=1;