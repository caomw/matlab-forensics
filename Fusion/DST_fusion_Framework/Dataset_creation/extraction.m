%ad esempio per il canale verde
%pattern = [0 1; 1 0];
%originale = immagine originale canale verde
% si fa l'ipotesi che le immagini abbiano un numero di pixel multiplo di 4 sia per le righe che per le colonne, se cosi non fosse si ritaglia l'immagine originale

function [imm_puri, imm_interp, puri] =  extraction(originale, pattern)
%il prodotto di kronecker kron(A,B) replica il blocchetto B in funzione di A
% quindi se A è fatta di tutti 1 semplicemente replica il blocchetto così come è.
% quante volte va replicato il blocchetto B? tante quante volte il blocchetto B sta nell'immagine.
% Nel nostro caso B è il pattern e l'immagine ha dimensioni multiple rispetto a quelle del pattern
nr = size(originale,1)/size(pattern,1);
nc = size(originale,2) / size(pattern,2);
%matrice di tutti 1 della dimensione cercata
X = zeros(nr, nc)+1;
% ripetizione del pattern
puri = kron(X, pattern);

imm_puri = originale .* puri;
imm_interp =  originale .* (1-puri) ;

return;