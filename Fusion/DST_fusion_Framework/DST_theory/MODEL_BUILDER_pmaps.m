function[bbaABC] = MODEL_BUILDER_pmaps()%(A, Ra, B, Rb, C, Rc, D, Rd, E, Re, table)%, plotFlag)
%Simple script to test how much time is needed to create a model with an
%increasing number of different traces, and to see how much time is needed
%to perform fusion.

%Experiment description: we have 7 tools, searching for a total of 5
%different traces

if ispc
    addpath('matlabfilesSYMBTBX\');
else
    
end


%%Put dummy values for all tools
AT = 0.8;
AN = 0.1;
AR = 0.6;
CA = (1 - (AR .* AT + AR .* AN));

BT = 0.7;
BN = 0.1;
BR = 0.8;
CB = (1 - (BR .* BT + BR .* BN));

CT = 0.7;
CN = 0.2;
CR = 0.9;
CC = (1 - (CR .* CT + CR .* CN));

DT = 0.3;
DN = 0.5;
DR = 0.7;
CD = (1 - (DR .* DT + DR .* DN));

ET = 0.1;
EN = 0.7;
ER = 0.9;
CE = (1 - (ER .* ET + ER .* EN));

FT = 0.001;
FN = 0.2;
FR = 0.5;
CF = (1 - (FR .* FT + FR .* FN));

GT = 0.2;
GN = 0.7;
GR = 0.7;
CG = (1 - (GR .* GT + GR .* GN));


%% First step: 2 tools

%Introduce new variables with their possible values.
clear newVariables;
newVariables{1,1} = 'B';
newVariables{1,2} = [{'tb'};{'nb'}];
newVariables{2,1} = 'C';
newVariables{2,2} = [{'tc'};{'nc'}];


modA = modelParser('A.mod'); %parse
targetMod = extendModel(modA, newVariables); %extend
modelWriter(targetMod,'ABC.mod'); %write model to file

BBAvacuousExt('M_A.bba','ABC.mod','M_A_ABC.bba');
BBAvacuousExt('M_B.bba','ABC.mod','M_B_ABC.bba');
BBAvacuousExt('M_C.bba','ABC.mod','M_C_ABC.bba');

bbaA = BBAparser('M_A_ABC.bba');
bbaB = BBAparser('M_B_ABC.bba');
bbaC = BBAparser('M_C_ABC.bba');
%bbaTAB = BBAparser('M_TAB_ABC.bba');

bbaAB = SimbOrthogonalSum(bbaA,bbaB);
bbaABC = SimbOrthogonalSum(bbaAB,bbaC);
%bbaFINAL = SimbOrthogonalSum(bbaABC,bbaTAB);

BBAwriter(bbaABC,'final.bba');

%BBAwriter(bbaFINAL,'final.bba');




return




