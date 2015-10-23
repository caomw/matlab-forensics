% generazione della statistica di decisione sulla presenza del CFA

function [statistica]=statistics_generation(sorgente,Bayer,Nb)

pattern_blocco=kron(ones(Nb/2,Nb/2),Bayer);

func= @(sigma) (prod(sigma(logical(pattern_blocco)))/(prod(sigma(not(logical(pattern_blocco))))));

statistica=blkproc(sorgente,[Nb Nb],func);

