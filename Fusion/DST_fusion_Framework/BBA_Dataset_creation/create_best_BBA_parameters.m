%This script creates the matrix for the BBA modules based on the previously
%calculated fold. Through a grid search, this file also finds the parameters gamma and the number of
%Nearest Neighbor needed by the BBA modules. These values are saved in
%best_fusion_parameter.mat

%sample step of the quality factor JPEG. The values are
%[50,60,70,80,90,100] for AJPEG and NAJPEG algorithms and
%[50,60,70,80,90,100,inf] for CFA.
qstep=10;


if ispc
    datasetdir='dataset\';
    ajpegdir='AJPEG\';
    najpegdir='NAJPEG\';
    cfadir='CFA\';
    datadir='DATA\'; 
    slash='\'; 
    addpath('..\utils\');
else
	datasetdir='dataset/';    
    ajpegdir='AJPEG/';
    najpegdir='NAJPEG/';
    cfadir='CFA/';
    datadir='DATA/';
    slash='/';  
    addpath('../utils/');
end    

vector=50:qstep:100;    
vector_cfa=[0 vector];
%number of fold
nfold=5;
j=1;

%matrices needed for the training and the testing of the dataset
train_cfa=0;
train_na=0;
train_a=0;

test_cfa=0;
test_na=0;
test_a=0;


%creation of those matrices
for i=1:length(vector_cfa)    
    [train test]=generate_train_test([datasetdir cfadir datadir],'CFA',vector_cfa(i),nfold,j);   
    if(i==1)
        train_cfa=[train];    
        test_cfa=[test];
    else
        train_cfa=[train_cfa;train];    
        test_cfa=[test_cfa;test];
    end
end

 for i=1:length(vector)              
    [train test]=generate_train_test([datasetdir ajpegdir datadir],'AJPEG',vector(i),nfold,j); 
    if(i==1)
        train_a=[train];    
        test_a=[test];
    else
        train_a=[train_a;train];    
        test_a=[test_a;test];
    end
 end

for i=1:length(vector)           
    [train test]=generate_train_test([datasetdir najpegdir datadir],'NAJPEG',vector(i),nfold,j);     
    if(i==1)
        train_na=[train];    
        test_na=[test];
    else
        train_na=[train_na;train];    
        test_na=[test_na;test];
    end
end


%the values are normalized in the [0,1] interval
train_a=normalize_matrix(train_a);
train_na=normalize_matrix(train_na);
train_cfa=normalize_matrix(train_cfa);

test_a=normalize_matrix(test_a);
test_na=normalize_matrix(test_na);
test_cfa=normalize_matrix(test_cfa);

%search for best KNN and gamma for every BBA modules
[ bestNN_cfa best_gamma_cfa best_alpha_cfa fusion_grid_cfa] = find_best_parameters_fusion(train_cfa(:,1:5),train_cfa(:,6));
[ bestNN_a best_gamma_a best_alpha_a fusion_grid_a] = find_best_parameters_fusion(train_a(:,1:5),train_a(:,6));
[ bestNN_na best_gamma_na best_alpha_na fusion_grid_na] = find_best_parameters_fusion(train_na(:,1:5),train_na(:,6));

%the best values are saved in the data structure best_fusion_parameter.mat
save best_fusion_parameter.mat bestNN_cfa best_gamma_cfa best_alpha_cfa bestNN_a best_gamma_a best_alpha_a bestNN_na best_gamma_na best_alpha_na fusion_grid_a fusion_grid_cfa fusion_grid_na

%the training matrices form the 3 matrices where the BBA modules find the
%neighbor
ajpeg_tables=train_a;
najpeg_tables=train_na;
cfa_tables=train_cfa;

%ATTENTION it is necessary to invert the label for CFA matrix, otherwise
%the Framework cannot work properly.
index_pos=cfa_tables(:,6)==1;
index_neg=cfa_tables(:,6)==0;
cfa_tables(index_pos,6)=0;
cfa_tables(index_neg,6)=1;

%remove the first quality factor (not needed for AJPEG and NAJPEG
%algorithms)
ajpeg_tables=ajpeg_tables(:,2:end);
najpeg_tables=najpeg_tables(:,2:end);

save tables.mat cfa_tables ajpeg_tables najpeg_tables;


%calculate the accurancy of testset
acc_tmp=0;

for k=1:size(test_cfa,1)
    [neighbors_cfa] = findNeighbors(train_cfa(:,1:5), train_cfa(:,6), test_cfa(k,1:5), bestNN_cfa);
    [beliefTamp beliefOrig doubt] = DST_BBA_by_query_noKNN_simplified_v2(test_cfa(k,1:5),neighbors_cfa(:,1:6),best_gamma_cfa,best_alpha_cfa);
    if(beliefTamp>0.5)
        label=1;
    else
        label=0;
    end
    acc_tmp=acc_tmp+(label==test_cfa(k,6));
end
fprintf('CFA accurancy max=%f\n',acc_tmp/(size(test_cfa,1)));

acc_tmp=0;

for k=1:size(test_a,1)
    [neighbors_a] = findNeighbors(train_a(:,1:5), train_a(:,6), test_a(k,1:5), bestNN_a);
    [beliefTamp beliefOrig doubt] = DST_BBA_by_query_noKNN_simplified_v2(test_a(k,1:5),neighbors_a(:,1:6),best_gamma_a,best_alpha_a);
    if(beliefTamp>0.5)
        label=1;
    else
        label=0;
    end
    acc_tmp=acc_tmp+(label==test_a(k,6));
end
fprintf('AJPEG accurancy max=%f\n',acc_tmp/(size(test_a,1)));


acc_tmp=0;

for k=1:size(test_na,1)
    [neighbors_na] = findNeighbors(train_na(:,1:5), train_na(:,6), test_na(k,1:5), bestNN_na);
    [beliefTamp beliefOrig doubt] = DST_BBA_by_query_noKNN_simplified_v2(test_na(k,1:5),neighbors_na(:,1:6),best_gamma_na,best_alpha_na);
    if(beliefTamp>0.5)
        label=1;
    else
        label=0;
    end
    acc_tmp=acc_tmp+(label==test_na(k,6));
end
fprintf('NAJPEG accurancy max=%f\n',acc_tmp/(size(test_na,1)));

