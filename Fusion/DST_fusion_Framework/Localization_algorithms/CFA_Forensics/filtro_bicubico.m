function [ sorg_filtrata ] = filtro_bicubico( sorgente,patternR,patternG,patternB )

% Applica il filtro bicubico a sorgente restituendo l'immagine filtrata
sorgente_big=zeros(size(sorgente,1)+4,size(sorgente,2)+4,size(sorgente,3));

sorgente_big(3:end-2,3:end-2,:)=sorgente;
sorgente_big(1:2,1:2,:)=sorgente(1:2,1:2,:);%quadrato 2x2 replicato nell'angolo in alto a sinistra
sorgente_big(1:2,end-1:end,:)=sorgente(1:2,end-1:end,:);%quadrato 2x2 replicato nell'angolo in alto a destra
sorgente_big(end-1:end,1:2,:)=sorgente(end-1:end,1:2,:);%quadrato 2x2 replicato nell'angolo in basso a sinistra
sorgente_big(end-1:end,end-1:end,:)=sorgente(end-1:end,end-1:end,:);%quadrato 2x2 replicato nell'angolo in basso a destra

sorgente_big(3:end-2,1:2,:)=sorgente(:,1:2,:);%replica prime due colonne a sinistra
sorgente_big(1:2,3:end-2,:)=sorgente(1:2,:,:);%replica prime due righe in alto
sorgente_big(end-1:end,3:end-2,:)=sorgente(end-1:end,:,:);%replica ultime due righe in basso
sorgente_big(3:end-2,end-1:end,:)=sorgente(:,end-1:end,:);%replica ultime due colonne a destra
orig_red=double(sorgente_big(:,:,1));%creo i 3 canali red green blue
orig_green=double(sorgente_big(:,:,2));
orig_blue=double(sorgente_big(:,:,3));



[imm_puriR,imm_interR,maschera_puriR]=extraction(orig_red,patternR);
[imm_puriG,imm_interG,maschera_puriG]=extraction(orig_green,patternG);
[imm_puriB,imm_interB,maschera_puriB]=extraction(orig_blue,patternB);


hrb=[1 0 -9 -16 -9 0 1; 0 0 0 0 0 0 0; -9 0 81 144 81 0 -9; -16 0 144 256 144 0 -16; -9 0 81 144 81 0 -9; 0 0 0 0 0 0 0; 1 0 -9 -16 -9 0 1];
hg=[0 0 0 1 0 0 0; 0 0 -9 0 -9 0 0; 0 -9 0 81 0 -9 0; 1 0 81 256 81 0 1; 0 -9 0 81 0 -9 0; 0 0 -9 0 -9 0 0; 0 0 0 1 0 0 0 ];
mat_bicubica_red=imfilter(imm_puriR,hrb);
mat_bicubica_red=mat_bicubica_red/256;
mat_bicubica_blue=imfilter(imm_puriB,hrb);
mat_bicubica_blue=mat_bicubica_blue/256;
mat_bicubica_green=imfilter(imm_puriG,hg);
mat_bicubica_green=mat_bicubica_green/256;

sorg_filtrata(:,:,1)=mat_bicubica_red(3:end-2,3:end-2);
sorg_filtrata(:,:,2)=mat_bicubica_green(3:end-2,3:end-2);
sorg_filtrata(:,:,3)=mat_bicubica_blue(3:end-2,3:end-2);

%sorg_filtrata = uint8(sorg_filtrata);