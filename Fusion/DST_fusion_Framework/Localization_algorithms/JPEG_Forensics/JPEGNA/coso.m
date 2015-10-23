r = 0;
c = 0;
QF2 = 75;
Q = jpeg_qtable(QF2);
A = 64*randn(1024);
B = dequantize(quantize(A, Q), Q);
C = A - B;
D = ibdct(C);
E = bdct(circshift(D, [-r -c]));

for k1 = 1:8
    for k2 = 1:8
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
      
        Q_ast(k1,k2) = sum(sum((Y1.*Q).^2/12))+...
                       sum(sum((Y2.*Q).^2/12))+...
                       sum(sum((Y3.*Q).^2/12))+...
                       sum(sum((Y4.*Q).^2/12));
        
        F = E(k1:8:end,k2:8:end);
        Q_prime(k1,k2) = var(F(:));
    end
end

Q.^2/12
Q_ast
Q_prime