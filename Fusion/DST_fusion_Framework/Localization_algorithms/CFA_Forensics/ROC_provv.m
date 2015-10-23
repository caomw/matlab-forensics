% Generazione delle curve ROC

function ROC_provv(folder_name,tamp)

% waitbar
%h=waitbar(0,'Please wait....');

directory = dir([char(folder_name), '/Verosimiglianza/*.mat']);
files = {directory.name};

dim=512;


% Dimensioni del filtraggio
Nm=5;

mask8x8=tampering_mask(dim/8,tamp/8);

vettore_logico8x8=logical(kron(ones(length(files),1),mask8x8(true(length(mask8x8)))));

data8x8=[];
data8x8_median=[];
data8x8_mean=[];

for i=1:length(files)
    current_file = char(files(i));
    filename = [folder_name, '/Verosimiglianza/', current_file];
    load(filename);

    ver8x8=loglikemap;


     
    data8x8=[data8x8;ver8x8(true(length(ver8x8)))];


end

regione_tamp8x8=real(data8x8(vettore_logico8x8));





regione_not_tamp8x8=real(data8x8(not(vettore_logico8x8)));




[PD8x8,PFA8x8]=calcolo_ROC(regione_tamp8x8,regione_not_tamp8x8);

save ([folder_name,'/ROC/ROC'],'PD8x8','PFA8x8');

AUC8x8=trapz(PFA8x8,PD8x8);

save ([folder_name,'/ROC/AUC.mat'],'AUC8x8');