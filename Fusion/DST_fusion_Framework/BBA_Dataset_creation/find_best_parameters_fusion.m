function [ bestNN best_gamma best_alpha fusion_grid] = find_best_parameters_fusion(trainset,label)
%This function implements the grid search on the trainset.
%The best NN, gamma, and alpha are calculated.
    bestNN = 0; best_gamma=0; best_alpha=0;
    nfold=5;
    number_of_elements_per_fold=length(label)/nfold;
    permutation=randperm(length(label));
        
    trainset=trainset(permutation,:);
    label=label(permutation);
    max_accuracy=0;
    k=1;    

    for neighbors=[4 8 12]
        for log2gamma = -1:2:11
            %ATTENTION the value alpha is fixed at 0.85
            for alpha=0.85                 
                acc_tmp=0;
                for i=1:nfold   
                    %Two sets are generated starting from the trainset
                    %matrix according to the 5-cross fold validation
                    if(i==1)            
                        train=trainset(number_of_elements_per_fold+1:end,:);
                        train_label=label(number_of_elements_per_fold+1:end);
                        test=trainset(1:number_of_elements_per_fold,:);
                        test_label=label(1:number_of_elements_per_fold);

                    else           
                        train=[trainset(1:(number_of_elements_per_fold*(i-1)),:);trainset(number_of_elements_per_fold*i+1:end,:)];
                        train_label=label(number_of_elements_per_fold+1:end);
                        test=trainset((number_of_elements_per_fold*(i-1))+1:number_of_elements_per_fold*i,:);
                        test_label=label((number_of_elements_per_fold*(i-1))+1:number_of_elements_per_fold*i);
                    end
                    for j=1:length(test_label)    
                        [KNN_neighbors] = findNeighbors(train(:,1:5), train_label, test(j,1:5), neighbors);
                        [beliefTamp beliefOrig doubt] = DST_BBA_by_query_noKNN_simplified_v2(test(j,1:5),KNN_neighbors(:,1:6),2^log2gamma,alpha);
                        if(beliefTamp>beliefOrig)
                            label_to_verify=1;
                        else     
                            label_to_verify=0;
                        end
                        acc_tmp=acc_tmp+(test_label(j)==label_to_verify);                    
                    end
                end
                acc_tmp=acc_tmp/(length(test_label)*nfold);
                fusion_grid.NN(k) = neighbors;
                fusion_grid.gamma(k) = 2^log2gamma;
                fusion_grid.retained_accur(k) = acc_tmp;
                k=k+1;
                if(acc_tmp>max_accuracy)
                    max_accuracy=acc_tmp;
                    bestNN=neighbors;
                    best_gamma=2^log2gamma;
                    best_alpha=alpha;
                end
                fprintf('KNN=%f gamma=%f alpha=%f acc=%f (best KNN=%f, gamma=%f, alpha=%f, rate=%f)\n', neighbors, log2gamma, alpha, acc_tmp, bestNN, best_gamma, best_alpha,max_accuracy);
            end
        end
    end

end

