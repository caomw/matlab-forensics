% Generazione delle curve ROC

function ROC_verosimiglianza(folder_name,tamp)

% waitbar
h=waitbar(0,'Please wait....');

directory = dir([char(folder_name), '\Verosimiglianza8x8\*.*']);
files = {directory.name};


dim=512;

% Numero di blocchi 2x2 da accumulare
Ns=[1,2,4];

% Dimensioni del filtraggio
Nm=5;



mask8x8=tampering_mask(dim/8,tamp/8);


vettore_logico8x8=logical(kron(ones(100,1),mask8x8(true(length(mask8x8)))));


data8x8=[];

for i=3:length(files)
    current_file = char(files(i));
    filename = [folder_name, '\Verosimiglianza8x8\', current_file];
    load(filename);
    
    ver8x8=loglikemap;    
    
    data8x8=[data8x8;ver8x8(true(length(ver8x8)))];
    
     % waiting bar update
      waitbar(i/(length(files)));
end


regione_tamp8x8=data8x8(vettore_logico8x8);

regione_not_tamp8x8=data8x8(not(vettore_logico8x8));


[PD8x8,PFA8x8]=calcolo_ROC(regione_tamp8x8,regione_not_tamp8x8);


save ([folder_name,'\ROC8x8\ROC.mat'],'PD8x8','PFA8x8');

AUC8x8=trapz(PFA8x8,PD8x8);

save ([folder_name,'\ROC8x8\AUC.mat'],'AUC8x8');
