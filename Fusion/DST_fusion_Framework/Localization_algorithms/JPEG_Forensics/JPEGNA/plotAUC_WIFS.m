
% load testNAoutputSCF_EM
% load testNAoutputDCF_EM
load testNAoutputFFF_EM

PFA = 5e-2;
QF2 = 50:10:100;
c2Y = [1 3 6 10 15];
[NC, NQF1, NQF2, NROC] = size(FPmat);
AUCcurve = zeros(NC,NQF2);
AUCcurve_s = zeros(NC,NQF2);

% integrate over QF1 (50:5:95)
FPmat2 = squeeze(sum(FPmat(:,1:NQF1-1,:,:),2))/(NQF1-1);                      
FPmat2_s = squeeze(sum(FPmat_s(:,1:NQF1-1,:,:),2))/(NQF1-1);                 
TPmat2 = squeeze(sum(TPmat(:,1:NQF1-1,:,:),2))/(NQF1-1);                 
TPmat2_s = squeeze(sum(TPmat_s(:,1:NQF1-1,:,:),2))/(NQF1-1); 

% for qf1 = 1:NQF1
%     figure, plot(squeeze(FPmat_s(1,qf1,11,:)),squeeze(TPmat_s(1,qf1,11,:)))
%     figure, plot(squeeze(FPmat(1,qf1,11,:)),squeeze(TPmat(1,qf1,11,:)))
%     figure, plot(squeeze(FPmat_c(1,qf1,11,:)),squeeze(TPmat_c(1,qf1,11,:)))
% end
% pause

for c = 1:2:NC
    for qf2 = 1:2:NQF2
        % find AUC
        AUCcurve(c,qf2) = trapz(squeeze(FPmat2(c,qf2,:)), squeeze(TPmat2(c,qf2,:)));
        AUCcurve_s(c,qf2) = trapz(squeeze(FPmat2_s(c,qf2,:)), squeeze(TPmat2_s(c,qf2,:)));
    end
end


figure, plot(QF2, AUCcurve(1,1:2:end), '+-', QF2, AUCcurve(3,1:2:end), 'x-', QF2, AUCcurve(5,1:2:end), 'o-')
axis([50 100 0.5 1])
grid
xlabel('QF_2')
ylabel('AUC')
legend('1 coeff.', '6 coeff.', '15 coeff.','Location','NorthWest')

figure, plot(QF2, AUCcurve_s(1,1:2:end), '+-', QF2, AUCcurve_s(3,1:2:end), 'x-', QF2, AUCcurve_s(5,1:2:end), 'o-')
axis([50 100 0.5 1])
grid
xlabel('QF_2')
ylabel('AUC')
legend('1 coeff.', '6 coeff.', '15 coeff.','Location','NorthWest')
