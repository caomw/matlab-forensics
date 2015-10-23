% Generazione della Mappa di Verosimiglianza

function [L]=verosimiglianza(statistica,mu,sigma)

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

% generazione della verosimiglianza

L=(sigma1/sigma2).*exp(-0.5.*((((log(statistica)-mu2).^2)/sigma2^2)-(((log(statistica)-mu1).^2)/sigma1^2)));
