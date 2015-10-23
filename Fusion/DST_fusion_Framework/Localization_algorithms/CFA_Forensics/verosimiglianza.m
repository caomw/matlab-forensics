% Calcolo delle mappe di verosimiglianza:

function verosimiglianza(folder_name)


directory = dir([char(folder_name), '/Mappe/*.mat']); % formato cambia a seconda che siano jpg o tif
files = {directory.name};

mu='';
sigma='';

for i=1:length(files)
    
    current_file=char(files(i));
    load([folder_name,'/Mappe/',current_file]);
    load([folder_name,'/Parametri/',current_file]);
    
    mu1=mu(1);
    mu2=mu(2);
    
    sigma1=sigma(1);
    sigma2=sigma(2);
    
    % Valori massimi per i quali non si ha problemi con i logaritmi

    min=1e-320;
    max=1e304;

    statistica(isnan(statistica))=1;
    statistica(isinf(statistica))=max;
    statistica(statistica==0)=min;
    
    log_statistica=log(statistica);
    
    cost=log(sigma2/sigma1);
    p1=(((log_statistica-mu1).^2)./(2*(sigma1^2)));
    p2=(((log_statistica-mu2).^2)./(2*(sigma2^2)));
    
    loglikemap=cost-p1+p2;
    
    save ([folder_name,'/Verosimiglianza/',num2str(i),'.mat'],'loglikemap');
    
end

   