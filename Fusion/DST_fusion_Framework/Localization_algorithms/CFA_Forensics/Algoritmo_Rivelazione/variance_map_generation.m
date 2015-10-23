% Generazione della mappa di varianze, ottenuta separando i pixel
% interpolati da quelli acquisiti, e togliendo i blocchi che hanno varianza
% sotto una certa soglia th


function [mappa_varianza]=variance_map_generation(sorgente,Bayer,dim)


pattern=kron(ones(dim(1)/2,dim(2)/2),Bayer);

mask=[1,0,1,0,1,0,1;
      0,1,0,1,0,1,0;
      1,0,1,0,1,0,1;
      0,1,0,1,0,1,0;
      1,0,1,0,1,0,1;
      0,1,0,1,0,1,0;
      1,0,1,0,1,0,1];

window=gaussian_window().*mask;
cost_norm_mean=sum(sum(window));
cost_norm_var=1-(sum(sum((window.^2))));
window_mean=window./cost_norm_mean;

acquisiti=sorgente.*(pattern);
mappa_media_acquisiti=imfilter(acquisiti,window_mean,'replicate').*pattern;
mappa_vqm_acquisiti=imfilter(acquisiti.^2,window_mean,'replicate').*pattern;
mappa_varianza_acquisiti=(mappa_vqm_acquisiti-(mappa_media_acquisiti.^2))/cost_norm_var;

interpolati=sorgente.*(1-pattern);
mappa_media_interpolati=imfilter(interpolati,window_mean,'replicate').*(1-pattern);
mappa_vqm_interpolati=imfilter(interpolati.^2,window_mean,'replicate').*(1-pattern);
mappa_varianza_interpolati=(mappa_vqm_interpolati-(mappa_media_interpolati.^2))/cost_norm_var;



mappa_varianza=mappa_varianza_interpolati+mappa_varianza_acquisiti;