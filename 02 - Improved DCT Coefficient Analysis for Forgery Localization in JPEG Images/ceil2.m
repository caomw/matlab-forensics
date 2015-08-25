function x2 = ceil2(x1)
tol = 1e-12;
x2 = ceil(x1);
idx = find(abs(x1 - x2) < tol);
x2(idx) = x1(idx) + 0.5;
return