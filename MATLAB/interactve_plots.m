%% Interactive Plots
% * REQUIRES: user to have username and API key to access plotly
% *
% * Tutorial on how to create an interactive in MATLAB using 1.) Clickable
% * Legend Toolbox which allows users to hide or unhide groups of data
% * or 2.) using plotly for MATLAB toolbox
% *
% * For references to clickableLegend function, see:
% *     https://www.mathworks.com/matlabcentral/fileexchange/
% *      21799-clickablelegend-interactive-highlighting-of-data-in-figures
% *  NOTE: The function (togglevisibility) included in the toolbox had a
% *       minor coloring bug and was fixed. Refer to github repository for
% *       modified version of this script.
% * For references to plotly MATLAB toolbox, see:
% *     https://plotly.com/matlab/
% *
% * The COVID-19 world data plotted in this tutorial comes from:
% *     https://ourworldindata.org/covid-hospitalizations
% *
% * Author: EunSeon Ahn, Yanyu Long, Tianshi Wang
% * Updated: Nov 19, 2020
% * --------------------------------------------------------------------- *
% *
% * 79: ----------------------------------------------------------------- *

%% Data Prep
addpath('clickable_legend')

fileName = './Data/owid-covid-data.csv';
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

%% Plotting interactive bar graph with clickable Legend Toolbox
nCountries = 5;
X = categorical(covid_hosp.location(1:nCountries));

Y = [covid_hosp{1:nCountries,2}, covid_hosp{1:nCountries,3},...
    covid_hosp{1:nCountries,4}, covid_hosp{1:nCountries,5}];

sky = [166, 206, 227]/255;
blue = [29, 124, 180]/255;
liGreen = [178, 223, 138]/255;
green = [52, 164, 44]/255;

fig = figure;
b = bar(X,Y);
b(1).FaceColor = sky; b(1).EdgeColor = sky;
b(2).FaceColor = blue; b(2).EdgeColor = blue;
b(3).FaceColor = liGreen; b(3).EdgeColor = liGreen;
b(4).FaceColor = green; b(4).EdgeColor = green;

lgd = clickableLegend({'Case', 'Death', 'Hosp', 'Test'}, ...
    'Location', 'eastoutside');
title(lgd, 'Variable')
title('Comparison of # of Cases, Deaths, Hospitalizations, and Testing')
xlabel('Countries')
ylabel('log10(# per million)')
set(gca, 'YScale', 'log')
annotation('textbox', [0.82, 0.62, 0, 0], 'string', 'Variable')

%% Plotting interactive bar graph with plotly for MATLAB
% Requires that we have the plotly toolbox downloaded
% and assumes that plotlysetup has been completed with username and API key
addpath('./plotly-graphing-library-for-matlab-master');

countries = covid_hosp.location(1 : nCountries);
logY = log10(Y);

trace1 = struct(...
  'x', { countries }, ...
  'y', logY(:,1), ...
  'name', 'Total # Cases', ...
  'marker', struct('color', 'rgb(166, 206, 227)'),...
  'type', 'bar');
trace2 = struct(...
  'x', { countries }, ...
  'y', logY(:,2), ...
  'name', 'Total # Deaths', ...
  'marker', struct('color', 'rgb(29, 124, 180)'),...
  'type', 'bar');
trace3 = struct(...
  'x', { countries }, ...
  'y', logY(:,3), ...
  'name', 'Total # Hospitalized', ...
  'marker', struct('color', 'rgb(178, 223, 138)'),...
  'type', 'bar');
trace4 = struct(...
  'x', { countries }, ...
  'y', logY(:,4), ...
  'name', 'Total # Tested', ...
  'marker', struct('color', 'rgb(52, 164, 44)'),...
  'type', 'bar');


data = {trace1, trace2, trace3, trace4};
layout = struct('title', ...
    'Comparison of # of Cases, Deaths, Hospitalizations, and Testing',...
    'yaxis', struct(...
      'title', 'log10 (# per million)'),...
    'xaxis', struct(...
      'title', 'Countries'),...  
    'barmode', 'group', ...
    'legend', struct(...
      'x', 1.0, ...
      'y', 1.0, ...
      'bgcolor', 'rgba(255, 255, 255, 0)', ...
      'bordercolor', 'rgba(255, 255, 255, 0)'));
response = plotly(data, struct('layout', layout, ...
    'filename', 'grouped-bar', 'fileopt', 'overwrite'));
plot_url = response.url;


% * 79: ----------------------------------------------------------------- *


