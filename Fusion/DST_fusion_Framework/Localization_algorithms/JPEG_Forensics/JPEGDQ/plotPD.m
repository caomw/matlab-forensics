
load testDQoutputSCF_EM

PFA = 5e-2;
QF2 = 50:5:100;
c2Y = [1 3 6 10 15];
[NC, NQF1, NQF2, NROC] = size(FPmat);
PDcurve = zeros(NC,NQF2);
PDcurve_c = zeros(NC,NQF2);
PDcurve_s = zeros(NC,NQF2);

% integrate over QF1
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
        % find PD @ given PFA
        k = 1;
        while FPmat2(c,qf2,k) <= PFA
            k = k + 1;
        end
        PDcurve(c,qf2) = TPmat2(c,qf2,k-1);
        k = 1;
        while FPmat2_c(c,qf2,k) <= PFA
            k = k + 1;
        end
        PDcurve_c(c,qf2) = TPmat2_c(c,qf2,k-1);
        k = 1;
        while FPmat2_s(c,qf2,k) <= PFA
            k = k + 1;
        end
        PDcurve_s(c,qf2) = TPmat2_s(c,qf2,k-1);
    end
end


figure, plot(QF2, PDcurve(1,:), '+-', QF2, PDcurve(2,:), 'x-', QF2, PDcurve(3,:), 'v-', QF2, PDcurve(4,:), '^-', QF2, PDcurve(5,:), 'o-')
axis([50 100 0 1])
grid
xlabel('QF_2')
ylabel('P_D')
legend('1 coeff.', '3 coeff.', '6 coeff.', '10 coeff.', '15 coeff.','Location','NorthWest')

figure, plot(QF2, PDcurve_c(1,:), '+-', QF2, PDcurve_c(2,:), 'x-', QF2, PDcurve_c(3,:), 'v-', QF2, PDcurve_c(4,:), '^-', QF2, PDcurve_c(5,:), 'o-')
axis([50 100 0 1])
grid
xlabel('QF_2')
ylabel('P_D')
legend('1 coeff.', '3 coeff.', '6 coeff.', '10 coeff.', '15 coeff.','Location','NorthWest')

figure, plot(QF2, PDcurve_s(1,:), '+-', QF2, PDcurve_s(2,:), 'x-', QF2, PDcurve_s(3,:), 'v-', QF2, PDcurve_s(4,:), '^-', QF2, PDcurve_s(5,:), 'o-')
axis([50 100 0 1])
grid
xlabel('QF_2')
ylabel('P_D')
legend('1 coeff.', '3 coeff.', '6 coeff.', '10 coeff.', '15 coeff.','Location','NorthWest')
