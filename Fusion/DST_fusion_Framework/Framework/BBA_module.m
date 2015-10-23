function [ mT mN mD ] = BBA_module(training,labels,test,NN,gamma,alpha)
%BBA module. It searches for the NN neighbors and calculates the BBA of the
%test starting from them. 
%mT is the mass for Tampering
%mN is the mass for Non Tampering
%mD is the mass for doubt
    [neighbors] = findNeighbors(training, labels, test, NN);
    [mT mN mD] = DST_BBA_by_query_noKNN_simplified_v2(test,neighbors(:,1:end-1),gamma,alpha);
end

