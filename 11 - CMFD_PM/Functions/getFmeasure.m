function [FM,measure] = getFmeasure(value,gt)
%compute the F-measure
% [FM,ret] = getFmeasure(map,gt)
%

    if ischar(value), value = imread(value)>0; end;
    if ischar(gt)   , gt = imread(gt); end;

    gt    = gt(:);
    value = value(:);
    gt1   = (gt==max(gt));
    gt0   = (gt==0);

    measure =	struct();
    measure.N_TP = sum(    value  & gt1);
    measure.N_TN = sum(not(value) & gt0);
    measure.N_FP = sum(    value  & gt0);
    measure.N_FN = sum(not(value) & gt1);
    
    measure.FM  = 2* measure.N_TP./(measure.N_TP+measure.N_FP+measure.N_TP+measure.N_FN);
    measure.TPR = measure.N_TP./(measure.N_TP+measure.N_FN); % = sensitivity = recall
    measure.TNR = measure.N_TN./(measure.N_TN+measure.N_FP); % = specificity
    measure.FPR = measure.N_FN./(measure.N_TP+measure.N_FN); % = 1-sensitivity 
    measure.FNR = measure.N_FP./(measure.N_TN+measure.N_FP); % = 1-specificity = false alarm rate
    measure.PPV = measure.N_TP./(measure.N_TP+measure.N_FP); % = precision  
    measure.NPV = measure.N_TN./(measure.N_TN+measure.N_FN); 
    
    FM = measure.FM;