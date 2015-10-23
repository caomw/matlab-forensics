% Generazione delle curve ROC

function ROC_verosimiglianza(folder_name,tamp)

% waitbar
h=waitbar(0,'Please wait....');

directory = dir([char(folder_name), '/Verosimiglianza/*.mat']);
files = {directory.name};


dim=512;

% Numero di blocchi 2x2 da accumulare
Ns=[1,2,4];

% Dimensioni del filtraggio
Nm=5;


mask2x2=tampering_mask(dim/2,tamp/2);
mask4x4=tampering_mask(dim/4,tamp/4);
mask8x8=tampering_mask(dim/8,tamp/8);

vettore_logico2x2=logical(kron(ones(100,1),mask2x2(true(length(mask2x2)))));
vettore_logico4x4=logical(kron(ones(100,1),mask4x4(true(length(mask4x4)))));
vettore_logico8x8=logical(kron(ones(100,1),mask8x8(true(length(mask8x8)))));

data2x2=[];
data4x4=[];
data8x8=[];
data2x2_median=[];
data4x4_median=[];
data8x8_median=[];
data2x2_mean=[];
data4x4_mean=[];
data8x8_mean=[];

for i=1:length(files)
    current_file = char(files(i));
    filename = [folder_name, '/Verosimiglianza/', current_file];
    load(filename);
    
    ver2x2=loglikemap;
    ver2x2_median=verosimiglianze_cumulate_median(ver2x2,Ns(1),Nm);
    ver2x2_mean=verosimiglianze_cumulate_mean(ver2x2,Ns(1),Nm);
    
    ver4x4=verosimiglianze_cumulate(ver2x2,Ns(2));
    ver4x4_median=verosimiglianze_cumulate_median(ver2x2,Ns(2),Nm);
    ver4x4_mean=verosimiglianze_cumulate_mean(ver2x2,Ns(2),Nm);

    ver8x8=verosimiglianze_cumulate(ver2x2,Ns(3));
    ver8x8_median=verosimiglianze_cumulate_median(ver2x2,Ns(3),Nm);
    ver8x8_mean=verosimiglianze_cumulate_mean(ver2x2,Ns(3),Nm);
    
    
    data2x2=[data2x2;ver2x2(true(length(ver2x2)))];
    data4x4=[data4x4;ver4x4(true(length(ver4x4)))];
    data8x8=[data8x8;ver8x8(true(length(ver8x8)))];
    
    data2x2_median=[data2x2_median;ver2x2_median(true(length(ver2x2_median)))];
    data4x4_median=[data4x4_median;ver4x4_median(true(length(ver4x4_median)))];
    data8x8_median=[data8x8_median;ver8x8_median(true(length(ver8x8_median)))];
    
    data2x2_mean=[data2x2_mean;ver2x2_mean(true(length(ver2x2_mean)))];
    data4x4_mean=[data4x4_mean;ver4x4_mean(true(length(ver4x4_mean)))];
    data8x8_mean=[data8x8_mean;ver8x8_mean(true(length(ver8x8_mean)))];
     % waiting bar update
      waitbar(i/(length(files)));
end

regione_tamp2x2=data2x2(vettore_logico2x2);
regione_tamp4x4=data4x4(vettore_logico4x4);
regione_tamp8x8=data8x8(vettore_logico8x8);

regione_tamp2x2_median=data2x2_median(vettore_logico2x2);
regione_tamp4x4_median=data4x4_median(vettore_logico4x4);
regione_tamp8x8_median=data8x8_median(vettore_logico8x8);

regione_tamp2x2_mean=data2x2_mean(vettore_logico2x2);
regione_tamp4x4_mean=data4x4_mean(vettore_logico4x4);
regione_tamp8x8_mean=data8x8_mean(vettore_logico8x8);


regione_not_tamp2x2=data2x2(not(vettore_logico2x2));
regione_not_tamp4x4=data4x4(not(vettore_logico4x4));
regione_not_tamp8x8=data8x8(not(vettore_logico8x8));

regione_not_tamp2x2_median=data2x2_median(not(vettore_logico2x2));
regione_not_tamp4x4_median=data4x4_median(not(vettore_logico4x4));
regione_not_tamp8x8_median=data8x8_median(not(vettore_logico8x8));

regione_not_tamp2x2_mean=data2x2_mean(not(vettore_logico2x2));
regione_not_tamp4x4_mean=data4x4_mean(not(vettore_logico4x4));
regione_not_tamp8x8_mean=data8x8_mean(not(vettore_logico8x8));

[PD8x8_mean,PFA8x8_mean]=calcolo_ROC(regione_tamp8x8_mean,regione_not_tamp8x8_mean);


[PD2x2,PFA2x2]=calcolo_ROC(regione_tamp2x2,regione_not_tamp2x2);
[PD2x2_median,PFA2x2_median]=calcolo_ROC(regione_tamp2x2_median,regione_not_tamp2x2_median);
[PD2x2_mean,PFA2x2_mean]=calcolo_ROC(regione_tamp2x2_mean,regione_not_tamp2x2_mean);

[PD4x4,PFA4x4]=calcolo_ROC(regione_tamp4x4,regione_not_tamp4x4);
[PD4x4_median,PFA4x4_median]=calcolo_ROC(regione_tamp4x4_median,regione_not_tamp4x4_median);
[PD4x4_mean,PFA4x4_mean]=calcolo_ROC(regione_tamp4x4_mean,regione_not_tamp4x4_mean);

[PD8x8,PFA8x8]=calcolo_ROC(regione_tamp8x8,regione_not_tamp8x8);
[PD8x8_median,PFA8x8_median]=calcolo_ROC(regione_tamp8x8_median,regione_not_tamp8x8_median);
[PD8x8_mean,PFA8x8_mean]=calcolo_ROC(regione_tamp8x8_mean,regione_not_tamp8x8_mean);

save ([folder_name,'/ROC/ROC'],'PD2x2','PFA2x2','PD4x4','PFA4x4','PD8x8','PFA8x8','PD2x2_median','PFA2x2_median','PD4x4_median','PFA4x4_median','PD8x8_median','PFA8x8_median','PD2x2_mean','PFA2x2_mean','PD4x4_mean','PFA4x4_mean','PD8x8_mean','PFA8x8_mean');

AUC2x2=trapz(PFA2x2,PD2x2);
AUC2x2_median=trapz(PFA2x2_median,PD2x2_median);
AUC2x2_mean=trapz(PFA2x2_mean,PD2x2_mean);

AUC4x4=trapz(PFA4x4,PD4x4);
AUC4x4_median=trapz(PFA4x4_median,PD4x4_median);
AUC4x4_mean=trapz(PFA4x4_mean,PD4x4_mean);


AUC8x8=trapz(PFA8x8,PD8x8);
AUC8x8_median=trapz(PFA8x8_median,PD8x8_median);
AUC8x8_mean=trapz(PFA8x8_mean,PD8x8_mean);

save ([folder_name,'/ROC/AUC.mat'],'AUC2x2','AUC2x2_median','AUC2x2_mean','AUC4x4','AUC4x4_median','AUC4x4_mean','AUC8x8','AUC8x8_median','AUC8x8_mean');
