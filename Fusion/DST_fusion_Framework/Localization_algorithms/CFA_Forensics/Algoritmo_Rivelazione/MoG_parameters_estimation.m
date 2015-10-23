% Stima dei parametri tramite algoritmo Expectation
% Maximization su Mixtured Gaussian Model

function [mu,sigma,mix_perc]=MoG_parameters_estimation(statistica)

% inizializzazione dei parametri

param.mu=[2;0];                     % i parametri sono inizializzati 
param.Sigma=zeros(1,1,2);           % in base a verifiche empiriche
param.Sigma(:,:,1)=2;
param.Sigma(:,:,2)=1;
param.PComponents=[0.5;0.5];


options=statset('MaxIter',500,'TolX', 1e-2);

data=log(statistica(not(isnan(statistica)|isinf(statistica)))); % gestione di eventuali Nan e Inf
data=data(not(isinf(data)|isnan(data)));                        % gestione di eventuali Nan e Inf

% algoritmo E/M per MG model di MatLab

MG_model=gmdistribution.fit(data,2,'Start',param,'Options',options);  
    
mu=MG_model.mu;

sigma=sqrt(MG_model.Sigma);

mix_perc=MG_model.PComponents;

