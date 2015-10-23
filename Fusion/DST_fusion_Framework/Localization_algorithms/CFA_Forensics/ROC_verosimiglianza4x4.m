% Generazione delle curve ROC

function ROC_verosimiglianza4x4(folder_name,tamp)

% waitbar
%h=waitbar(0,'Please wait....');

directory = dir([char(folder_name), '/Verosimiglianza/*.mat']);
files = {directory.name};


dim=512;

% Numero di blocchi 2x2 da accumulare
Ns=[1,2];

% Dimensioni del filtraggio
Nm=5;


mask4x4=tampering_mask(dim/4,tamp/4);
mask8x8=tampering_mask(dim/8,tamp/8);

vettore_logico4x4=logical(kron(ones(length(files),1),mask4x4(true(length(mask4x4)))));
vettore_logico8x8=logical(kron(ones(length(files),1),mask8x8(true(length(mask8x8)))));

data4x4=[];
data8x8=[];
data4x4_median=[];
data8x8_median=[];
data4x4_mean=[];
data8x8_mean=[];

for i=1:length(files)
    current_file = char(files(i));
    filename = [folder_name, '/Verosimiglianza/', current_file];
    load(filename);
    
    ver4x4=loglikemap;
    ver4x4_median=verosimiglianze_cumulate_median(ver4x4,Ns(1),Nm);
    ver4x4_mean=verosimiglianze_cumulate_mean(ver4x4,Ns(1),Nm);

    ver8x8=verosimiglianze_cumulate(ver4x4,Ns(2));
    ver8x8_median=verosimiglianze_cumulate_median(ver4x4,Ns(2),Nm);
    ver8x8_mean=verosimiglianze_cumulate_mean(ver4x4,Ns(2),Nm);
    
    data4x4=[data4x4;ver4x4(true(length(ver4x4)))];
    data8x8=[data8x8;ver8x8(true(length(ver8x8)))];
    
    data4x4_median=[data4x4_median;ver4x4_median(true(length(ver4x4_median)))];
    data8x8_median=[data8x8_median;ver8x8_median(true(length(ver8x8_median)))];
    
    data4x4_mean=[data4x4_mean;ver4x4_mean(true(length(ver4x4_mean)))];
    data8x8_mean=[data8x8_mean;ver8x8_mean(true(length(ver8x8_mean)))];
     % waiting bar update
     % waitbar(i/(length(files)));
end

regione_tamp4x4=data4x4(vettore_logico4x4);
regione_tamp8x8=data8x8(vettore_logico8x8);

regione_tamp4x4_median=data4x4_median(vettore_logico4x4);
regione_tamp8x8_median=data8x8_median(vettore_logico8x8);

regione_tamp4x4_mean=data4x4_mean(vettore_logico4x4);
regione_tamp8x8_mean=data8x8_mean(vettore_logico8x8);

regione_not_tamp4x4=data4x4(not(vettore_logico4x4));
regione_not_tamp8x8=data8x8(not(vettore_logico8x8));

regione_not_tamp4x4_median=data4x4_median(not(vettore_logico4x4));
regione_not_tamp8x8_median=data8x8_median(not(vettore_logico8x8));

regione_not_tamp4x4_mean=data4x4_mean(not(vettore_logico4x4));
regione_not_tamp8x8_mean=data8x8_mean(not(vettore_logico8x8));


[PD4x4,PFA4x4]=calcolo_ROC(regione_tamp4x4,regione_not_tamp4x4);
[PD4x4_median,PFA4x4_median]=calcolo_ROC(regione_tamp4x4_median,regione_not_tamp4x4_median);
[PD4x4_mean,PFA4x4_mean]=calcolo_ROC(regione_tamp4x4_mean,regione_not_tamp4x4_mean);

[PD8x8,PFA8x8]=calcolo_ROC(regione_tamp8x8,regione_not_tamp8x8);
[PD8x8_median,PFA8x8_median]=calcolo_ROC(regione_tamp8x8_median,regione_not_tamp8x8_median);
[PD8x8_mean,PFA8x8_mean]=calcolo_ROC(regione_tamp8x8_mean,regione_not_tamp8x8_mean);

save ([folder_name,'/ROC/ROC'],'PD4x4','PFA4x4','PD8x8','PFA8x8','PD4x4_median','PFA4x4_median','PD8x8_median','PFA8x8_median','PD4x4_mean','PFA4x4_mean','PD8x8_mean','PFA8x8_mean');


AUC4x4=trapz(PFA4x4,PD4x4);
AUC4x4_median=trapz(PFA4x4_median,PD4x4_median);
AUC4x4_mean=trapz(PFA4x4_mean,PD4x4_mean);


AUC8x8=trapz(PFA8x8,PD8x8);
AUC8x8_median=trapz(PFA8x8_median,PD8x8_median);
AUC8x8_mean=trapz(PFA8x8_mean,PD8x8_mean);

save ([folder_name,'/ROC/AUC.mat'],'AUC4x4','AUC4x4_median','AUC4x4_mean','AUC8x8','AUC8x8_median','AUC8x8_mean');
