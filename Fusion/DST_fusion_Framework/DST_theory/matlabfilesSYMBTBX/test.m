tic;
BBA_to_test = BBAfinal;

somma = sym(0);

for i=1:size(BBA_to_test.assignments,1) 
        somma = somma + BBA_to_test.assignments{i,2};
end

res = somma.findsym;
%Obtain candidate variable list
vars = regexp(res, ',', 'split');
%declare symbolic variables
for i=1:numel(vars)
   syms(vars{i});
end

ARv=0.8;
ATv=0.8;
ANv=0.1;
ATNv=0.1;
CAv = abs(1-ARv*(ATv+ANv));

BRv=0.7;
BTv=0.2;
BNv=0.6;
BTNv=0.2;
CBv = abs(1-BRv*(BTv+BNv));

CRv=0.8;
CTv=0.7;
CNv=0.2;
CTNv=0.1;
CCv = abs(1-CRv*(CTv+CNv));

DRv=0.6;
DTv=0.2;
DNv=0.6;
DTNv=0.2;
CDv = abs(1-DRv*(DTv+DNv));

ERv=0.9;
ETv=0.1;
ENv=0.6;
ETNv=0.3;
CEv = abs(1-ERv*(ETv+ENv));



sommav = subs(somma,{AR AT AN ATN BR BT BN BTN CR CT CN CTN DR DT DN DTN ER ET EN ETN CA CB CC CD CE},{ARv ATv ANv ATNv BRv BTv BNv BTNv CRv CTv CNv CTNv DRv DTv DNv DTNv ERv ETv ENv ETNv CAv CBv CCv CDv CEv});
Kv = subs(BBA_to_test.K,{AR AT AN ATN BR BT BN BTN CR CT CN CTN DR DT DN DTN ER ET EN ETN CA CB CC CD CE},{ARv ATv ANv ATNv BRv BTv BNv BTNv CRv CTv CNv CTNv DRv DTv DNv DTNv ERv ETv ENv ETNv CAv CBv CCv CDv CEv});
fprintf('Total mass is: %.8f\n',sommav.double);
fprintf('Conflict is: %.8f\n',Kv.double);

belTsym = getBelief(BBA_to_test, ...
    {'(ta, tb, tc)';...
    '(ta, nb, nc)';...
    '(na, tb, tc)';...
    '(na, nb, tc)'});
BelTv = subs(belTsym,{AR AT AN ATN BR BT BN BTN CR CT CN CTN DR DT DN DTN ER ET EN ETN CA CB CC CD CE},{ARv ATv ANv ATNv BRv BTv BNv BTNv CRv CTv CNv CTNv DRv DTv DNv DTNv ERv ETv ENv ETNv CAv CBv CCv CDv CEv});
fprintf('Belief for event Tampered is: %.8f\n',BelTv.double)

BelNsym = getBelief(BBA_to_test, ...
    {'(na, nb, nc)'});
BelNv = subs(BelNsym,{AR AT AN ATN BR BT BN BTN CR CT CN CTN DR DT DN DTN ER ET EN ETN CA CB CC CD CE},{ARv ATv ANv ATNv BRv BTv BNv BTNv CRv CTv CNv CTNv DRv DTv DNv DTNv ERv ETv ENv ETNv CAv CBv CCv CDv CEv});
fprintf('Belief for event Non-Tampered is: %.8f\n',BelNv.double);
toc;