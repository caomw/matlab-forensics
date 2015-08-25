function [Y] = block_avg(X,d,pad) 
% BLOCK_SUM: Compute the avg of elements for all overlapping dxd windows
%            in data X, where d = 2*rad+1.
%
% [bksum] = block_avg(X,rad)
% 
% input arguments:
%	X: an [nx,ny,ns] array as a stack of ns images of size [nx,ny]
%	rad: radius of the sliding window, i.e., window size = (2*rad+1)*(2*rad+1)
%  pad: padding patterns:
%			'zero': padding with zeros (default)
%			'mirror': padding with mirrored boundary area
%
% output arguments:
%	bksum:sum of elements for all overlapping dxd windows
%
% Xunyu Pan, Xing Zhang and Siwei Lyu -- 07/26/2012             

[nx,ny,ns] = size(X);

if d < 0 | d ~= floor(d) | d >= min(nx,ny)
	error('window size needs to be a positive integer');
	return
end
if ~exist('pad','var'), pad = 'zero'; end

wd = 2*d+1; % size of the sliding window

Y = zeros(nx+wd,ny+wd,ns,'single');
Y(d+2:nx+d+1,d+2:ny+d+1,:) = X; 

% padding boundary
switch pad(1:2)
	case 'ze', % default do nothing
	case 'mi', % padding by mirroring
		% mirroring top
		Y(2:d+1,:,:) = Y(wd+1:-1:d+3,:,:);
		% mirroring bottom
		Y(nx+d+2:end,:,:) = Y(nx+d:-1:nx+1,:,:);
		% mirroring left
		Y(:,2:d+1,:) = Y(:,wd+1:-1:d+3,:);
		% mirroring right
		Y(:,ny+d+2:end,:) = Y(:,ny+d:-1:ny+1,:);
	otherwise,
		error('unknown padding pattern');
		return
end


% forming integral image
Y = cumsum(cumsum(Y,1),2);

% computing block sums
Y = Y(wd+1:end,wd+1:end,:)+Y(1:end-wd,1:end-wd,:) ...
    - Y(wd+1:end,1:end-wd,:)-Y(1:end-wd,wd+1:end,:);

Y = Y/(wd*wd);

%[r,w] = unix('free | grep Mem');
%stats = str2double(regexp(w, '[0-9]*', 'match'));
%memsize = stats(1)/1e6;
%freemem = (stats(3)+stats(end))/1e6;
%disp(['BlockAvgDone: ' num2str(freemem)])

return
