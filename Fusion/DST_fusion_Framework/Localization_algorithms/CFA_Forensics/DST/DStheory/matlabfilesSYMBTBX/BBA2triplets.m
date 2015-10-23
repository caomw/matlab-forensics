function[XT XN XTN] = BBA2triplets(X, alg, BBAtot)

idx = floor(X*100 + 1);
XT=0;
XN=0;
XTN=0;
for z=1:size(BBAtot.(alg){idx}.assignments(:,1))
   switch BBAtot.(alg){idx}.assignments{z,1}
       case '10'
           XTt = BBAtot.(alg){idx}.assignments{z,2};
           XT = XTt.double;
       case '01'
           XNt = BBAtot.(alg){idx}.assignments{z,2};
           XN = XNt.double;
       case '11'
           XTNt = BBAtot.(alg){idx}.assignments{z,2};
           XTN = XTNt.double;
   end
end
if (1-(XT+XN+XTN))>0.01
    display('BBA2triplets: Something is wrong, masses do not sum to 1.');
end
end