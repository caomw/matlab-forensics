% Generazione della Block Posteriori Probability Map di dimensioni 2x2

function [BPPM]=BPPM(L)

% generazione della BPPM 

BPPM=1./(1+L);