function [trainset,testset]=generate_train_test(path,type,q2,number_of_fold,index_of_test_set)
    %This function generates 2 sets: trainset and dataset from the
    %number_of_fold previously generated.
    load([path 'data_array_' type '_' num2str(q2) '_nfold_' num2str(number_of_fold) '.mat']);
    [row col]=size(data_array);
    trainset=zeros(row*(number_of_fold-1),col);
    testset=zeros(row,col);
    count=1;
    for i=1:number_of_fold
        load([path 'data_array_' type '_' num2str(q2) '_nfold_' num2str(i) '.mat']);       
        index=isnan(data_array);
        data_array(index)=1;
        if(i==index_of_test_set)
            testset=data_array;
        else        
            shift=(count-1)*row;
            trainset(1+shift:row+shift,:)=data_array;
            count=count+1;
        end            
    end
    
end