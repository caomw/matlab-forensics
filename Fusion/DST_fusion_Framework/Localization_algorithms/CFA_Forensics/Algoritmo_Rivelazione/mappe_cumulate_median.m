% Generazione di mappe cumulate e filtrate tramite filtro mediano sulla log-somiglianza

function [BPPM]=mappe_cumulate_median(L,Ns,Nm)

func= @(x) prod(x(true(Ns)));

L_cum=blkproc(L,[Ns Ns],func);

log_L_cum=log(L_cum);


% Filtro Mediano

% BPPM=medfilt2(log_L_cum,[Nm Nm],'symmetric');






% Filtro Mediano OLD

log_L_filt=medfilt2(log_L_cum,[Nm Nm],'symmetric');

BPPM=1./(1+exp(log_L_filt));