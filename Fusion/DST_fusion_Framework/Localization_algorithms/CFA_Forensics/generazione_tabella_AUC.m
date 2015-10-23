scenario = (1:1:6)';
tab = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('/users/ferrara/Desktop/Simulazioni4x4/Sintetiche_128/ROC/AUC.mat');
tab(1,1) = AUC4x4;


load('/users/ferrara/Desktop/Simulazioni4x4/TIFF_128/ROC/AUC.mat');
tab(2,1) = AUC4x4;


load('/users/ferrara/Desktop/Simulazioni4x4/JPEG100_128/ROC/AUC.mat');
tab(3,1) = AUC4x4;


load('/users/ferrara/Desktop/Simulazioni4x4/JPEG95_128/ROC/AUC.mat');
tab(4,1) = AUC4x4;


load('/users/ferrara/Desktop/Simulazioni4x4/JPEG90_128/ROC/AUC.mat');
tab(5,1) = AUC4x4;


load('/users/ferrara/Desktop/Simulazioni4x4/JPEG85_128/ROC/AUC.mat');
tab(6,1) = AUC4x4;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save tabellaAUC4x4.m tab