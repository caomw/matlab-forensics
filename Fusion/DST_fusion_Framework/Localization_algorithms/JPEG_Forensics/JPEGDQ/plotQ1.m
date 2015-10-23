mask = logical(toeplitz(zeros(1,11), [0 ones(1,10)]))
% mask = logical(toeplitz([0 ones(1,2) zeros(1,8)], [0 ones(1,10)]))

load testDQoutputSCF_EM

% Q1err_SCF = squeeze(mean(mean(Q1err,1),2));
for k = 1:15
    A = Q1err(:,:,k);
    Q1err_SCF(k) = mean(A(mask));
end

load testDQoutputDCF_EM

% Q1err_DCF = squeeze(mean(mean(Q1err,1),2));
for k = 1:15
    A = Q1err(:,:,k);
    Q1err_DCF(k) = mean(A(mask));
end

load testDQoutputFFF_EM

% Q1err_FFF = squeeze(mean(mean(Q1err,1),2));
for k = 1:15
    A = Q1err(:,:,k);
    Q1err_FFF(k) = mean(A(mask));
end

coeff = 1:15;

figure, plot(coeff, Q1err_SCF, '+-', coeff, Q1err_FFF, 'x-', coeff, Q1err_DCF, 'o-')
axis([1 15 0 1])
grid
xlabel('DCT coefficient')
ylabel('P_e')
legend('15/16','1/2','1/16','Location','NorthWest')