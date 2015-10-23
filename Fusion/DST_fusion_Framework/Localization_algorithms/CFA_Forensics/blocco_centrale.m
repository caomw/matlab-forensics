function [sorgente]=blocco_centrale(sorgente)

block_size=480; %grandezza del blocco centrale in esame
[H,K,L] = size(sorgente); 

if H>block_size && K>block_size
    sorgente = sorgente(floor(H/2)-(block_size/2-1):floor(H/2)+(block_size/2),floor(K/2)-(block_size/2-1):floor(K/2)+(block_size/2),:); % blocco centrale block_size x block_size
end