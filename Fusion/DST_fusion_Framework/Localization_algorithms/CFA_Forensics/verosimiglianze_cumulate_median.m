% Generazione di mappe cumulate e filtrate tramite filtro mediano

function [BPPM]=verosimiglianze_cumulate_median(mappa,Ns,Nm)

func= @(x) sum(x(true(Ns)));

BPPM=blkproc(mappa,[Ns Ns],func);

% Filtraggio mediano

BPPM=medfilt2(BPPM,[Nm Nm],'symmetric');