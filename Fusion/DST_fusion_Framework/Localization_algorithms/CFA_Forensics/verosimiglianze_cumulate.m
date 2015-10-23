% Generazione di mappe di verosiglianze cumulate 

function [BPPM]=verosimiglianze_cumulate(mappa,Ns)

func= @(x) sum(x(true(Ns)));

BPPM=blkproc(mappa,[Ns Ns],func);