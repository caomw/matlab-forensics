% Algoritmo di Rivelazione di Fotomontaggi tramite l'Analisi della
% Demosaicatura

Nb = 2;           % dimensione del blocco della statistica
Ns = 4;           % dimensioni dei blocchi della BPPM
Nm = 5;           % dimensione della finestra di filtraggio

% Pattern di Bayer: sono stimati per un dato modello di fotocamera e
% tengono conto dell'orientazione della camera al momento dell'acquisizione
% dell'immagine

Bayer_G = [0, 1;
           1, 0];
    
Bayer_R = [1, 0;
           0, 0];
     
Bayer_B = [0, 0; 
           0, 1];

% Acquisizione dell'immagine da analizzare

immagine = imread('/users/ferrara/Desktop/Dataset/Siena_DSC_0001.tiff');

% Simulazione di demosaicing bilineare

%immagine = filtro_bilineare( immagine, Bayer_R, Bayer_G, Bayer_B );

% dimensioni dell'immagine

[h, w, dummy] = size(immagine);
dim = [h, w];
     
% Estrazione del canale verde
immagine = immagine(:,:,2);

% Calcolo dell'errore di predizione
err_pred = predizione(immagine);

% Varianza locale dell'errore di predizione
mappa_varianza = variance_map_generation(err_pred, Bayer_G, dim);

% Statistica Log(S)
statistica = statistics_generation(mappa_varianza, Bayer_G, Nb);

% Stima dei parametri GMM

[mu, sigma, mix_perc] = MoG_parameters_estimation(statistica);

% Calcolo della funzione di Verosimiglianza

likelihood_map = verosimiglianza(statistica, mu, sigma);

% Calcolo delle mappe di Probabilit� cumulate e/o filtrate

BPPMap = BPPM(likelihood_map);        % mappa 2x2

BPPMfilt_mean = mappe_cumulate_mean(likelihood_map, Ns, Nm); % mappa cumulata e filtrata

figure; imagesc(BPPMfilt_mean, [0 1]);

BPPMfilt_median = mappe_cumulate_median(likelihood_map, Ns, Nm);

figure; imagesc(BPPMfilt_median, [0 1]);

BPPM_cum = mappe_cumulate(likelihood_map, Ns);

figure; imagesc(BPPM_cum,[0 1]);











