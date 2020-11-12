%% Marginal Histogram 
% * Tutorial on how to create marginal histogram in MATLAB using both
% *    'scatterhist' and 'scatterhistogram' function 
% *
% * For MATLAB help file on these functions refer to:
% *     https://www.mathworks.com/help/stats/scatterhist.html
% *     https://www.mathworks.com/help/matlab/ref/scatterhistogram.html
% *
% * The COVID-19 racial data plotted in this tutorial comes from:
% *     https://covidtracking.com/race
% *
% * Author: EunSeon Ahn, Yanyu Long, Tianshi Wang
% * Updated: Nov 12, 2020
% * ------------------------------------------------------------------------- *
% *
% * 79: --------------------------------------------------------------------- *

%% Date Prep 
% Read in data
fileName = 'Race Data Entry - CRDT.csv';
raceData = readtable(fileName);

%Select only 11/01/20 data
newestDate = 20201101;
raceData = raceData(raceData.Date == newestDate,:);

% Convert all case/death # to double
colnames = raceData.Properties.VariableNames;
for i = 3:length(colnames)
    if iscell(raceData.(genvarname(colnames{i})))
        raceData.(genvarname(colnames{i})) = ...
        str2double(raceData.(genvarname(colnames{i})));
    end

end

%% Get race info
% Grabbing the different races identified in dataset
race_idx = find(contains(colnames,'Deaths'));
race_idx = race_idx(2:10); % remove total and ethnicity info
races = raceData(end, race_idx);
raceID =  strrep(races.Properties.VariableNames,'Deaths_','');

% Grab cases and deaths for each race, convert to column vector
cases = [];
%cases = table2array(raceData(1:end, 4:12)); % for all races
cases = table2array(raceData(1:end, 4:7));
cases = reshape(cases,[],1);
deaths = [];
%deaths = table2array(raceData(1:end, 17:25)); % for all races
deaths = table2array(raceData(1:end, 17:20)); 
deaths = reshape(deaths,[],1);

% Generate race labels matching the column vector for cases/deaths
race_label = [];
for i = 1:4
    race_label = [race_label; repmat(raceID(i),size(raceData,1),1)];
end


%% Plotting (Marginal Histogram)

x = cases;
y = deaths;
figure
% Alternatiely, we could be using scatterhistogram function but this
% requires MATLAB version R2018b minimum. This allows us to adjust transparency
% of the plotted points.
h = scatterhist(x,y,'Group',race_label, 'Style','bar', 'marker','o');
xlabel('Cases')
ylabel('Deaths')
title('Total confirmed COVID-19 deaths vs. cases, U.S. States (11/03/20)') 


%% Switching from histogram to boxplot

% If wanting to put bax plots instead
hold on;
clr = get(h(1),'colororder');
boxplot(h(2),x,race_label,'orientation','horizontal',...
     'label',{'','','',''},'color',clr);
boxplot(h(3),y,race_label,'orientation','horizontal',...
     'label', {'','','',''},'color',clr);
set(h(2:3),'XTickLabel','');
view(h(3),[270,90]);  % Rotate the Y plot
axis(h(1),'auto');  % Sync axes
hold off;
% * 79: --------------------------------------------------------------------- *







