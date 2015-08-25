function [mtx] = rnd2mtx(n) 
% DCT2MTX: generating matrices corresponding to random orthnormal transform.
%
% [mtx] = rnd2mtx(N)
% 
% input arguments:
%	N: size of 2D random basis (N x N)
%
% output arguments:
%	mtx: 3D matrices of dimension (NxNxN^2)
%       mtx(:,:,k) is the kth 2D DCT basis of support size N x N
%
% Xunyu Pan, Xing Zhang, Siwei Lyu -- 07/26/2012             

% code from MATLAB dctmtx function
X = randn(n);
X = X - repmat(mean(X),n,1);
X = X./repmat(sqrt(sum(X.^2)),n,1);

mtx = zeros(n,n,n*n);
k = 1;
for i = 1:n
	for j = 1:n
		mtx(:,:,k) = X(:,i)*X(:,j)';
		k = k+1;
	end
end

return
