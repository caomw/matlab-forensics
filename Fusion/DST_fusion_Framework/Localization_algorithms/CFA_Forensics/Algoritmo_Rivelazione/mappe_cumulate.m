% Generazione di mappe cumulate

function [BPPM]=mappe_cumulate(L,Ns)

func= @(x) prod(x(true(Ns)));

L_cum=blkproc(L,[Ns Ns],func);

BPPM=1./(1+L_cum);

