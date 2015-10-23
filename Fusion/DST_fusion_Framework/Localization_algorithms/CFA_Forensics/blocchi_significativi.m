function [blocks,blocchi_varianza]=blocchi_significativi(immagine,Nb)

immagine=double(immagine(:,:,2));

th1=0;
th2=Inf;

window=gaussian_window();
cost_norm=sum(sum(window));
window=window./cost_norm;
cost_norm_var=1-(sum(sum((window.^2))));

mappa_media=imfilter(immagine,window,'replicate');
mappa_vqm=imfilter(immagine.^2,window,'replicate');

mappa_varianza=(mappa_vqm-(mappa_media.^2))/cost_norm_var;

func= @(x) mean(x(true(Nb)));

blocchi_varianza=blkproc(mappa_varianza,[Nb Nb],func);

blocks=not((blocchi_varianza<th1)|(blocchi_varianza>th2));
