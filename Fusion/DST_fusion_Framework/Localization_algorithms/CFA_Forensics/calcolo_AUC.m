function calcolo_AUC(folder_name);

load([folder_name,'/ROC/ROC.mat'])

%AUC2x2=trapz([0;PFA2x2;1],[0;PD2x2;1]);
%AUC2x2_median=trapz([0;PFA2x2_median;1],[0;PD2x2_median;1]);
%AUC2x2_mean=trapz([0;PFA2x2_mean;1],[0;PD2x2_mean;1]);

%AUC4x4=trapz([0;PFA4x4;1],[0;PD4x4;1]);
%AUC4x4_median=trapz([0;PFA4x4_median;1],[0;PD4x4_median;1]);
%AUC4x4_mean=trapz([0;PFA4x4_mean;1],[0;PD4x4_mean;1]);


AUC8x8=trapz([0;PFA8x8;1],[0;PD8x8;1]);
AUC8x8_median=trapz([0;PFA8x8_median;1],[0;PD8x8_median;1]);
AUC8x8_mean=trapz([0;PFA8x8_mean;1],[0;PD8x8_mean;1]);

%save ([folder_name,'/ROC/AUC.mat'],'AUC2x2','AUC2x2_median','AUC2x2_mean','AUC4x4','AUC4x4_median','AUC4x4_mean','AUC8x8','AUC8x8_median','AUC8x8_mean');
%save ([folder_name,'/ROC/AUC.mat'],'AUC4x4','AUC4x4_median','AUC4x4_mean','AUC8x8','AUC8x8_median','AUC8x8_mean');
save ([folder_name,'/ROC/AUC.mat'],'AUC8x8','AUC8x8_median','AUC8x8_mean');