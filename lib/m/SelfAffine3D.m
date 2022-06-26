%% A simple script to plot self-affine sets by iterating compact sets
% Zhou Feng @ 2022-6-25
clc, clf, clear
tic

%% settings
% % IFS linear parts
linearMats = {diag([1/6, 1/4, 1/3]),...
              diag([1/2, 1/2, 1/3]),...
              diag([1/3, 1/4, 2/3]),...
              diag([1/2, 1/4, 1/3])};

% IFS translations
translations = {[0 0 0]',...
                [1/6 1/4 0]',...
                [2/3, 3/4, 1/3]',...
                [1/6, 0, 0]'};

% initial polygon for iteration
shapeInit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1]';
shapeInitFaces = [4 8 5 1; 1 5 6 2; 2 6 7 3; 3 7 8 4; 5 8 7 6; 1 4 3 2];

% iteration time
numItrs = 8;

% plot settings
spaceDim = 3;
showTitle = true;
showFirstItrs = false;
alphaPlot = 0.6;
colorPlot = 'k';
colorEdge = 'w'; % 'none'

%% Examples
% ---------------------------------- sponges --------------------------------- %
% % Sierpinski-Menger snowflake
% ratio = 1/3;
% linearMats = cell(8, 1);
% for i = 1:8
%     linearMats{i} = ratio * eye(3);
% end
% translations = {[0 0 0]', [0 2/3 0]', [2/3, 2/3, 0]', [2/3, 0, 0]', ...
%             [0 0 2/3]', [0 2/3 2/3]', [2/3, 2/3, 2/3]', [2/3, 0, 2/3]'};
% shapeInit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1]';
% shapeInitFaces = [4 8 5 1; 1 5 6 2; 2 6 7 3; 3 7 8 4; 5 8 7 6; 1 4 3 2];


% % Sierpinski-Menger sponge
% ratio = 1/3;
% linearMats = cell(20, 1);
% for i = 1:20
%     linearMats{i} = ratio * eye(3);
% end
% translations = kron(ones(4, 1), [0 0 0;...
%                                 1/3 0 0;...
%                                 2/3 0 0]);
% translations(4:6, 2) = translations(4:6, 2) + 2/3;
% translations(7:9, 3) = translations(7:9, 2) + 2/3;
% translations(10:12, 2:3) = translations(10:12, 2:3) + 2/3;
% translations = [translations; kron(ones(4, 1), [0, 0, 1/3; 2/3, 0, 1/3])];
% translations(15:16, 2) = translations(15:16, 2) + 2/3;
% translations(17:18, 2:3) = translations(17:18, 2:3) + [1/3 -1/3; 1/3 -1/3];
% translations(19:20, 2:3) = translations(19:20, 2:3) + [1/3 1/3; 1/3 1/3];
% translations = mat2cell(translations', [3], ones(20, 1));
% shapeInit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1]';
% shapeInitFaces = [4 8 5 1; 1 5 6 2; 2 6 7 3; 3 7 8 4; 5 8 7 6; 1 4 3 2];


% % Baranski menger
% linearMats = {diag([1/6, 1/4, 1/3]),...
%               diag([1/2, 1/2, 1/3]),...
%               diag([1/3, 1/4, 2/3]),...
%               diag([1/2, 1/4, 1/3])};
% translations = {[0 0 0]',...
%                 [1/6 1/4 0]',...
%                 [2/3, 3/4, 1/3]',...
%                 [1/6, 0, 0]'};
% shapeInit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1]';
% shapeInitFaces = [4 8 5 1; 1 5 6 2; 2 6 7 3; 3 7 8 4; 5 8 7 6; 1 4 3 2];


%% Error handling
isCompactible = false;

if length(linearMats) == length(translations)
    isCompactible = true;
end

if ~isCompactible
    error('Illegal settings. Dimensions of the parameters does not match!')
end

sizeIFS = length(linearMats);
numInitPts = size(shapeInit, 2);
numInitFaces = size(shapeInitFaces, 2);

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
    sizeNow = size(ptsNow, 2);

    ptsTotal{levelNow + 1} = ptsNow;
end

%% Plot
numShapes = sizeNow / numInitPts;
facesPlot = kron(ones(numShapes, 1), shapeInitFaces) + ...
    kron((0:(numShapes - 1))' * numInitPts, ones(6, 1));
figure(1)
patch('Faces', facesPlot, ...
    'Vertices', ptsNow', ...
    'FaceColor', colorPlot, ...
    'EdgeColor', colorEdge, ...
    'FaceAlpha', alphaPlot)
view(3)
set(gca, 'XColor', 'none', 'YColor', 'none', 'ZColor', 'none')

if showTitle
    title(['Iteration time = ', num2str(numItrs)], 'Interpreter', 'latex');
end

if showFirstItrs && numItrs >= 3
    figure(2)

    for i = 1:3
        subplot(1, 3, i)
        [~, sizeTmp] = size(ptsTotal{i});
        numShapesTmp = sizeTmp / numInitPts;
        facesPlot = kron(ones(numShapesTmp, 1), shapeInitFaces) + ...
            kron((0:(numShapesTmp - 1))' * numInitPts, ones(6, 1));
        patch('Faces', facesPlot, ...
            'Vertices', ptsTotal{i}', ...
            'FaceColor', colorPlot, ...
            'EdgeColor', colorEdge, ...
            'FaceAlpha', alphaPlot)
        view(3)
        set(gca, 'XColor', 'none', 'YColor', 'none', 'ZColor', 'none')
        % title(['Iteration time = ', num2str(plotposition-1)], 'Interpreter', 'latex');
    end

end

%% Show param
countPtsTotal = sizeNow;
countShapesTotal = numShapes;
tableResults = table(countPtsTotal, countShapesTotal);
disp(tableResults)
