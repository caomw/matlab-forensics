function [XT, XN, XTN] = DST_BBA_by_query_noKNN(to_be_classified, training_array, training_model, forensic_algorithm)
%function [XT, XN, XTN] = DST_BBA_by_query_noKNN(to_be_classified, training_array, training_model, forensic_algorithm)
%
%This function implements the approach describer in [1] to classify in
%using basic belief assignments a given sample basing on a set of training
%samples. Three values are returned: the mass for the sample belonging to
%class T, the mass for the sample belonging to class N and the mass for
%the doubt TN.
%
%--- INPUT PARAMS ---
%-> to_be_classified: (scalar value) the sample to be classified
%-> training_array: N-by-3 array with training samples. The first column
%   must contain sample values and the second column must contain ground truth
%   labels (0 means class N, 1 means class T).
%   Example:
%   [0.1123     0;
%    0.1892     0;
%    0.8991     1]
%   The third column is OPTIONAL, and can contain the Quality Factor of the
%   image. If this info is available, it can be used to dinamycally weigth
%   each training sample by the reliability of specified forensic_algorithm
%-> training_model: Dempster-Shafer model (obtained by parsing a .mod file)
%   specifying the list of elementary propositions that defines the frame
%   of discernment.
%   You should try with modelParser('training.mod');
%-> [OPTIONAL] forensic_algorithm: the name (one between A B C D and E) of the
%   considered forensic algorithm
%
%--- OUTPUT PARAMS ---
%-> XT: mass for the sample belonging to class T
%-> XN: mass for the sample belonging to class N
%-> XTN: mass for the doubt
%
%--- Usage Example ---
%addpath(genpath('DStheory'));
%train =%   [0.1123     0;    0.1892     0;    0.8991     1]
%test = 0.107;
%[beliefTamp beliefOrig doubt] = DST_BBA_by_query_noKNN(test,train,modelParser('training.mod'));

    use_adaptive_alfa = false;
    
    if ~use_adaptive_alfa
        alfa = 0.8;
    end
    
    gammaT = 70;
    gammaN = 70;
    
    if size(training_array,2)==3 && nargin>3
        nh = sortrows([ training_array(:,1) training_array(:,2) get_tool_reliability(training_array(:,3),forensic_algorithm)],1);        
    else
        nh = sortrows([ training_array(:,1) training_array(:,2)],1);        
    end
    
        %generate BBAs
        BBA = struct('K',{},'assignments',{},'model',{});
        %         BBAtot = struct('K',{},'assignments',{},'model',{});
        %         BBA(k).name=['BBAforVal:',num2str(v)];
        %         BBA(k).modelFile='training.mod';
        %         BBA(k).model = trainModel;
        %         BBA(k).K = 0;
        for n=1:size(nh,1)
            BBA(n).name='void';
            BBA(n).modelFile='training.mod';
            BBA(n).model = training_model;
            BBA(n).K = 0;
            if use_adaptive_alfa
                assert((nargin>3 && size(training_array,2)==3)  ,'Adaptive alpha is available only if you specify the name of the algorithm and the quality factor of each training sample\n.');
                alfa = nh(n,3);
            end
            if nh(n,2)==1 %if sample belongs to forged class
                mass = alfa*exp(-gammaT*abs(to_be_classified-nh(n,1)));
                BBA(n).assignments{1,1} = '10';
                BBA(n).assignments{1,2} = sym(mass);
                BBA(n).assignments{2,1} = '11';
                BBA(n).assignments{2,2} = sym(1)-mass;
            else %if sample belongs to untouched class
                mass = alfa*exp(-gammaN*abs(to_be_classified-nh(n,1)));
                BBA(n).assignments{1,1} = '01';
                BBA(n).assignments{1,2} = sym(mass);
                BBA(n).assignments{2,1} = '11';
                BBA(n).assignments{2,2} = sym(1)-mass;
            end
            if n==1
                BBAtot = BBA(1);
            else
                BBAold = BBAtot;
                BBAtot = SimbOrthogonalSum(BBAold,BBA(n));
            end
        end
        XT=0; XN=0; XTN=0;
        for z=1:size(BBAtot.assignments(:,1))
           switch BBAtot.assignments{z,1}
               case '10'
                   XTt = BBAtot.assignments{z,2};
                   XT = XTt.double;
               case '01'
                   XNt = BBAtot.assignments{z,2};
                   XN = XNt.double;
               case '11'
                   XTNt = BBAtot.assignments{z,2};
                   XTN = XTNt.double;
           end
        end
        if (1-(XT+XN+XTN))>0.01
            warning('Something is wrong, masses did not sum to 1 but to %.3f.',XT+XN+XTN); %#ok<*WNTAG>
        end        
        
end

