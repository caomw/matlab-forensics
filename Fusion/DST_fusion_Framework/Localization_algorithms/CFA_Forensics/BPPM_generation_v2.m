% Generazione della Block Posteriori Probability Map

function [BPPM]=BPPM_generation_v2(statistica,blocks,mu,sigma,Ns)

% inizializzazione dei parametri stimati della distribuzione

probability=0.5;        % probabilità dei blocchi uniformi

mu1=mu(1);
mu2=mu(2);

sigma1=sigma(:,:,1);
sigma2=sigma(:,:,2);


% generazione della BPPM cumulata su blocchi NsxNs, normalizzata e filtrata
% con filtro a media di dimensione 5x5 


BPPM=1./(1+(sigma1/sigma2).*exp(-0.5.*((((log(statistica)-mu2).^2)/sigma2^2)-(((log(statistica)-mu1).^2)/sigma1^2))));

BPPM(blocks==0)=probability;

func= @(x) prod(x(true(Ns)))/(prod(x(true(Ns)))+(prod(1-x(true(Ns)))));

BPPM=blkproc(BPPM,[Ns Ns],func);

%BPPM=medfilt2(BPPM, [5 5]);