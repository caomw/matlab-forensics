% Generazione di mappe cumulate e filtrate tramite filtro a media Gaussiano

function [BPPM]=mappe_cumulate_mean(mappa,Ns,Nm)

func= @(x) prod(x(true(Ns)))/(prod(x(true(Ns)))+(prod(1-x(true(Ns)))));

BPPM=blkproc(mappa,[Ns Ns],func);

% Filtro Gaussiano

filtro=gaussian_filter(Nm);
filtro=filtro./(sum(sum(filtro)));

BPPM=imfilter(BPPM,filtro,'replicate');
