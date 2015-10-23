
BBA_to_test = BBA;

syms AR AT AN ATN CA
%AR=0.8;
%AT=0.8;
%AN=0.1;
%ATN=0.1;
CA = abs(1-AR*(AT+AN));

syms BR BT BN BTN CB
%BR=0.7;
%BT=0.2;
%BN=0.6;
%BTN=0.2;
CB = abs(1-BR*(BT+BN));

syms CR CT CN CTN CC

%CR=0.8;
%CT=0.7;
%CN=0.2;
%CTN=0.1;
CC = abs(1-CR*(CT+CN));

syms DR DT DN DTN CD
%DR=0.6;
%DT=0.2;
%DN=0.6;
%DTN=0.2;
CD = abs(1-DR*(DT+DN));

syms ER ET EN ETN CE
%ER=0.9;
%ET=0.1;
%EN=0.6;
%ETN=0.3;
CE = abs(1-ER*(ET+EN));

somma = [];
fnames = fieldnames(BBA_to_test.assignments);
for i=1:numel(fnames) 
    if strfind(fnames{i},'1')  %SKIP THE EMPTY SET (which is conflict!)
        somma = [somma '+ ' BBA_to_test.assignments.(fnames{i})];
    end
end
disp(sprintf('Total mass is: %.8f',eval(somma)));
disp(sprintf('Conflict is: %.8f',eval(BBA_to_test.K)));
subs({AR AT AN ATN BR BT BN BTN CR CT CN CTN DR DT DN DTN ER ET EN ETN},{0.8 0.8 0.1 0.1 0.7 0.2 0.6 0.2 0.8 0.7 0.2 0.1 0.6 0.2 0.6 0.2 0.9 0.1 0.6 0.3});


disp(sprintf('Belief for event Tampered is: %.8f',eval(getBelief(BBA_to_test, ...
    {'(ta, tb, tc)';...
    '(ta, nb, nc)';...
    '(na, tb, tc)';...
    '(na, nb, tc)'}))))

disp(sprintf('Belief for event Non-Tampered is: %.8f',eval(getBelief(BBA_to_test, ...
    {'(na, nb, nc)'}))));
