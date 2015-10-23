function [ sorg_filtrata ] = filtro_smooth( sorgente,patternR,patternG,patternB  )

% Applica il filtro smooth hue a sorgente restituendo l'immagine filtrata

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
[sizer, sizec]=size(orig_red);

[imm_puriR,imm_interR,maschera_puriR]=extraction(orig_red,patternR);
[imm_puriG,imm_interG,maschera_puriG]=extraction(orig_green,patternG);
[imm_puriB,imm_interB,maschera_puriB]=extraction(orig_blue,patternB);



hrb=0.25*[0 1 0;1 4 1;0 1 0];


mat_bilineare_green=imfilter(imm_puriG,hrb);
ratio_rg=imm_puriR./mat_bilineare_green;
ratio_bg=imm_puriB./mat_bilineare_green;
ratio_rg=imfilter(ratio_rg,hrb);
ratio_bg=imfilter(ratio_bg,hrb);


for i=3:sizer-2
     for j=3:sizec-2
         if (maschera_puriR(i,j)==0 && mod(i,2)==0 && mod(j,2)==1)
             imm_puriR(i,j)=0.5*(mat_bilineare_green(i,j))*(ratio_rg(i+1,j)+(ratio_rg(i-1,j)));
         end
         if (maschera_puriR(i,j)==0 && mod(i,2)==1 && mod(j,2)==0) 
             imm_puriR(i,j)=0.5*(mat_bilineare_green(i,j))*(ratio_rg(i,j+1)+(ratio_rg(i,j-1)));
         end  
        if (maschera_puriR(i,j)==0 && mod(i,2)==0 && mod(j,2)==0) 
            imm_puriR(i,j)=0.25*(mat_bilineare_green(i,j))*(ratio_rg(i+1,j+1)+ratio_rg(i-1,j-1)+ratio_rg(i-1,j+1)+ratio_rg(i+1,j-1));
        end
     end
end
            
 for i=3:sizer-2
     for j=3:sizer-2
         if (maschera_puriB(i,j)==0 && mod(i,2)==0 && mod(j,2)==1)
             imm_puriB(i,j)=0.5*(mat_bilineare_green(i,j))*(ratio_bg(i,j+1)+(ratio_bg(i,j-1)));
         end
         if (maschera_puriB(i,j)==0 && mod(i,2)==1 && mod(j,2)==0) 
             imm_puriB(i,j)=0.5*(mat_bilineare_green(i,j))*(ratio_bg(i+1,j)+(ratio_bg(i-1,j)));
         end  
        if (maschera_puriB(i,j)==0 && mod(i,2)==1 && mod(j,2)==1) 
             imm_puriB(i,j)=0.25*(mat_bilineare_green(i,j))*(ratio_bg(i+1,j+1)+ratio_bg(i-1,j-1)+ratio_bg(i-1,j+1)+ratio_bg(i+1,j-1));
        end
     end
end           
            
            



sorg_filtrata(:,:,1)=imm_puriR(3:end-2,3:end-2);
sorg_filtrata(:,:,2)=mat_bilineare_green(3:end-2,3:end-2);
sorg_filtrata(:,:,3)=imm_puriB(3:end-2,3:end-2);

sorg_filtrata = uint8(sorg_filtrata);