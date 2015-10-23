function [ sorg_filtrata ] = filtro_gradientbased( sorgente,patternR,patternG,patternB  )

% Applica il filtro mediana a sorgente restituendo l'immagine filtrata

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

[gradh_red,gradv_red] = gradvh(imm_puriR);
[gradh_blue,gradv_blue] = gradvh(imm_puriB);

for i=2:sizer-1
    for j=2:sizec-1
        if(maschera_puriG(i,j)==0)
            if(maschera_puriR(i,j)==1)
                if(gradh_red(i,j)<gradv_red(i,j))
                    imm_puriG(i,j)=(imm_puriG(i,j+1)+imm_puriG(i,j-1))/2;
                elseif(gradh_red(i,j)>gradv_red(i,j))
                    imm_puriG(i,j)=(imm_puriG(i+1,j)+imm_puriG(i-1,j))/2;
                else
                    imm_puriG(i,j)=(imm_puriG(i,j+1)+imm_puriG(i,j-1)+imm_puriG(i+1,j)+imm_puriG(i-1,j))/4;
                end
            end
            
            if(maschera_puriB(i,j)==1)
                if(gradh_blue(i,j)<gradv_blue(i,j))
                    imm_puriG(i,j)=(imm_puriG(i,j+1)+imm_puriG(i,j-1))/2;
                elseif(gradh_blue(i,j)>gradv_blue(i,j))
                    imm_puriG(i,j)=(imm_puriG(i+1,j)+imm_puriG(i-1,j))/2;
                else
                    imm_puriG(i,j)=(imm_puriG(i,j+1)+imm_puriG(i,j-1)+imm_puriG(i+1,j)+imm_puriG(i-1,j))/4;
                end
            end
        end
    end
end

diff_RG=imm_puriR-imm_puriG;
diff_BG=imm_puriB-imm_puriG;

%hrb=0.25*[0 1 0;1 4 1;0 1 0];

% Secondo me questo filtraggio ? di troppo
%diff_RG=imfilter(diff_RG,hrb);
%diff_BG=imfilter(diff_BG,hrb);
 
for i=2:sizer-1
     for j=2:sizec-1
         if (maschera_puriR(i,j)==0 && mod(i,2)==0 && mod(j,2)==1)
             imm_puriR(i,j)=imm_puriG(i,j)+0.5*(diff_RG(i-1,j)+diff_RG(i+1,j));
         end
         if (maschera_puriR(i,j)==0 && mod(i,2)==1 && mod(j,2)==0)  
             imm_puriR(i,j)=imm_puriG(i,j)+0.5*(diff_RG(i,j-1)+diff_RG(i,j+1));
        end  
        if (maschera_puriR(i,j)==0 && mod(i,2)==0 && mod(j,2)==0) 
            imm_puriR(i,j)=imm_puriG(i,j)+0.25*(diff_RG(i-1,j-1)+diff_RG(i-1,j+1)+diff_RG(i+1,j-1)+diff_RG(i+1,j+1));
        end
     end
end
            
 for i=2:sizer-1
     for j=2:sizec-1
         if (maschera_puriB(i,j)==0 && mod(i,2)==1 && mod(j,2)==0)
             imm_puriB(i,j)=imm_puriG(i,j)+0.5*(diff_BG(i-1,j)+diff_BG(i+1,j));
         end
         if (maschera_puriB(i,j)==0 && mod(i,2)==0 && mod(j,2)==1) 
             imm_puriB(i,j)=imm_puriG(i,j)+0.5*(diff_BG(i,j-1)+diff_BG(i,j+1));
         end  
        if (maschera_puriB(i,j)==0 && mod(i,2)==1 && mod(j,2)==1) 
            imm_puriB(i,j)=imm_puriG(i,j)+0.25*(diff_BG(i-1,j-1)+diff_BG(i-1,j+1)+diff_BG(i+1,j-1)+diff_BG(i+1,j+1));
        end
     end
end

 
sorg_filtrata(:,:,1)=imm_puriR(3:end-2,3:end-2);
sorg_filtrata(:,:,2)=imm_puriG(3:end-2,3:end-2);
sorg_filtrata(:,:,3)=imm_puriB(3:end-2,3:end-2);

%sorg_filtrata = uint8(sorg_filtrata);

