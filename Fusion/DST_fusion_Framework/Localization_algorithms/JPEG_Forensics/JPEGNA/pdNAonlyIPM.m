
pfa1 = 5e-6;
pfa2 = 5e-6;
th_inc = 0.01;
nfiles = 100;


JPEGqualities = round(50:50/16:99);
pd = zeros(length(JPEGqualities));
acc = zeros(length(JPEGqualities));
% pdfix = zeros(length(JPEGqualities));
% pfafix = zeros(length(JPEGqualities));
% eer = zeros(length(JPEGqualities));

test_sizes = [128, 256, 512, 1024];
accuracies_ZFA = zeros(length(test_sizes), length(JPEGqualities));
accuracies_MAX = zeros(length(test_sizes), length(JPEGqualities));

thresholds1 = zeros(length(test_sizes), length(JPEGqualities));
thresholds2 = zeros(length(test_sizes), length(JPEGqualities));

for ts = 1:length(test_sizes)

    load(['statNAout_', num2str(test_sizes(ts))]);

    for t2 = 1:length(JPEGqualities)
        th1 = 6;
        while sum(minH1_0(t2,1:nfiles) < th1)/nfiles > pfa1
            th1 = th1 - th_inc;
        end
        thresholds1(ts, t2) = th1;
%         th2 = 6;
%         while sum(minH2_0(t2,1:nfiles) < th2)/nfiles > pfa2
%             th2 = th2 - th_inc;
%         end
%         thresholds2(ts, t2) = th2;
%     end
% end

% save thresholds thresholds1 thresholds2

    %     th1_eer = 6;
    %     while sum(minH1_0(t2,1:nfiles) < th1_eer)/nfiles > sum(sum(minH1_1(t2,:,1:nfiles) > th1_eer))/(nfiles*length(JPEGqualities))
    %         th1_eer = th1_eer - th_inc;
    %     end
    %     th2_eer = 6;
    %     while sum(minH2_0(t2,1:nfiles) < th2_eer)/nfiles > sum(minH2_1(t2,1:nfiles) > th2_eer)/nfiles
    %         th2_eer = th2_eer - th_inc;
    %     end
    %     
    %     JPEGqualities(t2)
    %     th1
    %     th2
    %     th1_eer = 4;
    %     th2_eer = 2.5;
        for t1 = 1:length(JPEGqualities)
            if t1 == t2
                pd(t1,t2) = sum(minH1_0(t1,nfiles+1:2*nfiles) < th1)/nfiles;
    %             pdfix(t1,t2) = sum(minH1_0(t1,nfiles+1:2*nfiles) >= th1_eer)/nfiles * sum(minH2_1(t1,1:nfiles) < th2_eer)/nfiles;
    %             pfafix(t1,t2) = sum(minH1_0(t1,nfiles+1:2*nfiles) < th1_eer)/nfiles + sum(minH1_0(t1,nfiles+1:2*nfiles) >= th1_eer)/nfiles * sum(minH2_0(t1,1:nfiles) < th2_eer)/nfiles;
    %             th2_eer = 6;
    %             while sum(minH2_0(t2,1:nfiles) < th2_eer)/nfiles > sum(minH2_1(t2,1:nfiles) >= th2_eer)/nfiles
    %                 th2_eer = th2_eer - th_inc;
    %             end
    %             acc(t1,t2) = (sum(minH2_0(t2,1:nfiles) >= th2_eer) + sum(minH2_1(t2,1:nfiles) < th2_eer)) / (2*nfiles);
                acc_max = 0;
                for thr_max = 0:th_inc:6
                    acc_tmp = (sum(minH1_0(t2,1:nfiles) >= thr_max) + sum(minH1_0(t1,nfiles+1:2*nfiles) < thr_max)) / (2*nfiles);
                    if acc_max < acc_tmp
                        acc_max = acc_tmp;
                    end
                end
                acc(t1,t2) = acc_max;
            else
                pd(t1,t2) = sum(squeeze(minH1_1(t1,t2,1:nfiles) < th1))/nfiles;
    %             pdfix(t1,t2) = sum(squeeze(minH1_1(t1,t2,1:nfiles) < th1_eer))/nfiles;
    %             pfafix(t1,t2) = sum(squeeze(minH1_0(t2,1:nfiles) < th1_eer))/nfiles;
    %             th1_eer = 6;
    %             while sum(minH1_0(t2,1:nfiles) < th1_eer)/nfiles > sum(squeeze(minH1_1(t1,t2,1:nfiles) >= th1_eer))/nfiles
    %                 th1_eer = th1_eer - th_inc;
    %             end
    %             acc(t1,t2) = (sum(minH1_0(t2,1:nfiles) >= th1_eer) + sum(squeeze(minH1_1(t1,t2,1:nfiles) < th1_eer))) / (2*nfiles);
                acc_max = 0;
                for thr_max = 0:th_inc:6
                    acc_tmp = (sum(minH1_0(t2,1:nfiles) >= thr_max) + sum(squeeze(minH1_1(t1,t2,1:nfiles) < thr_max))) / (2*nfiles);
                    if acc_max < acc_tmp
                        acc_max = acc_tmp;
                    end
                end
                acc(t1,t2) = acc_max;
            end
        end 
    end

    subs = kron(reshape(1:30,5,6), ones(3,3));
    subs = [subs(:,1:16); 31*ones(1,16)];
    A = accumarray(subs(:), pd(:));
    pd2 = reshape(A(1:end-1)/3, 5, 6);
    pd2(:,1:5) = pd2(:,1:5)/3
    
    save(['pdz_only_IPM_', num2str(test_sizes(ts))], 'pd2')

    A = accumarray(subs(:), acc(:));
    acc2 = reshape(A(1:end-1)/3, 5, 6);
    acc2(:,1:5) = acc2(:,1:5)/3
    
    save(['acc_only_IPM_', num2str(test_sizes(ts))], 'acc2')
   
    accuracies_ZFA(ts,:) = (mean(pd(1:end-1,:))+1)/2;
    accuracies_MAX(ts,:) = mean(acc(1:end-1,:));
end

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