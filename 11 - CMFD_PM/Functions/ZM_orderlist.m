function NM = ZM_orderlist(ORDER)
%Create the moment indices 
%  NM = ZM_orderlist(ORDER)
% 
% NM is a matrix with 2 columns, where the first column indicates n and the second column m.
% 
 
	NM = zeros(0,2); 
	for n = 0:ORDER, 
		for m = 0:n, 
			if mod(n-abs(m),2)==0,
				NM = cat(1, NM , [n m]);
			end 
		end
	end