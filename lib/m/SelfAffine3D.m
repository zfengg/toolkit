%% A simple script to plot self-affine sets by iterating compact sets
% Zhou Feng @ 2022-6-25
clc, clf, clear
tic

%% settings
% IFS linear parts
ratio = 1/3;
linearMats = cell(8, 1);
for i = 1:8
    linearMats{i} = ratio * eye(3);
end
% linearMats = {[0.25 0; 0 0.25],...
%     [0.25 0; 0 0.25],...
%     [0.25 0; 0 0.25],...
%     [0.25 0; 0 0.25],...
%     [0.5 0; 0 0.5]};

% IFS translations
% tmp = {[0 0 0]', [0 2/3 0]', [2/3, 2/3, 0]', [2/3, 0, 0]'}
translations = {[0 0 0]', [0 2/3 0]', [2/3, 2/3, 0]', [2/3, 0, 0]', ...
                [0 0 2/3]', [0 2/3 2/3]', [2/3, 2/3, 2/3]', [2/3, 0, 2/3]'};
% translations = {[0; 0],...
%     [0.75; 0],...
%     [0.75; 0.75],...
%     [0; 0.75],...
%     [0.25; 0.25]};

% initial polygon for iteration
shapeInit = [0    0    0;
        1  0    0;
        1  1  0;
        0    1  0;
        0    0    1;
        1  0    1;
        1 1  1;
        0 1  1;]';
% shapeInit = [0 1 1 0;
%              0 0 1 1];
idx = [4 8 5 1 4; 1 5 6 2 1; 2 6 7 3 2; 3 7 8 4 3; 5 8 7 6 5; 1 4 3 2 1]';


numItrs = 5; % iteration time

% plot settings
spaceDim = 3;
showTitle = true;
showFirstItrs = false;


%% Examples
% ---------------------------------- gaskets --------------------------------- %
% % Sierpinski gasket
% cRatio = 1/2;
% linearMats = cell(1, 3);
% for i = 1:3
%     linearMats{i} = cRatio * eye(2);
% end
% translations = {[0; 0], [cRatio; 0], [0; cRatio]};
% shapeInit = [0 1 0; 0 0 1];

% % Sierpinski gasket (self-affine)
% hRatio = 0.25;
% vRatio = 0.7;
% linearMats = {[hRatio 0; 0 vRatio],
%               [1 - hRatio 1 - hRatio - vRatio; 0 vRatio],
%               [1 - vRatio 0; 0 1 - vRatio]};
% translations = {[0; 0], [hRatio; 0], [0; vRatio]};
% shapeInit = [0 1 0; 0 0 1];

% ---------------------------------- carpets --------------------------------- %
% % Sierpinski carpet
% linearMats = cell(1, 8);
% for i = 1:8
%     linearMats{i} = 1/3 * eye(2);
% end
% translations = {[0;0], [1;0], [2;0], [0;1], [2;1], [0;2], [1;2], [2;2]};
% shapeInit = [0 3 3 0; 0 0 3 3];

% % Bedford-McMullen carpet
% BMh = 3; % horizontal size
% BMv = 4; % vertical size
% BMselect = [1 0 0 1;
%             0 0 0 0;
%             0 0 0 0;
%             1 0 0 1]; % select positions
% BMmat = flipud(BMselect);
% [oneRows, oneCols] = find(BMmat>0);
% BMsize = length(oneRows);
% BMlinear = [1/BMh 0; 0 1/BMv];
% linearMats = cell(1, BMsize);
% translations = cell(1, BMsize);
% for i = 1:BMsize
%     linearMats{i} = BMlinear;
%     translations{i} = [(oneCols(i)-1)*(1/BMh); (oneRows(i)-1)*(1/BMv)];
% end
% shapeInit = [0 1 1 0; 0 0 1 1];

% % Baranski carpet
% Bar_h = [0.1 0.3 0.4 0.2]; % horizontal scales
% Bar_v = [0.1 0.2 0.4 0.3]; % vertical scales
% Bar_select = [1 0 1 0;
%               0 1 0 1;
%               0 0 0 0;
%               0 0 1 0]; % select positions
% Bar_mat = flipud(Bar_select);
% [oneRows, oneCols] = find(Bar_mat > 0);
% Bar_size = length(oneRows);
% linearMats = cell(1, Bar_size);
% translations = cell(1, Bar_size);
% for i = 1:Bar_size
%     linearMats{i} = [Bar_h(oneCols(i)) 0; 0 Bar_v(oneRows(i))];
%     translations{i} = [sum(Bar_h(1:oneCols(i))) - Bar_h(oneCols(i));...
%         sum(Bar_v(1:oneRows(i))) - Bar_v(oneRows(i))];
% end
% shapeInit = [0 1 1 0; 0 0 1 1];

% --------------------------------- triangles -------------------------------- %
% % Sierpinski triangle
% cRatio = 1/2;
% linearMats = cell(1, 3);
% for i = 1:3
%     linearMats{i} = cRatio * eye(2);
% end
% translations = {[0; 0], [1-cRatio; 0], [0.5*(1-cRatio); (1-cRatio)*0.5*sqrt(3)]};
% shapeInit = [0 1 0.5; 0 0 0.5*sqrt(3)];

