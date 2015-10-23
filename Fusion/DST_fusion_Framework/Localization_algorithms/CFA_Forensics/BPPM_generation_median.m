% Generazione della Block Posteriori Probability Map

function [BPPM]=BPPM_generation_median(statistica,mu,sigma,Ns)

% inizializzazione dei parametri stimati della distribuzione

mu1=mu(1);
mu2=mu(2);

sigma1=sigma(:,:,1);
sigma2=sigma(:,:,2);


% generazione della BPPM cumulata su blocchi NsxNs, normalizzata e filtrata
% con filtro a media di dimensione 5x5 


BPPM=1./(1+(sigma1/sigma2).*exp(-0.5.*((((log(statistica)-mu2).^2)/sigma2^2)-(((log(statistica)-mu1).^2)/sigma1^2))));

func= @(x) prod(x(true(Ns)))/(prod(x(true(Ns)))+(prod(1-x(true(Ns)))));

BPPM=blkproc(BPPM,[Ns Ns],func);

% Filtraggio mediano sulla BPPM

BPPM=medfilt2(BPPM, [5 5]);
