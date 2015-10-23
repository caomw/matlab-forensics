% Stima dei parametri tramite algoritmo Expectation
% Maximization su Mixtured Gaussian Model

function [mu,sigma,mix_perc]=MoG_parameters_estimation_ZM(statistica, tol, max_iter)

% inizializzazione dei parametri

statistica(isnan(statistica)) = 1;

data=log(statistica(:)); 
data=data(not(isinf(data)|isnan(data)));                        % gestione di eventuali Nan e Inf

% algoritmo E/M per MG model di MatLab

[alpha, v1, mu2, v2] = EMGaussianZM(data, tol , max_iter);  
    
mu= [mu2 ; 0];                  % la seconda componente è forzata a zero

sigma=sqrt([v2; v1]);

mix_perc=[1-alpha;alpha];

