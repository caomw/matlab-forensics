
Q = 2*ones(8);

Q(1:4:end,1:4:end) = 1;
Q(1:4:end,2:4) = 3;
Q(1:4:end,6:8) = 3;
Q(2:4,1:4:end) = 4;
Q(6:8,1:4:end) = 4;

figure, imagesc(0:7,0:7,Q)
axis square
map = [1 1 1; 1 1 0; 0 1 0; 0 0.5 1;];
colormap(map)
hold on
% plot(0,0,'o')
% plot(0,0,'ko')
h = line([4 4],[-1 9]);
set(h,'LineStyle','-.','LineWidth',1);
h = line([-1 9],[4 4]);
set(h,'LineStyle','-.','LineWidth',1);

% h = line([1.5 2.5], [0.5 0.5]);
% set(h,'Linestyle','--');
% h = line([1.5 2.5], [1.5 1.5]);
% set(h,'Linestyle','--');
% h = line([1.5 2.5], [6.5 6.5]);
% set(h,'Linestyle','--');
% h = line([1.5 2.5], [7.5 7.5]);
% set(h,'Linestyle','--');
% h = line([5.5 6.5], [0.5 0.5]);
% set(h,'Linestyle','--');
% h = line([5.5 6.5], [1.5 1.5]);
% set(h,'Linestyle','--');
% h = line([5.5 6.5], [6.5 6.5]);
% set(h,'Linestyle','--');
% h = line([5.5 6.5], [7.5 7.5]);
% set(h,'Linestyle','--');
% h = line([1.5 1.5], [0.5 1.5]);
% set(h,'Linestyle','--');
% h = line([2.5 2.5], [0.5 1.5]);
% set(h,'Linestyle','--');
% h = line([5.5 5.5], [0.5 1.5]);
% set(h,'Linestyle','--');
% h = line([6.5 6.5], [0.5 1.5]);
% set(h,'Linestyle','--');
% h = line([1.5 1.5], [6.5 7.5]);
% set(h,'Linestyle','--');
% h = line([2.5 2.5], [6.5 7.5]);
% set(h,'Linestyle','--');
% h = line([5.5 5.5], [6.5 7.5]);
% set(h,'Linestyle','--');
% h = line([6.5 6.5], [6.5 7.5]);
% set(h,'Linestyle','--');
% 
% h = line([0.5 1.5], [3.5 3.5]);
% set(h,'Linestyle','--');
% h = line([0.5 1.5], [4.5 4.5]);
% set(h,'Linestyle','--');
% h = line([0.5 0.5], [3.5 4.5]);
% set(h,'Linestyle','--');
% h = line([1.5 1.5], [3.5 4.5]);
% set(h,'Linestyle','--');
% h = line([6.5 7.5], [3.5 3.5]);
% set(h,'Linestyle','--');
% h = line([6.5 7.5], [4.5 4.5]);
% set(h,'Linestyle','--');
% h = line([6.5 6.5], [3.5 4.5]);
% set(h,'Linestyle','--');
% h = line([7.5 7.5], [3.5 4.5]);
% set(h,'Linestyle','--');
% 
for k=0:8
    h = line([k-0.5, k-0.5], [-0.5, 7.5]);
    set(h,'Linestyle',':');
    h = line([-0.5, 7.5], [k-0.5, k-0.5]);
    set(h,'Linestyle',':');
end

h = plot(2,1,'kx');
set(h, 'LineWidth', 1, 'MarkerSize', 8);
h = plot([2 6 6],[7 7 1],'k+');
set(h, 'LineWidth', 1, 'MarkerSize', 8);
h = plot(1,0,'kx');
set(h, 'LineWidth', 1, 'MarkerSize', 8);
h = plot(7,0,'k+');
set(h, 'LineWidth', 1, 'MarkerSize', 8);

h = plot([0 4 4],[4 4 0],'k*');
set(h, 'LineWidth', 1, 'MarkerSize', 8);

h = plot([0 0],[3 5], 'ko');
set(h, 'LineWidth', 1, 'MarkerSize', 8);
h = plot([3 5],[0 0], 'ko');
set(h, 'LineWidth', 1, 'MarkerSize', 8);
h = plot([3 5 4 4],[4 4 3 5], 'ko');
set(h, 'LineWidth', 1, 'MarkerSize', 8);
