%Simple script used to build up the fusion model

addpath('matlabfilesSYMBTBX\');
addpath('model\');

start_mod = modelParser('c.mod'); %c.mod defines variable c that can take values in {'tcfa, ncfa'}.

%Create the model for the two global variables and the three algorithms
clear newVariables;
newVariables{1,1} = 'na';
newVariables{1,2} = [{'tna'};{'nna'}];

newVariables{2,1} = 'al';
newVariables{2,2} = [{'tal'};{'nal'}];

newVariables{3,1} = 'N';
newVariables{3,2} = [{'tN'};{'nN'}];

newVariables{4,1} = 'A';
newVariables{4,2} = [{'tA'};{'nA'}];

newVariables{5,1} = 'C';
newVariables{5,2} = [{'tC'};{'nC'}];


%extend the model for the 5 variables
targetMod = extendModel(start_mod, newVariables); 

%write it down
modelWriter(targetMod,'ABCDE.mod');

%Vacuous extensions of the single models to the extended model
BBAvacuousExt('M_A.bba','ABCDE.mod','M_A_ABCDE.bba');
BBAvacuousExt('M_na.bba','ABCDE.mod','M_na_ABCDE.bba');
BBAvacuousExt('M_c.bba','ABCDE.mod','M_c_ABCDE.bba');
BBAvacuousExt('M_al.bba','ABCDE.mod','M_al_ABCDE.bba');
BBAvacuousExt('M_N.bba','ABCDE.mod','M_N_ABCDE.bba');
BBAvacuousExt('M_CC.bba','ABCDE.mod','M_CC_ABCDE.bba');


bbaA = BBAparser('M_A_ABCDE.bba');
bban = BBAparser('M_na_ABCDE.bba');
bbac = BBAparser('M_c_ABCDE.bba');
bbaa = BBAparser('M_al_ABCDE.bba');
bbaN = BBAparser('M_N_ABCDE.bba');
bbaC = BBAparser('M_CC_ABCDE.bba');
bbaTAB = BBAparser('M_TAB.bba');
 

%Ortogonal sum
bbaAN = SimbOrthogonalSum(bbaA,bbaN);
disp('somma 1');
bbaANc = SimbOrthogonalSum(bbaAN,bbac);
disp('somma 2');
bbaANcn = SimbOrthogonalSum(bbaANc,bban);
disp('somma 3');
bbaANcna = SimbOrthogonalSum(bbaANcn,bbaa);
disp('somma 4');
bbaANCcna = SimbOrthogonalSum(bbaANcna,bbaC);
disp('somma 5');
bbafinal= SimbOrthogonalSum(bbaANCcna ,bbaTAB);
disp('somma 6');

%Write the final model
BBAwriter(bbafinal,'final.bba');

%The formulae that represent the "tampered block" and "original
%block" proposition 
tampered=getBelief(bbafinal, ...
    {...
    '(tcfa, nna, nal, nN, tA, tC)';...
    '(tcfa, nna, nal, nN, tA, nC)';...
    '(ncfa, tna, nal, tN, tA, tC)';...
    '(ncfa, tna, nal, tN, tA, nC)';...
    '(ncfa, tna, nal, tN, nA, tC)';...
    '(ncfa, tna, nal, tN, nA, nC)';...
    '(ncfa, nna, nal, nN, tA, tC)';...
    '(ncfa, nna, nal, nN, tA, nC)';...
    '(ncfa, nna, nal, nN, nA, tC)';...
    });
original= getBelief(bbafinal, ...
    {...
    '(tcfa, nna, tal, tN, tA, tC)';...
    '(tcfa, nna, tal, nN, tA, tC)';...
    '(tcfa, nna, nal, tN, nA, tC)';...
    '(tcfa, nna, nal, nN, nA, tC)';...
    '(ncfa, nna, tal, tN, tA, nC)';...
    '(ncfa, nna, tal, nN, tA, tC)';...
    '(ncfa, nna, tal, nN, tA, nC)';...
    '(ncfa, nna, nal, tN, nA, nC)';...
    '(ncfa, nna, nal, nN, nA, nC)';...
    });

%simplify the formulae to achieve better performances
tamp=tampered.simplify;
orig=original.simplify;

%ATTENTION
%To achieve the fusion step with matrix operation (absolutely needed) you need to convert the variable tamp and
%orig in char format (orig.char tamp.char) and replace / with ./ and * with .*
%These formulae can be evaluated with the eval operation.
orig_ch = orig.char;
tamp_ch = tamp.char;
orig_ch = strrep(orig_ch,'*','.*');
orig_ch = strrep(orig_ch,'/','./');
tamp_ch = strrep(tamp_ch,'*','.*');
tamp_ch = strrep(tamp_ch,'/','./');
tampered = tamp_ch;
original = orig_ch;







