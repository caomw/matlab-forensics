function [ sorg_filtrata ] = filtro_adaptive( sorgente,patternR,patternG,patternB  )

% Applica il filtro adaptative a sorgente restituendo l'immagine filtrata

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

%gradh e gradv
for i=3:sizer-2
    for j=3:sizec-2
        if(maschera_puriG(i,j)==0 && maschera_puriR(i,j)==1)
            gradh(i,j)=abs(imm_puriG(i,j-1)-imm_puriG(i,j+1))+abs((2*imm_puriR(i,j))-imm_puriR(i,j-2)-imm_puriR(i,j+2));
            gradv(i,j)=abs(imm_puriG(i-1,j)-imm_puriG(i+1,j))+abs((2*imm_puriR(i,j))-imm_puriR(i-2,j)-imm_puriR(i+2,j));
        end
        if(maschera_puriG(i,j)==0 && maschera_puriB(i,j)==1)
            gradh(i,j)=abs(imm_puriG(i,j-1)-imm_puriG(i,j+1))+abs((2*imm_puriB(i,j))-imm_puriB(i,j-2)-imm_puriB(i,j+2));
            gradv(i,j)=abs(imm_puriG(i-1,j)-imm_puriG(i+1,j))+abs((2*imm_puriB(i,j))-imm_puriB(i-2,j)-imm_puriB(i+2,j));
        end       
    end
end
%canale G
for i=3:sizer-2
    for j=3:sizec-2
        if(maschera_puriG(i,j)==0)
            if(maschera_puriR(i,j)==1)
                if(gradh(i,j)<gradv(i,j))
                    imm_puriG(i,j)=(imm_puriG(i,j+1)+imm_puriG(i,j-1))/2+((2*imm_puriR(i,j))-imm_puriR(i,j-2)-imm_puriR(i,j+2))/4;
                elseif(gradh(i,j)>gradv(i,j))
                    imm_puriG(i,j)=(imm_puriG(i+1,j)+imm_puriG(i-1,j))/2+((2*imm_puriR(i,j))-imm_puriR(i-2,j)-imm_puriR(i+2,j))/4;
                else
                    imm_puriG(i,j)=((imm_puriG(i,j+1)+imm_puriG(i,j-1)+imm_puriG(i+1,j)+imm_puriG(i-1,j))/4)+ (4*imm_puriR(i,j)-imm_puriR(i-2,j)-imm_puriR(i+2,j)-imm_puriR(i,j-2)-imm_puriR(i,j+2))/8;
                end
            end
            
            if(maschera_puriB(i,j)==1)
               if(gradh(i,j)<gradv(i,j))
                    imm_puriG(i,j)=(imm_puriG(i,j+1)+imm_puriG(i,j-1))/2+((2*imm_puriB(i,j))-imm_puriB(i,j-2)-imm_puriB(i,j+2))/4;
                elseif(gradh(i,j)>gradv(i,j))
                    imm_puriG(i,j)=(imm_puriG(i+1,j)+imm_puriG(i-1,j))/2+((2*imm_puriB(i,j))-imm_puriB(i-2,j)-imm_puriB(i+2,j))/4;
                else
                    imm_puriG(i,j)=((imm_puriG(i,j+1)+imm_puriG(i,j-1)+imm_puriG(i+1,j)+imm_puriG(i-1,j))/4)+ (4*imm_puriB(i,j)-imm_puriB(i-2,j)-imm_puriB(i+2,j)-imm_puriB(i,j-2)-imm_puriB(i,j+2))/8;
                end
            end
        end
    end
end

%canale R

