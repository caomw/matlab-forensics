function [mtx] = dct2mtx(n,ord) 
% DCT2MTX: generating matrices corresponding to 2D-DCT transform.
%          
%
% [mtx] = dct2mtx(N)
% 
% input arguments:
%	N: size of 2D-DCT basis (N x N)
%  ord: order of the obtained DCT basis
%		'grid': as grid order (default)
%     'snake': as snake order
% output arguments:
%	mtx: 3D matrices of dimension (NxNxN^2)
%       mtx(:,:,k) is the kth 2D DCT basis of support size N x N
%
% Xunyu Pan, Xing Zhang, Siwei Lyu -- 07/26/2012             

% code from MATLAB dctmtx function
[cc,rr] = meshgrid(0:n-1);

c = sqrt(2 / n) * cos(pi * (2*cc + 1) .* rr / (2 * n));
c(1,:) = c(1,:) / sqrt(2);

switch ord(1:2)
	case 'gr',
		ord = reshape(1:n^2,n,n);
	case 'sn', % not exactly snake code,but close
		temp = cc+rr;
		[temp,idx] = sort(temp(:));
		ord = reshape(idx,n,n);
	otherwise,
		error('unknown order')
end

mtx = zeros(n,n,n*n);
for i = 1:n
	for j = 1:n
		mtx(:,:,ord(i,j)) = c(i,:)'*c(j,:);
	end
end

return
