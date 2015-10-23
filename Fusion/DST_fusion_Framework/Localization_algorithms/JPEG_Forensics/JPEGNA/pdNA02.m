% evaluate pd and pfa from saved statistics
addpath('Z:\Matlab\Forensics\DJPG\biolearning');
pfa1 = 1e-2;
pfa2 = 1e-2;
th_inc = 0.001;
nfold = 5;

JPEGqualities = round(50:50/16:99);

test_sizes = [128, 256, 512, 1024];
% test_sizes = 256;
accuracies_ZFA = zeros(length(test_sizes), length(JPEGqualities));
accuracies_MAX = zeros(length(test_sizes), length(JPEGqualities));

thresholds1 = zeros(length(test_sizes), length(JPEGqualities));
thresholds2 = zeros(length(test_sizes), length(JPEGqualities));

for ts = 1:length(test_sizes)

    load(['results1000/', num2str(test_sizes(ts)), '/NA_feat']);
    pd = zeros(length(JPEGqualities)-1,length(JPEGqualities));
    acc = zeros(length(JPEGqualities)-1,length(JPEGqualities));
    
    % separate classes
%     feat = [NA.features(NA.group == 0,:); NA.features(NA.group == 1,:)];
%     class = [NA.group(NA.group == 0,:); NA.group(NA.group == 1,:)];
%     qf1 = [NA.group_qf1(NA.group == 0,:); NA.group_qf1(NA.group == 1,:)];
%     qf2 = [NA.group_qf2(NA.group == 0,:); NA.group_qf2(NA.group == 1,:)];
%     
    feat = NA.features;
    class = NA.group;
    qf1 = NA.group_qf1;
    qf2 = NA.group_qf2;
    
    for t2 = 1:length(JPEGqualities)
        
        display(['QF2 = ', num2str(JPEGqualities(t2))])
        
        feat_qf2 = feat(qf2 == t2,:);
        class_qf2 = class(qf2 == t2,:);
        qf1_qf2 = qf1(qf2 == t2,:);
        N = size(feat_qf2,1);
    
        for k = 1:nfold
            
            train = true(N,1);
            train(round((k-1)*N/nfold)+1:round(k*N/nfold)) = false;
            
            H1_0 = feat_qf2(train & (class_qf2 == 0), 1);
            H1_1 = feat_qf2(train & (class_qf2 == 1) & (qf1_qf2 ~= t2), 1);
            H2_0 = feat_qf2(train & (class_qf2 == 0), 2);
            H2_1 = feat_qf2(train & (class_qf2 == 1) & (qf1_qf2 == t2), 2);
                                
            th1 = 6;
            while sum(H1_0 < th1)/length(H1_0) > pfa1
                th1 = th1 - th_inc;
            end
            thresholds1(ts, t2) = th1;
            th2 = 6;
            while sum(H2_0 < th2)/length(H2_0) > pfa2
                th2 = th2 - th_inc;
            end
            thresholds2(ts, t2) = th2;

            acc_max = 0;
            thr1_max = 0;
            for thr_tmp = 0:th_inc:6
                acc_tmp = (sum(H1_0 >= thr_tmp)/length(H1_0) + sum(H1_1 < thr_tmp)/length(H1_1)) / 2;
                if acc_max < acc_tmp
                    acc_max = acc_tmp;
                    thr1_max = thr_tmp;
                end
            end

            acc_max = 0;
            thr2_max = 0;
            for thr_tmp = 0:th_inc:6
                acc_tmp = (sum(H2_0 >= thr_tmp)/length(H2_0) + sum(H2_1 < thr_tmp)/length(H2_1)) / 2;
                if acc_max < acc_tmp
                    acc_max = acc_tmp;
                    thr2_max = thr_tmp;
                end
            end
         
            for t1 = 1:length(JPEGqualities)-1
                
                H1_0 = feat_qf2(~train & (class_qf2 == 0), 1);
                H1_1 = feat_qf2(~train & (class_qf2 == 1) & (qf1_qf2 == t1), 1);
                H2_0 = feat_qf2(~train & (class_qf2 == 0), 2);
                H2_1 = feat_qf2(~train & (class_qf2 == 1) & (qf1_qf2 == t1), 2);
                                 
                if t1 == t2
                    pd_tmp = sum(H2_1 < th2)/length(H2_1);
                    acc_max = (sum(H2_0 >= thr2_max)/length(H2_0) + sum(H2_1 < thr2_max)/length(H2_1)) / 2;
                   
                else
                    pd_tmp = sum(H1_1 < th1)/length(H1_1);
                    acc_max = (sum(H1_0 >= thr1_max)/length(H1_0) + sum(H1_1 < thr1_max)/length(H1_1)) / 2;                  
                end
                pd(t1,t2) = pd(t1,t2) + pd_tmp;
                acc(t1,t2) = acc(t1,t2) + acc_max;
            end
        end 
    end
    
    pd = pd/nfold
    acc = acc/nfold

    subs = kron(reshape(1:30,5,6), ones(3,3));
    subs = subs(:,1:16);
    A = accumarray(subs(:), pd(:));
    pd2 = reshape(A/3, 5, 6);
    pd2(:,1:5) = pd2(:,1:5)/3
    
    save(['pdz_', num2str(test_sizes(ts))], 'pd2')

    A = accumarray(subs(:), acc(:));
    acc2 = reshape(A/3, 5, 6);
    acc2(:,1:5) = acc2(:,1:5)/3
    
    save(['acc_', num2str(test_sizes(ts))], 'acc2')
   
    accuracies_ZFA(ts,:) = (mean(pd)+1-pfa1)/2;
    accuracies_MAX(ts,:) = mean(acc);
end

save thresholds thresholds1 thresholds2

figure, plot(JPEGqualities, accuracies_ZFA(1,:), '-+',...
            JPEGqualities, accuracies_ZFA(2,:), '-x',...
            JPEGqualities, accuracies_ZFA(3,:), '-v',...
            JPEGqualities, accuracies_ZFA(4,:), '-^')
grid
axis([50 100 0.5 1])
xlabel('QF_2')
ylabel('accuracy')
legend([num2str(test_sizes(1)),'x',num2str(test_sizes(1))],...
        [num2str(test_sizes(2)),'x',num2str(test_sizes(2))],...
        [num2str(test_sizes(3)),'x',num2str(test_sizes(3))],...
        [num2str(test_sizes(4)),'x',num2str(test_sizes(4))],'Location','SouthEast')

figure, plot(JPEGqualities, accuracies_MAX(1,:), '-+',...
            JPEGqualities, accuracies_MAX(2,:), '-x',...
            JPEGqualities, accuracies_MAX(3,:), '-v',...
            JPEGqualities, accuracies_MAX(4,:), '-^')
grid
axis([50 100 0.5 1])
xlabel('QF_2')
ylabel('accuracy')
legend([num2str(test_sizes(1)),'x',num2str(test_sizes(1))],...
        [num2str(test_sizes(2)),'x',num2str(test_sizes(2))],...
        [num2str(test_sizes(3)),'x',num2str(test_sizes(3))],...
        [num2str(test_sizes(4)),'x',num2str(test_sizes(4))],'Location','SouthEast')