for i=3:sizer-2
     for j=3:sizec-2
         if (maschera_puriR(i,j)==0 && mod(i,2)==0 && mod(j,2)==1)
             imm_puriR(i,j)=(imm_puriR(i-1,j)+imm_puriR(i+1,j))/2+((2*imm_puriG(i,j))-imm_puriG(i-1,j)-imm_puriG(i+1,j))/2;
         end
         if (maschera_puriR(i,j)==0 && mod(i,2)==1 && mod(j,2)==0)  
             imm_puriR(i,j)=(imm_puriR(i,j-1)+imm_puriR(i,j+1))/2+((2*imm_puriG(i,j))-imm_puriG(i,j-1)-imm_puriG(i,j+1))/2;
        end  
        if (maschera_puriR(i,j)==0 && mod(i,2)==0 && mod(j,2)==0)
            D1=abs(imm_puriR(i-1,j-1)-imm_puriR(i+1,j+1))+abs((2*imm_puriG(i,j))-imm_puriG(i-1,j-1)-imm_puriG(i+1,j+1));
            D2=abs(imm_puriR(i-1,j+1)-imm_puriR(i+1,j-1))+abs((2*imm_puriG(i,j))-imm_puriG(i-1,j+1)-imm_puriG(i+1,j-1));
            if (D1>D2)
                imm_puriR(i,j)=(imm_puriR(i-1,j+1)+imm_puriR(i+1,j-1))/2+((2*imm_puriG(i,j))-imm_puriG(i-1,j+1)-imm_puriG(i+1,j-1));
            elseif (D1<D2)  
                imm_puriR(i,j)=(imm_puriR(i-1,j-1)+imm_puriR(i+1,j+1))/2+((2*imm_puriG(i,j))-imm_puriG(i-1,j-1)-imm_puriG(i+1,j+1));
            else
                imm_puriR(i,j)=(imm_puriR(i-1,j+1)+imm_puriR(i+1,j-1)+imm_puriR(i-1,j-1)+imm_puriR(i+1,j+1))/4+((4*imm_puriG(i,j))-imm_puriG(i-1,j+1)-imm_puriG(i+1,j-1)-imm_puriG(i-1,j-1)-imm_puriG(i+1,j+1))/4;
            end
        end
     end
end

%canale B

for i=3:sizer-2
     for j=3:sizec-2
         if (maschera_puriB(i,j)==0 && mod(i,2)==0 && mod(j,2)==1)
             imm_puriB(i,j)=(imm_puriB(i,j-1)+imm_puriB(i,j+1))/2+((2*imm_puriG(i,j))-imm_puriG(i,j-1)-imm_puriG(i,j+1))/2;
         end
         if (maschera_puriB(i,j)==0 && mod(i,2)==1 && mod(j,2)==0)  
             imm_puriB(i,j)=(imm_puriB(i-1,j)+imm_puriB(i+1,j))/2+((2*imm_puriG(i,j))-imm_puriG(i-1,j)-imm_puriG(i+1,j))/2;
        end  
        if (maschera_puriB(i,j)==0 && mod(i,2)==1 && mod(j,2)==1)
            D1=abs(imm_puriB(i-1,j-1)-imm_puriB(i+1,j+1))+abs((2*imm_puriG(i,j))-imm_puriG(i-1,j-1)-imm_puriG(i+1,j+1));
            D2=abs(imm_puriB(i-1,j+1)-imm_puriB(i+1,j-1))+abs((2*imm_puriG(i,j))-imm_puriG(i-1,j+1)-imm_puriG(i+1,j-1));
            if (D1>D2)
                imm_puriB(i,j)=(imm_puriB(i-1,j+1)+imm_puriB(i+1,j-1))/2+((2*imm_puriG(i,j))-imm_puriG(i-1,j+1)-imm_puriG(i+1,j-1));
            elseif (D1<D2)  
                imm_puriB(i,j)=(imm_puriB(i-1,j-1)+imm_puriB(i+1,j+1))/2+((2*imm_puriG(i,j))-imm_puriG(i-1,j-1)-imm_puriG(i+1,j+1));
            else
                imm_puriB(i,j)=(imm_puriB(i-1,j+1)+imm_puriB(i+1,j-1)+imm_puriB(i-1,j-1)+imm_puriB(i+1,j+1))/4+((4*imm_puriG(i,j))-imm_puriG(i-1,j+1)-imm_puriG(i+1,j-1)-imm_puriG(i-1,j-1)-imm_puriG(i+1,j+1))/4;
            end
        end
     end
end


sorg_filtrata(:,:,1)=imm_puriR(3:end-2,3:end-2);
sorg_filtrata(:,:,2)=imm_puriG(3:end-2,3:end-2);
sorg_filtrata(:,:,3)=imm_puriB(3:end-2,3:end-2);

%sorg_filtrata = uint8(sorg_filtrata);