% % Sierpinski triangle (self-affine)
% ratio1st = 2/3;
% ratio2nd = 2/3;
% linearMats = {[ratio1st * (1 - ratio2nd) ratio1st * (2 * ratio2nd - 1) / sqrt(3);...
%     0 ratio1st * ratio2nd], ...
%     [ratio1st * (1 - ratio2nd) 0; 0 ratio1st * (1 - ratio2nd)], ...
%     [ratio1st * ratio2nd 0; 0 ratio1st * ratio2nd], ...
%     [1 - ratio1st 0; 0 1 - ratio1st], ...
%     [1/2 (1/2 - ratio1st) / sqrt(3); sqrt(3) / 2 - sqrt(3) * ratio1st 1/2]};
% translations = {[0; 0], [ratio1st * ratio2nd / 2; ratio1st * ratio2nd * sqrt(3) / 2],...
%     [ratio1st * (1 - ratio2nd); 0], ...
%     [ratio1st; 0], [ratio1st / 2; ratio1st * sqrt(3) / 2]};
% shapeInit = [0 1 0.5; 0 0 0.5 * sqrt(3)];

% ----------------------------------- dusts ---------------------------------- %
% % Cantor dust
% linearMats = cell(1, 4);
% for i = 1:4
%     linearMats{i} = 0.25 * eye(2);
% end
% translations = {[0.26; 0], ...
%     [0.75; 0.25], ...
%     [0; 0.5], ...
%     [0.5; 0.75]};
% shapeInit = [0 1 1 0; 0 0 1 1];

% % product Cantor set
% linearMats = cell(1, 4);
% for i = 1:4
%     linearMats{i} = 1/3 * eye(2);
% end
% translations = {[0; 0], [2/3; 0], [0; 2/3], [2/3; 2/3]};
% shapeInit = [0 1 1 0; 0 0 1 1];

% ----------------------------------- misc ----------------------------------- %
% % Dim of self-affine sets is discontinuous
% ratioDimDiscts = 0.1;
% linearMats = {[0.5 0; 0 1/3], [0.5 0; 0 1/3]};
% translations = {[0; 2/3], [ratioDimDiscts; 0]};
% shapeInit = [0 1 1 0; 0 0 1 1];

% % attenna
% linearMats = {[0.25 0; 0 0.25], [0.25 0; 0 0.25], [0.25 0; 0 0.25],...
%               [0.25 0; 0 0.25], [0.5 0; 0 0.5]};
% translations = {[0; 0], [0.75; 0], [0.75; 0.75], [0; 0.75], [0.25; 0.25]};
% shapeInit = [0 1 1 0; 0 0 1 1];


%% Error handling
isCompactible = false;

if length(linearMats) == length(translations)
    isCompactible = true;
end

if ~isCompactible
    error('Illegal settings. Dimensions of the parameters does not match!')
end

sizeIFS = length(linearMats);
[~, numInitPts] = size(shapeInit);


%% Generate points
ptsInit = shapeInit;
ptsNow = ptsInit;
sizeNow = numInitPts;
ptsTotal = cell(numItrs + 1, 1);
ptsTotal{1} = ptsInit;

for levelNow = 1:numItrs

    ptsTmp = zeros(spaceDim, sizeNow * sizeIFS);
    for indexFct = 1:sizeIFS
        ptsTmp(:, (indexFct - 1) * sizeNow + 1:indexFct * sizeNow) = ...
            linearMats{indexFct} * ptsNow + translations{indexFct};
    end

    ptsNow = ptsTmp;
    [~, sizeNow] = size(ptsNow);

    ptsTotal{levelNow + 1} = ptsNow;
end


%% Plot
xc = reshape(ptsNow(1, :), numInitPts, []);
yc = reshape(ptsNow(2, :), numInitPts, []);
zc = reshape(ptsNow(3, :), numInitPts, []);
% [~, numShapes] = size(xc);
numShapes = sizeNow / numInitPts;
xcPatch = zeros(5, 6*numShapes);
ycPatch = zeros(5, 6*numShapes);
zcPatch = zeros(5, 6*numShapes);
for i = 1:numShapes
    xcPatch(:, 1+(i-1)*6 : i*6) = reshape(xc(idx, i), 5, []);
    ycPatch(:, 1+(i-1)*6 : i*6) = reshape(yc(idx, i), 5, []);
    zcPatch(:, 1+(i-1)*6 : i*6) = reshape(zc(idx, i), 5, []);
end

figure(1)
patch(xcPatch, ycPatch, zcPatch, 'k', 'facealpha', 0.5)
view(3)
set(gca, 'XColor', 'none', 'YColor', 'none', 'ZColor', 'none')
if showTitle
    title(['Iteration time = ', num2str(numItrs)], 'Interpreter', 'latex');
end

if showFirstItrs && numItrs >= 3
    figure(2)
    for plotposition = 1:3
        subplot(1,3,plotposition)
        Xsubplotpts = reshape(ptsTotal{plotposition}(1,:), numInitPts, []);
        Ysubplotpts = reshape(ptsTotal{plotposition}(2,:), numInitPts, []);
        patch(Xsubplotpts, Ysubplotpts, 'black')
        set(gca,'XColor', 'none','YColor','none')
        % title(['Iteration time = ', num2str(plotposition-1)], 'Interpreter', 'latex');
    end
end


%% Show param
countPtsTotal = sizeNow;
[~, countShapesTotal] = size(xc);
tableResults = table(countPtsTotal, countShapesTotal);
disp(tableResults)
