scenario = (1:1:6)';
tab = [];

figure;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('/users/ferrara/Desktop/Simulazioni2x2/Sintetiche_128/ROC/AUC.mat');
tab(1,1) = AUC8x8;
tab(1,2) = AUC8x8_mean;
tab(1,3) = AUC8x8_median;

load('/users/ferrara/Desktop/Simulazioni2x2/TIFF_128/ROC/AUC.mat');
tab(2,1) = AUC8x8;
tab(2,2) = AUC8x8_mean;
tab(2,3) = AUC8x8_median;

load('/users/ferrara/Desktop/Simulazioni2x2/JPEG100_128/ROC/AUC.mat');
tab(3,1) = AUC8x8;
tab(3,2) = AUC8x8_mean;
tab(3,3) = AUC8x8_median;

load('/users/ferrara/Desktop/Simulazioni2x2/JPEG95_128/ROC/AUC.mat');
tab(4,1) = AUC8x8;
tab(4,2) = AUC8x8_mean;
tab(4,3) = AUC8x8_median;

load('/users/ferrara/Desktop/Simulazioni2x2/JPEG90_128/ROC/AUC.mat');
tab(5,1) = AUC8x8;
tab(5,2) = AUC8x8_mean;
tab(5,3) = AUC8x8_median;

load('/users/ferrara/Desktop/Simulazioni2x2/JPEG85_128/ROC/AUC.mat');
tab(6,1) = AUC8x8;
tab(6,2) = AUC8x8_mean;
tab(6,3) = AUC8x8_median;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(scenario,tab(:,1),'Color','b','LineWidth',1,'Marker','o');
hold
plot(scenario,tab(:,2),'Color','r','LineWidth',1,'Marker','s');
plot(scenario,tab(:,3),'Color','g','LineWidth',1,'Marker','x');

legend('No filtering','Mean filtering','Median Filtering','Location', 'NorthEast');
xlabel('Scenario');
ylabel('AUC');
