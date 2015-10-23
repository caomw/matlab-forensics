% Iterazione per acquisizione caratteristiche foto da fotocamera
function [media_coefficienti] = stima_coeff_camera (  )

Matrice_totale_coeff_cfa=[];

start_path = 'C:\Documents and Settings\Pasquale\Desktop\Canon_5D - Copia\';


complete_path = [start_path,'1.tif'];
sorgente= imread(complete_path);
sorgente=blocco_centrale(sorgente);
[ min_error,vettorecoeff,pattern ]=maincfa( sorgente );
Matrice_totale_coeff_cfa=[vettorecoeff];
for i=2:10
    complete_path = [start_path, int2str(i),'.tif'];
    sorgente= imread(complete_path);
    sorgente=blocco_centrale(sorgente);
    [ min_error,vettorecoeff,pattern ]=maincfa( sorgente );
    Matrice_totale_coeff_cfa=[Matrice_totale_coeff_cfa;vettorecoeff];
end

media_coefficienti=sum(Matrice_totale_coeff_cfa)./10;

