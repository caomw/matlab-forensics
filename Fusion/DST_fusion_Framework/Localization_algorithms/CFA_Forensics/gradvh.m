function [ gradh, gradv ] = gradvh( matrice_pura )

% Calcolo del gradiente orizzontale e verticale della matrice_pura

dim=size(matrice_pura);
gradh=zeros(dim);
gradv=zeros(dim);
for i= 1:dim(1),
    for j=1:dim(2),
        
        %gradh
        if(j>=3 && j<=(dim(2)-2)) 
            gradh(i,j) = abs(matrice_pura(i,j-2)+matrice_pura(i,j+2)-(2*matrice_pura(i,j)));
        elseif(j<3)
            gradh(i,j) = abs(0+matrice_pura(i,j+2)-(2*matrice_pura(i,j))); %creazione del gradiente nei bordi della matrice
        elseif(j>(dim(2)-2))
            gradh(i,j) = abs(matrice_pura(i,j-2)+ 0 -(2*matrice_pura(i,j))); %creazione del gradiente nei bordi della matrice
        end
        
        %gradv
        
        if(i>=3 && i<=(dim(1)-2))
           gradv(i,j) = abs(matrice_pura(i-2,j)+matrice_pura(i+2,j)-(2*matrice_pura(i,j)));
        elseif(i<3)
           gradv(i,j) = abs(0 +matrice_pura(i+2,j)-(2*matrice_pura(i,j))); %creazione del gradiente nei bordi della matrice
        elseif(i>(dim(1)-2))
           gradv(i,j) = abs(matrice_pura(i-2,j)+ 0 -(2*matrice_pura(i,j))); %creazione del gradiente nei bordi della matrice
        end
        
        
        
    end
end