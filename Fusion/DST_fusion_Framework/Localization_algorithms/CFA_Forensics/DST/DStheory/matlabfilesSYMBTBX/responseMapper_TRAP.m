function[XT, XN, XTN, tot] = responseMapper_TRAP(X, GrowN, DecrN, GrowT, DecrT, rampWidth, testing)

if nargin<6 || isempty(rampWidth)
    rampWidth = 0.1;
end

StartN = GrowN - rampWidth;
ZeroN = DecrN + rampWidth;

StartT = GrowT - rampWidth;
ZeroT = DecrT + rampWidth;

XN = trapmf(X,[StartN, GrowN, DecrN, ZeroN]);
XT = trapmf(X,[StartT, GrowT, DecrT, ZeroT]);
XTN = max(0,1-(XN+XT));
tot = XN+XT+XTN;
%normalize
XN = XN./(tot);
XT = XT./(tot);
XTN = XTN./(tot);

if nargin>6 && strcmp(testing,'t')
   [XT, XN, XTN] = testIt(X,GrowN, DecrN, GrowT, DecrT, rampWidth);
end
end

%check and view script:
function [XT, XN, XTN] = testIt(X,GrowN, DecrN, GrowT, DecrT, rampWidth)
figure();
%figure();
out=zeros(1,3);
for i=0:0.01:1
[out(end+1,1),out(end,2),out(end,3)]=responseMapper_TRAP(i, GrowN, DecrN, GrowT, DecrT, rampWidth);
% [out(end+1,1),out(end,2),out(end,3)]=responseMapper_TRAP(i,0.2,0.4,0.8,1);
end
out=out(2:end,:);
plot(linspace(0,1,length(out(:,1))),out(:,1),'r--','LineWidth',2)
hold on
plot(linspace(0,1,length(out(:,2))),out(:,2),'b-','LineWidth',2)
plot(linspace(0,1,length(out(:,3))),out(:,3),'k-.')
xlim([0 1.01]);
ylim([0 1.1]);
xlabel('Detection');
ylabel('Mass');
set(gca,'FontSize',14);
title(['Tool ',X,' mapping functions']);
xlhand = get(gca,'xlabel');set(xlhand,'fontsize',14);
ylhand = get(gca,'ylabel');set(ylhand,'fontsize',14);
set(gca,'XGrid','on');set(gca,'YGrid','on');
if ~strcmpi(X,'B')
    legend(['\mu_T'],['\mu_N'],['\mu_{TN}'],'Location','E');
else
    legend(['\mu_T'],['\mu_N'],['\mu_{TN}'],'Location','W');
end
    check=sum(out,2);
XT  = out(:,1);
XN  = out(:,2);
XTN = out(:,3);
end
%Make a big subplot
% figure();
% subplot(2,3,1);     [AT, AN, ATN] = responseMapper_TRAP('A', 0, 0.2, 0.7,  1, 0.5,'t');    
% subplot(2,3,2);    [BT, BN, BTN] = responseMapper_TRAP('B', 0, 0.3, 0.90, 1, 0.45,'t');
% subplot(2,3,3);    [CT, CN, CTN] = responseMapper_TRAP('C', 0, 0.35, 0.6, 1, 0.45,'t');
% subplot(2,3,4);     [DT, DN, DTN] = responseMapper_TRAP('D', 0, 0.20, 0.35, 1, 0.1,'t');        
% subplot(2,3,5);    [ET, EN, ETN] = responseMapper_TRAP('E', 0, 0.1, 0.2,1, 0.1,'t');
