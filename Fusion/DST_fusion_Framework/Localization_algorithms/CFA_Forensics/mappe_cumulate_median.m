% Generazione di mappe cumulate e filtrate tramite filtro mediano

function [BPPM]=mappe_cumulate_median(mappa,Ns,Nm)

func= @(x) prod(x(true(Ns)))/(prod(x(true(Ns)))+(prod(1-x(true(Ns)))));

BPPM=blkproc(mappa,[Ns Ns],func);

% Filtraggio mediano

BPPM=medfilt2(BPPM,[Nm Nm]);
