% Generazione della Block Posteriori Probability Map

function [BPPM]=BPPM_generation(statistica,mu,sigma,Ns)

% Valori massimi per i quali non si ha problemi con i logaritmi

min=1e-320;
max=1e304;

statistica(isnan(statistica))=1;
statistica(isinf(statistica))=max;
statistica(statistica==0)=min;


% inizializzazione dei parametri stimati della distribuzione

mu1=mu(1);
mu2=mu(2);

sigma1=sigma(:,:,1);
sigma2=sigma(:,:,2);


% generazione della BPPM cumulata su blocchi NsxNs e normalizzata


BPPM=1./(1+(sigma1/sigma2).*exp(-0.5.*((((log(statistica)-mu2).^2)/sigma2^2)-(((log(statistica)-mu1).^2)/sigma1^2))));

func= @(x) prod(x(true(Ns)))/(prod(x(true(Ns)))+(prod(1-x(true(Ns)))));

BPPM=blkproc(BPPM,[Ns Ns],func);

