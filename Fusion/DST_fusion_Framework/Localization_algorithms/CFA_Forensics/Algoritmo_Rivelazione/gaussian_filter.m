% Generazione del filtro a forma Gaussiana

function [window]=gaussian_filter(N_filter)


sigma=1;         % deviazione standard del fltro

% generazione della maschera della stima

[x, y]=meshgrid(-(ceil(sigma*2)):4*sigma/(N_filter-1):ceil(sigma*2));

window=(1/(2*pi*sigma^2)).*exp(-0.5.*(x.^2+y.^2)./sigma^2);
