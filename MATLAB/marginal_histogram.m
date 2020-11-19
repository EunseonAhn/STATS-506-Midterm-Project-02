%% Marginal Histogram 
% * Tutorial on how to create marginal histogram in MATLAB using either
% *    'scatterhist' or building off of subplot functionality 
% *
% * For MATLAB help file on scatterhist functions refer to:
% *     https://www.mathworks.com/help/stats/scatterhist.html
% *
% * This script relies on the use of subaxis function, which comes from
% *      subaxis tool box:
% *          https://www.mathworks.com/matlabcentral/
% *                             fileexchange/3696-subaxis-subplot
% *
% * The COVID-19 racial data plotted in this tutorial comes from:
% *     https://covidtracking.com/race
% *
% * Author: EunSeon Ahn, Yanyu Long, Tianshi Wang
% * Updated: Nov 19, 2020
% * --------------------------------------------------------------------- *
% *
% * 79: ----------------------------------------------------------------- *

%% Date Prep 
% Read in data
fileName = './Data/Race Data Entry - CRDT.csv';
raceData = readtable(fileName);

%Select only 11/01/20 data
newestDate = 20201101;
raceData = raceData(raceData.Date == newestDate,:);

% Convert all case/death # to double
colnames = raceData.Properties.VariableNames;
for i = 3 : length(colnames)
    if iscell(raceData.(genvarname(colnames{i})))
        raceData.(genvarname(colnames{i})) = ...
        str2double(raceData.(genvarname(colnames{i})));
    end

end

%% Get race info
% Grabbing the different races identified in dataset
race_idx = find(contains(colnames, 'Deaths'));
race_idx = race_idx(2 : 10); % remove total and ethnicity info
races = raceData(end, race_idx);
raceID =  strrep(races.Properties.VariableNames,'Deaths_', '');

plotData = raceData(1 : end, {'Date', 'State', 'Cases_White', ...
    'Cases_Black', 'Cases_LatinX', 'Cases_Asian', 'Deaths_White', ...
    'Deaths_Black', 'Deaths_LatinX', 'Deaths_Asian'});

case_col = startsWith(plotData.Properties.VariableNames, 'Cases');
cases = table2array(plotData(:, case_col));
cases = reshape(cases, [], 1);

death_col = startsWith(plotData.Properties.VariableNames, 'Deaths');
deaths = table2array(plotData(:, death_col));
deaths = reshape(deaths, [], 1);

% Generate race labels matching the column vector for cases/deaths
race_label = [];
for i = 1 : 4
    race_label = [race_label; repmat(raceID(i), size(raceData,1), 1)];
end

%% Plotting (Marginal Histogram) using scatterhist
x = cases;
y = deaths;

% Specify color to be used for each race grouping
red = [236, 95, 97] / 255;
blue = [115, 165, 205] / 255;
green = [131, 199, 129] / 255;
purple = [173, 113, 182] / 255;
c_array = [red; blue; green; purple];

figure
% scatterhist does not allow us to adjust the transparency of the plots,
% to do this we can generate marginal histogram from scratch using subplot
h = scatterhist(x, y, 'Group', race_label, 'Style', 'bar', ...
    'marker', '.', 'Location', 'NorthEast', 'Direction', 'out', ...
    'color', c_array, 'MarkerSize', 16);

[leg,~] = legend('show');
title(leg,'Race')
xlabel('Cases')
ylabel('Deaths')
sgtitle('Total confirmed COVID-19 deaths vs. cases, U.S. States (11/03/20)') 

%% Using subplot to create marginal histogram
% we'll be using subaxis toolbox to minimize the margins between subplots
addpath('subaxis')

% scatterplots and bar plots have to be separately graphed for each group
% and overlaid, breaking race data into separate arrays
white = find(race_label == "White");
black = find(race_label == "Black");
latinx = find(race_label == "LatinX");
asian = find(race_label == "Asian");

figure(1)
clf
% first subplot -- y-data histogram
ah1 = subaxis(2, 2, 4, 'sh', 0, 'sv', 0.01, 'padding', 0, 'margin', 0.1);
p1 = histogram(deaths(white), 'Orientation', 'horizontal', ...
    'Normalization', 'probability', 'BinWidth', 1000, ...
    'Facecolor', red);
hold on
p2 = histogram(deaths(black), 'Orientation', 'horizontal', ...
    'Normalization', 'probability', 'BinWidth', 1000, ...
    'Facecolor', blue);
hold on
p3 = histogram(deaths(latinx), 'Orientation', 'horizontal', ...
    'Normalization', 'probability', 'BinWidth', 1000, ...
    'Facecolor', green);
hold on
p4 = histogram(deaths(asian), 'Orientation', 'horizontal', ...
    'Normalization', 'probability', 'BinWidth', 1000, ...
    'Facecolor', purple);

% x-data histogram
ah2 = subaxis(2, 2, 1,'sh', 0.03, 'sv', 0.03, 'padding', 0, 'margin', 0.1);
histogram(cases(white), 'Normalization', 'probability', ...
    'BinWidth', 20000, 'Facecolor', red)
hold on
histogram(cases(black), 'Normalization', 'probability', ...
    'BinWidth', 20000, 'Facecolor', blue)
hold on
histogram(cases(latinx), 'Normalization', 'probability', ...
    'BinWidth', 20000, 'Facecolor', green)
hold on
histogram(cases(asian), 'Normalization', 'probability', ...
    'BinWidth', 20000, 'Facecolor', purple)

% scatterplot
ah3 = subaxis(2, 2, 3, 'sh', 0.03, 'sv', 0.01, ...
    'padding', 0, 'margin', 0.1);
hold on
scatter(cases(white), deaths(white), 'filled', ...
     'MarkerFaceColor', red, 'Markerfacealpha', 0.6)
scatter(cases(black), deaths(black), 'filled', ...
    'MarkerFaceColor', blue, 'Markerfacealpha', 0.6)
scatter(cases(latinx), deaths(latinx), 'filled', ...
    'MarkerFaceColor', green, 'Markerfacealpha', 0.6)
scatter(cases(asian), deaths(asian), 'filled', ...
    'MarkerFaceColor', purple, 'Markerfacealpha', 0.6)

% Remove boxes and axes information from the histogram
linkaxes([ah1, ah3], 'y')
linkaxes([ah3, ah2], 'x')
ah1.Box = 'off';
% ah1.View = [180, -90]; % changing direction of histogram
ah1.Visible = 'off';
ah2.Visible = 'off';
ah2.Box = 'off';
%ah2.View = [0, -90]; % changing direction of histogram

% Create single universal legend
h = [p1;p2;p3;p4];
hold on
lgd = legend(h, 'White', 'Black', 'Latinx', 'Asian');
lgd.Box = 'off';
newPosition = [0.5 0.6 0.13 0.13];
newUnits = 'normalized';
set(lgd, 'Position', newPosition, 'Units', newUnits);
title(lgd, 'Races')

% Give title and label axis in scatterplot
sgtitle(['Total confirmed COVID-19 deaths vs. cases, ', ...
    'U.S. States (11/03/20)'])
xlabel('Cases')
ylabel('Deaths')


% * 79: ----------------------------------------------------------------- *
