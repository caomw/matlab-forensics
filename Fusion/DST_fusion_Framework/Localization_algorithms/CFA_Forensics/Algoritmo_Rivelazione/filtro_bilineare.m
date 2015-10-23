function [ sorg_filtrata ] = filtro_bilineare( sorgente,patternR,patternG,patternB  )

% Applica il filtro bilineare a sorgente restituendo l'immagine filtrata

orig_red = double( sorgente(:,:,1) );%creo i 3 canali red green blue
orig_green = double( sorgente(:,:,2) );
orig_blue = double( sorgente(:,:,3) );


[imm_puriR] = uint8( extraction(orig_red,patternR) );
[imm_puriG] = uint8( extraction(orig_green,patternG) );
[imm_puriB] = uint8( extraction(orig_blue,patternB) );


hrb=0.25*[1 2 1;2 4 2;1 2 1];
hg=0.25*[0 1 0;1 4 1;0 1 0];


mat_bilineare_red=imfilter(imm_puriR,hrb,'replicate');
mat_bilineare_blue=imfilter(imm_puriB,hrb, 'replicate');
mat_bilineare_green=imfilter(imm_puriG,hg, 'replicate');

sorg_filtrata(:,:,1)=mat_bilineare_red;
sorg_filtrata(:,:,2)=mat_bilineare_green;
sorg_filtrata(:,:,3)=mat_bilineare_blue;

sorg_filtrata = uint8(sorg_filtrata);