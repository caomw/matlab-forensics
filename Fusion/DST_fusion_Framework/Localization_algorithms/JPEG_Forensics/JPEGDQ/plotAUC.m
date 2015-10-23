
% load testDQoutputSCF_EM
% load testDQoutputDCF_EM
% load testDQoutputFFF_EM
load ../JPEGNA/testDQNAoutputFFF_EM

PFA = 5e-2;
QF2 = 50:5:100;
c2Y = [1 3 6 10 15];
[NC, NQF1, NQF2, NROC] = size(FPmat);
AUCcurve = zeros(NC,NQF2);
AUCcurve_c = zeros(NC,NQF2);
AUCcurve_s = zeros(NC,NQF2);

% integrate over QF1 (50:5:95)
FPmat2 = squeeze(sum(FPmat(:,1:NQF1-1,:,:),2))/(NQF1-1);      
FPmat2_c = squeeze(sum(FPmat_c(:,1:NQF1-1,:,:),2))/(NQF1-1);                 
FPmat2_s = squeeze(sum(FPmat_s(:,1:NQF1-1,:,:),2))/(NQF1-1);                 
TPmat2 = squeeze(sum(TPmat(:,1:NQF1-1,:,:),2))/(NQF1-1);                 
TPmat2_c = squeeze(sum(TPmat_c(:,1:NQF1-1,:,:),2))/(NQF1-1); 
TPmat2_s = squeeze(sum(TPmat_s(:,1:NQF1-1,:,:),2))/(NQF1-1); 

% for qf1 = 1:NQF1
%     figure, plot(squeeze(FPmat_s(1,qf1,11,:)),squeeze(TPmat_s(1,qf1,11,:)))
%     figure, plot(squeeze(FPmat(1,qf1,11,:)),squeeze(TPmat(1,qf1,11,:)))
%     figure, plot(squeeze(FPmat_c(1,qf1,11,:)),squeeze(TPmat_c(1,qf1,11,:)))
% end
% pause

for c = 1:NC
    for qf2 = 1:NQF2
        % find AUC
        AUCcurve(c,qf2) = trapz(squeeze(FPmat2(c,qf2,:)), squeeze(TPmat2(c,qf2,:)));
        AUCcurve_c(c,qf2) = trapz(squeeze(FPmat2_c(c,qf2,:)), squeeze(TPmat2_c(c,qf2,:)));
        AUCcurve_s(c,qf2) = trapz(squeeze(FPmat2_s(c,qf2,:)), squeeze(TPmat2_s(c,qf2,:)));
    end
end


figure, plot(QF2, AUCcurve(1,:), '+-', QF2, AUCcurve(2,:), 'x-', QF2, AUCcurve(3,:), 'v-', QF2, AUCcurve(4,:), '^-', QF2, AUCcurve(5,:), 'o-')
axis([50 100 0.5 1])
grid
xlabel('QF_2')
ylabel('AUC')
legend('1 coeff.', '3 coeff.', '6 coeff.', '10 coeff.', '15 coeff.','Location','NorthWest')

figure, plot(QF2, AUCcurve_c(1,:), '+-', QF2, AUCcurve_c(2,:), 'x-', QF2, AUCcurve_c(3,:), 'v-', QF2, AUCcurve_c(4,:), '^-', QF2, AUCcurve_c(5,:), 'o-')
axis([50 100 0.5 1])
grid
xlabel('QF_2')
ylabel('AUC')
legend('1 coeff.', '3 coeff.', '6 coeff.', '10 coeff.', '15 coeff.','Location','NorthWest')

figure, plot(QF2, AUCcurve_s(1,:), '+-', QF2, AUCcurve_s(2,:), 'x-', QF2, AUCcurve_s(3,:), 'v-', QF2, AUCcurve_s(4,:), '^-', QF2, AUCcurve_s(5,:), 'o-')
axis([50 100 0.5 1])
grid
xlabel('QF_2')
ylabel('AUC')
legend('1 coeff.', '3 coeff.', '6 coeff.', '10 coeff.', '15 coeff.','Location','NorthWest')
