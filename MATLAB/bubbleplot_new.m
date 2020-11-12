%% bubble Plot
% * Tutorial on how to create a bubble plot in MATLAB using 'bubblechart'
% *   function
% *
% * For MATLAB help file on bubblechart see:
% *     https://www.mathworks.com/help/matlab/ref/bubblechart.html
% * 
% * The COVID-19 world data plotted in this tutorial comes from:
% *     https://ourworldindata.org/covid-hospitalizations
% *
% * Author: EunSeon Ahn, Yanyu Long, Tianshi Wang
% * Updated: Nov 12, 2020
% * ------------------------------------------------------------------------- *
% *
% * 79: --------------------------------------------------------------------- *

%% Data Prep
fileName = 'owid-covid-data.csv';
covid_orig = readtable(fileName);
covid_orig.human_development_index = str2double(...
    covid_orig.human_development_index);

%Select 2020-10-20 Data
newestDate = covid_orig.date(217);
covid = covid_orig(covid_orig.date == newestDate,:);
sum(isnan(covid.stringency_index))
sum(isnan(covid.human_development_index))

% Variables of interest (VOI)
voi = {'location', 'continent', 'total_cases_per_million', ...
    'total_deaths_per_million','stringency_index',...
    'human_development_index'};

% Remove international and world info and keep only variables of interest
covid = covid(1:end-2, voi);

% Convert continent label to color label to be used in bubble plot
for k = 1 : size(covid, 1)
    if strcmp(covid.continent(k), 'Africa')
       covid.continent{k} = 1;
    elseif strcmp(covid.continent(k), 'Asia')
       covid.continent{k} = 2;
    elseif strcmp(covid.continent(k), 'Europe')
        covid.continent{k} = 3;
    elseif strcmp(covid.continent(k), 'North America')
        covid.continent{k} = 4;
    elseif strcmp(covid.continent(k), 'Oceania')
        covid.continent{k} = 5;
    elseif strcmp(covid.continent(k), 'South America')
        covid.continent{k} = 6;
    end
end

covid = sortrows(covid, 2);

x = table2array(covid(:,5)); % x-axis: Stringency index
y = table2array(covid(:,6)); % y-axis: Human development index
sz = table2array(covid(:,4)); % size: Total deaths per million
c = cell2mat(table2array(covid(:,2))); % color: continent

% To achieve different colors for each continent, we have to overlay
% multiple bubble charts on top of one another. We need separated data to
% do this.
% Stringency index of countries grouped by continent
x1 = x(c==1); x2 = x(c==2); x3 = x(c==3);
x4 = x(c==4); x5 = x(c==5); x6 = x(c==6);
% Human development index of countries grouped by continent
y1 = y(c==1); y2 = y(c==2); y3 = y(c==3); 
y4 = y(c==4); y5 = y(c==5); y6 = y(c==6);
% Total Deaths per mil. of countries grouped by continent
sz1 = sz(c==1); sz2 = sz(c==2); sz3 = sz(c==3);
sz4 = sz(c==4); sz5 = sz(c==5); sz6 = sz(c==6);

%% Plot data in a tiled chart layout
figure
t = tiledlayout(1,1);
nexttile
bubblechart(x1,y1,sz1)
hold on
bubblechart(x2,y2,sz2)
hold on
bubblechart(x3,y3,sz3)
hold on
bubblechart(x4,y4,sz4)
hold on
bubblechart(x5,y5,sz5)
hold on
bubblechart(x6,y6,sz6)
hold off

title('Total # of Deaths Across Gov. Stringency Index and Human Development Index')
xlabel('Stringency Index (100 - strictest)')
ylabel('Human Development Index')

blgd = bubblelegend('Total Death (Per Mil.)','Location','eastoutside');
lgd = legend('Africa','Asia', 'Europe', 'N. America', 'Oceania', 'S. America');

blgd.Layout.Tile = 'east';
lgd.Layout.Tile = 'east';

% Adjust opacity of the bubbles
b1.MarkerFaceAlpha = 0.4; b2.MarkerFaceAlpha = 0.4;
b3.MarkerFaceAlpha = 0.4; b4.MarkerFaceAlpha = 0.4;
b5.MarkerFaceAlpha = 0.4; b6.MarkerFaceAlpha = 0.4;

%% Example of how to specify color of the bubbles
% Can specify color during initial call to the function
ex1 = bubblechart(x1,y1,sz1, "red");

% Can change the color once the figure has been plotted by assigning RGB
% value
ex2 = bubblechart(x1,y1,sz1, "red");
ex2.CData = [0 0 0];

% * 79: --------------------------------------------------------------------- *





