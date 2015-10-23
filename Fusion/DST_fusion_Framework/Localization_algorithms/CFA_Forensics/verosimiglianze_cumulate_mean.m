% Generazione di mappe di verosimiglianza cumulate e filtrate tramite filtro a media Gaussiano

function [BPPM]=verosimiglianze_cumulate_mean(mappa,Ns,Nm)

func= @(x) sum(x(true(Ns)));

BPPM=blkproc(mappa,[Ns Ns],func);

% Filtro Gaussiano

filtro=gaussian_filter(Nm);
filtro=filtro./(sum(sum(filtro)));

BPPM=imfilter(BPPM,filtro,'replicate');