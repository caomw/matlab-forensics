% Generazione di mappe cumulate

function [BPPM]=mappe_cumulate(mappa,Ns)

func= @(x) prod(x(true(Ns)))/(prod(x(true(Ns)))+(prod(1-x(true(Ns)))));

BPPM=blkproc(mappa,[Ns Ns],func);