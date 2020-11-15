%% Interactive Plots
% * Tutorial on how to create an interactive in MATLAB using Clickable Legend
% *     Toolbox which allows users to hide or unhide groups of data
% *
% * For references to clickableLegend function see:
% *     https://www.mathworks.com/matlabcentral/fileexchange/
% *      21799-clickablelegend-interactive-highlighting-of-data-in-figures
% *  NOTE: The function (togglevisibility) included in the toolbox had a
% *       minor coloring bug and was fixed. Refer to github repository for
% *       modified version of this script.
% *
% * The COVID-19 world data plotted in this tutorial comes from:
% *     https://ourworldindata.org/covid-hospitalizations
% *
% * To Do:
% *     - Add tutorial on how to do this with line plots or scatter plots
% *
% * Author: EunSeon Ahn, Yanyu Long, Tianshi Wang
% * Updated: Nov 12, 2020
% * ------------------------------------------------------------------------- *
% *
% * 79: --------------------------------------------------------------------- *

%% Data Prep
addpath('clickable_legend')

fileName = 'owid-covid-data.csv';
covid_orig = readtable(fileName);

% Select 2020-10-20 Data
newestDate = covid_orig.date(217);
covid_hosp = covid_orig(covid_orig.date == newestDate,:);
% Keep only countries that have hospitalization data
covid_hosp = covid_hosp(~isnan(covid_hosp.hosp_patients_per_million),:);

% Plotting the following variables:
%   # of deaths, # of cases, # of tests, # hospitalizations
voi = {'location', 'total_cases_per_million', ...
    'total_deaths_per_million','hosp_patients_per_million',...
    'total_tests_per_thousand'};

% Update dataset to only include variables of interest
covid_hosp = covid_hosp(:, voi);
% Convert total_tests_per_thousand to total_tests_per_million
covid_hosp(:,'total_tests_per_thousand') = ...
table(1000*covid_hosp.total_tests_per_thousand);
covid_hosp.Properties.VariableNames{5} = 'total_tests_per_million';

%% Plotting 
nCountries = 5;
X = categorical(covid_hosp.location(1:nCountries));

Y = [covid_hosp{1:nCountries,2}, covid_hosp{1:nCountries,3},...
    covid_hosp{1:nCountries,4}, covid_hosp{1:nCountries,5}];
figure
bar(X,Y)
clickableLegend({'Case','Death','Hosp','Test'}, 'Location', 'eastoutside');
title('Comparison of Cases, Deaths, Hospitaliations, and Testing')
xlabel('Countries')
ylabel('log10(# per million)')
set(gca, 'YScale', 'log')

% * 79: --------------------------------------------------------------------- *


