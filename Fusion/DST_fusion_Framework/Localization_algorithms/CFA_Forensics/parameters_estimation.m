% Stima Maximum Likelihood dei parametri

function [mu,sigma]=parameters_estimation(statistica)

data=log(statistica(not(isnan(statistica)|isinf(statistica)))); % gestione di eventuali NaN e Inf
data=data(not(isinf(data)|isnan(data)));                        % gestione di eventuali NaN e Inf

mu=mean(data);

sigma=sqrt(var(data));