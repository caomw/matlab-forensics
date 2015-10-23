function[neighbors] = findNeighbors(training, classes, test, K)
%Find the nearest K elements of test in training.
%
%--- INPUT ARGS ---
%-> training: N-by-DIM matrix where DIM is the dimension of each training
%             vector and N is the total number of training vectors.
%-> classes: 1-by-N binary vector, that contains the classes of each training example
%
%-> test: 1-by-DIM vector whose neighbors we are searching for.
%-> K:   The number of neighbors to find
%
%--- OUTPUT ARGS ---
%-> neighbors: K-by-(size(training,2)+2) matrix. The j-th row refers to the
%j-th neighbor and contains:
%   for the first size(training,2) elements -> the value of j
%   for the element size(training,2)+1 -> the class of the j-th neighbor
%   for the element size(training,2)+2 -> the Euclidean distance between the j-th neighbor and 'test'. 



%check the matrix dimension
assert(size(training,2) == size(test,2), 'Error: training and test must have the same number of columns.');

%repeat the test for the vectorial sub
reptest = repmat(test,size(training,1),1);

%Calculate the square of the difference of each component
component_distances = (training - reptest).^2;

%Sum the components
distances = sum(component_distances,2);

%Find the closest K point to test
neighbors = zeros(1,size(training,2)+2);
for i=1:K
    [a b] = min(distances);
    distances(b) = Inf;
    neighbors(i,:) = [training(b,:),classes(b),sqrt(a)];   
end
