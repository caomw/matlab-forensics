JPEGqualities = round(50:50/16:99);
test_sizes = [128, 256, 512, 1024];
% test_sizes = [128, 256, 128, 256];
accuracies_Q = zeros(length(test_sizes), length(JPEGqualities));
accuracies_kk = zeros(length(test_sizes), length(JPEGqualities));

for ts = 1:length(test_sizes)

    load(['results1000/', num2str(test_sizes(ts)), '/NA_est']);
    %correct mistake in simulations!!!
    perrQ = perrQ * length(JPEGqualities) * (length(JPEGqualities) - 1);
    perrkk = perrkk * length(JPEGqualities) * (length(JPEGqualities) - 1);
    pmiss = pmiss * length(JPEGqualities) * (length(JPEGqualities) - 1);
    
    accuracies_Q(ts,:) = 1 - mean(perrQ(1:end-1,:))./(1 - mean(pmiss(1:end-1,:)));
    accuracies_kk(ts,:) = 1 - mean(perrkk(1:end-1,:))./(1 - mean(pmiss(1:end-1,:)));
end


figure, plot(JPEGqualities, accuracies_Q(1,:), '-+',...
            JPEGqualities, accuracies_Q(2,:), '-x',...
            JPEGqualities, accuracies_Q(3,:), '-v',...
            JPEGqualities, accuracies_Q(4,:), '-^')
grid
axis([50 100 0.5 1])
xlabel('QF_2')
ylabel('accuracy')
legend([num2str(test_sizes(1)),'x',num2str(test_sizes(1))],...
        [num2str(test_sizes(2)),'x',num2str(test_sizes(2))],...
        [num2str(test_sizes(3)),'x',num2str(test_sizes(3))],...
        [num2str(test_sizes(4)),'x',num2str(test_sizes(4))],'Location','SouthEast')

figure, plot(JPEGqualities, accuracies_kk(1,:), '-+',...
            JPEGqualities, accuracies_kk(2,:), '-x',...
            JPEGqualities, accuracies_kk(3,:), '-v',...
            JPEGqualities, accuracies_kk(4,:), '-^')
grid
axis([50 100 0.5 1])
xlabel('QF_2')
ylabel('accuracy')
legend([num2str(test_sizes(1)),'x',num2str(test_sizes(1))],...
        [num2str(test_sizes(2)),'x',num2str(test_sizes(2))],...
        [num2str(test_sizes(3)),'x',num2str(test_sizes(3))],...
        [num2str(test_sizes(4)),'x',num2str(test_sizes(4))],'Location','SouthEast')