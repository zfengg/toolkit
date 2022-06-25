%% To plot self-similar sets by iterating intervals
% Tailored for homogeneous IFS for the sake of speed
% Zhou Feng @ 2022-5-20
clc, clf, clear
tic

%% settings
% IFS
% ratios = [1/3, 1/3];
% trans = [0, 2/3];
% intervalInit = [0, 1];

numItrs = 7;

isHomo = true;
showTitle = true;
colorPlot = 'black';
thickness = 50;

%% examples
% example of Jian-Ci Xiao
m = 5;
a = 3;
ratios = 1/3 * ones(1, m);
trans = [0, a.^ - (0:1:(m - 2))];
intervalInit = [0, 1.5];

% mid-third Cantor set
ratios = [1/3, 1/3];
trans = [0, 2/3];
intervalInit = [0, 1];

%% prepare params & error handling
isCompact = false;

if length(ratios) == length(trans)
    isCompact = true;
end

if ~isCompact
    error('Illegal settings. Dimensions of the parameters does not match!')
end

sizeIFS = length(ratios);
trans = sort(trans);
lenInit = diff(intervalInit);

%% generate points
if isHomo
    ptsInit = intervalInit(1);
    ptsNow = ptsInit;
    sizeNow = length(ptsNow);
    ptsTotal = cell(numItrs + 1, 1);
    ptsTotal{1} = ptsInit;

    for levelNow = 1:numItrs
        ptsTmp = kron(ptsNow, ratios) + kron(ones(1, sizeNow), trans);
        ptsNow = unique(ptsTmp);
        sizeNow = length(ptsNow);
        ptsTotal{levelNow + 1} = ptsNow;
    end

end

%% plot
if isHomo
    r = ratios(1);
    lenBasic = r^numItrs * lenInit;
    ptsDiff = diff(ptsNow);
    indexGaps = ptsDiff > lenBasic;
    ptsLeft = ptsNow([true indexGaps]);
    numSegments = length(ptsLeft);
    ptsRight = [ptsNow([false, indexGaps]) - ptsDiff(indexGaps), ptsNow(end)] + lenBasic;

    figure(1)
    plot([ptsLeft; ptsRight], zeros(2, numSegments), ...
        colorPlot, "LineWidth", thickness)
    set(gca, 'XColor', 'none', 'YColor', 'none')

    if showTitle
        title(['Iteration time = ', num2str(numItrs)], 'Interpreter', 'latex');
    end

end

%% show param
countPtsTotal = sizeNow;
[~, countShapesTotal] = size(ptsLeft);
tableResults = table(countPtsTotal, countShapesTotal);
format long
disp(tableResults)

% the right ends of first segments during iterations
r = ratios(1);
firstRights = lenInit * ones(numItrs + 1, 1);

for i = 1:numItrs
    lenBasic = r^i * lenInit;
    ptsNow = ptsTotal{i + 1};
    ptsDiff = diff(ptsNow);
    indexFirstRight = find(ptsDiff > lenBasic, 1);
    ptFirstRight = ptsNow(indexFirstRight + 1) - ptsDiff(indexFirstRight) + lenBasic;
    firstRights(i + 1) = ptFirstRight;
end

fprintf("The right ends of leftmost segments:\n")
disp(firstRights)
