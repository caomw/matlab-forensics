function [Q2_ast] = getQ2_ast(k1,k2,r,c,Qtable)

Z = zeros(8);
Z(k1,k2) = 1;
W = ibdct(Z);
W1 = zeros(8);
W1(1:r,1:c) = W(9-r:8,9-c:8);
W2 = zeros(8);
W2(1:r,c+1:8) = W(9-r:8,1:8-c);
W3 = zeros(8);
W3(r+1:8,1:c) = W(1:8-r,9-c:8);
W4 = zeros(8);
W4(r+1:8,c+1:8) = W(1:8-r,1:8-c);
Y1 = bdct(W1);
Y2 = bdct(W2);
Y3 = bdct(W3);
Y4 = bdct(W4);

Q2_ast = sum(sum((Y1.*Qtable).^2/12))+...
               sum(sum((Y2.*Qtable).^2/12))+...
               sum(sum((Y3.*Qtable).^2/12))+...
               sum(sum((Y4.*Qtable).^2/12));
           
return