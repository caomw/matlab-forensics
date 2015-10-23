% Generazione della Block Posteriori Probability Map

function [BPPM]=BPPM_uniform(statistica,mu,sigma)

% inizializzazione dei parametri stimati della distribuzione

mu1=mu(1);
mu2=mu(2);

sigma1=sigma(:,:,1);
sigma2=sigma(:,:,2);

% generazione della BPPM

BPPM=1./(1+(sigma1/sigma2).*exp(-0.5.*((((log(statistica)-mu2).^2)/sigma2^2)-(((log(statistica)-mu1).^2)/sigma1^2))));



