function[BelT, PlT, BelN, PlN, Confl] = FiveToolFusion_NewIdea_EXHAUSTIVE(A, Ra, B, Rb, C, Rc, D, Rd, E, Re, XT, XN, XTN)

%CASO DI STUDIO: vedi M_5tools_ABCDE.bba
%A: detection del tool Double JPEG (Ta)
%B: detection del tool Single JPEG (Tb)
%C: detection del tool JPEG Ghost (Tc)
%D: detection del tool JPNA (Td)
%E: detecion del tool JPDQ (Te)

%Ra, Rb, Rc, Rd, Re confidenza a priori sui tool
%plotFlag: set to 'd' if you want to display the image, 's' to save figure,
%'n' to disable
%warning off
%Mapping from A -> AT,AN,ATN and the same for other variables...
%Mapping from Ra -> AR,AU,ARU and the same for other variables...

AR = Ra;
AN = 1-Ra;
BR = Rb;
BN = 1-Rb;
CR = Rc;
CN = 1-Rc;
DR = Rd;
DN = 1-Rd;
ER = Re;
EN = 1-Re;

 display('Using DS built BBA assignment');
 AT = XT.A(round(A*100+1)); AN = XN.A(round(A*100+1)); ATN = XTN.A(round(A*100+1)); 
 BT = XT.B(round(B*100+1)); BN = XN.B(round(B*100+1)); BTN = XTN.B(round(B*100+1)); 
 CT = XT.C(round(C*100+1)); CN = XN.C(round(C*100+1)); CTN = XTN.C(round(C*100+1)); 
 DT = XT.D(round(D*100+1)); DN = XN.D(round(D*100+1)); DTN = XTN.D(round(D*100+1)); 
 ET = XT.E(round(E*100+1)); EN = XN.E(round(E*100+1)); ETN = XTN.E(round(E*100+1)); 



CA = (1 - (AR .* AT + AR .* AN));
CB = (1 - (BR .* BT + BR .* BN));
CC = (1 - (CR .* CT + CR .* CN));
CD = (1 - (DR .* DT + DR .* DN));
CE = (1 - (ER .* ET + ER .* EN));

%BBA = BBAparser('ABCDE_Tab.bba');
 
try
    load('active_BBAs/ABCDE_Tab.mat');
catch
    BBA = BBAparser('./active_BBAs/ABCDE_Tab.bba');
    save('active_BBAs/ABCDE_Tab.mat','BBA');
end
        BelT = eval(getBelief(BBA, ...
            {...
            '(ta, tb, tc)';...
            '(ta, nb, nc)';...
            '(na, tb, tc)';...
            '(na, nb, tc)';...
            }));
        BelN = eval(getBelief(BBA, ...
            {...
            '(na, nb, nc)';...
            }));              



PlT = 1 - BelN;

PlN = 1 - BelT;
Confl = eval(BBA.K);
% fprintf('--------- Forensic_ICIP.m ---------\n');
% display(['Conflict: ',num2str(1-K)]);
% fprintf('Belief-Plausibility ranges are:\n');
% display(['T = [',num2str(BelT,3),' , ',num2str(PlT,3),']']);
% display(['N = [',num2str(BelN,3),' , ',num2str(PlN,3),']']);
% if nargin>7 && (strcmpi(plotFlag,'d')||strcmpi(plotFlag,'s'))
%     h=bar('v6',[BelT PlT; BelN PlN],'group');
%     set(gca,'XTickLabel',['T';'N']);
%     set(gca,'YLim',[0 1]);
%     legend('Belief', 'Plausibility');
%     title({['D:',num2str(D),'   S:',num2str(S),'   G:',num2str(G)];['Rd:',num2str(Rd),'   Rs:',num2str(Rs),'   Rg:',num2str(Rg)];['--> Conflict = ', num2str(1-K)]},'FontSize',12,'FontWeight','bold');
%     try
%         set(h(1),'facecolor',[K 0 0])
%         set(h(2),'facecolor',[0 0 K])
%         set(h(3),'facecolor',[K 0 0])
%         set(h(4),'facecolor',[0 0 K])
%     catch
%     end
%     %display(['Is tampered: ',num2str(BelT*K)]);
%     if strcmpi(plotFlag,'s')
%         file_name= sprintf('D_%1.2f__S_%1.2f__G_%1.2f__Rd_%1.2f__Rs_%1.2f__Rg_%1.2f',[D S G Rd Rs Rg]);
%         saveas(gca, fullfile('images',['DSMODEL_', file_name, '.png']), 'png');
%     end
% end

end

