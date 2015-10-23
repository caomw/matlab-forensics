% Generazione di mappe cumulate e filtrate, tramite filtro a media
% Gaussiano sulla log-somiglianza

function [BPPM]=mappe_cumulate_mean(L,Ns,Nm)

func= @(x) prod(x(true(Ns)));

L_cum=blkproc(L,[Ns Ns],func);

log_L_cum=log(L_cum);

% Filtro Gaussiano

filtro=gaussian_filter(Nm);
filtro_norm=filtro./(sum(sum(filtro)));

log_L_filt=imfilter(log_L_cum,filtro_norm,'replicate');

BPPM=1./(1+exp(log_L_filt));