% x = [0 1 1 0 0 1];
% y = [0 0 1 1 1 1];
% z = [0 0 0 0 1 1];
% patch(x, y, z, 'red')
% view(3)
clear, clc, clf
%% example
coord = [...
    0    0    0;
    1  0    0;
    1  1  0;
    0    1  0;
    0    0    1;
    1  0    1;
    1  1  1;
    0    1  1;];
idx = [4 8 5 1 4; 1 5 6 2 1; 2 6 7 3 2; 3 7 8 4 3; 5 8 7 6 5; 1 4 3 2 1]';

xc = coord(:,1);
yc = coord(:,2);
zc = coord(:,3);

xc(idx)
reshape(coord(idx, 1), 5, 6)
isequal(   reshape(coord(idx, 1)', 5, 6), reshape(coord(idx, 1), 5, 6) )
% ax(1) = plot();
figure(3)
patch([xc(idx) xc(idx) + 2], [yc(idx) yc(idx) + 1], [zc(idx) zc(idx)], 'r', 'facealpha', 0.1);
view(3);
% Deformed
% coord2 = coord + rand(size(coord))*0.1;
% xc = coord2(:,1);
% yc = coord2(:,2);
% zc = coord2(:,3);
% ax(2) = subplot(2,1,2);
% patch(xc(idx), yc(idx), zc(idx), 'r', 'facealpha', 0.1);
% view(3);   

%%
x = [2 5 7 8;
    1 1 2 2];
x(1, [1 1 3 4])