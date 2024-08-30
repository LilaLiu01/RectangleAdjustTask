%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   trendAnalysis.m Dec 02, 2023
%   Sean Liu
%   Tbc...

%% Plot the main results of raw data and baseline-corrected data
clc
clear all
close all
cd ExpData/
figure;
load('ratioAll_onoff.mat'); % raw data
rawAdj = 100*(0.005*rawAdj + 0.795); % convert to apparent skew

TestNum = 50;
SubNum = 1;
SessionNum = 10;
TestperSession = TestNum/SessionNum; % 5

first_BaseIdx = 1:TestperSession*2:TestNum;
second_BaseIdx = 6:TestperSession*2:TestNum;
grandmn = mean(rawAdj(8,1:TestNum),1,'omitnan');
load('grandStdErr.mat');
% grandStdErr = std(rawAdj(6,1:TestNum),1,'omitnan')/sqrt(size(rawAdj(1:SubNum,1:TestNum),1));


% set the index
BaseIdx = 1:TestperSession:TestNum;
X = [1:TestperSession,  %1:5
    TestperSession+2:2*TestperSession+1,   %7:11
    2*TestperSession+4:3*TestperSession+3,   %14:18
    3*TestperSession+5:4*TestperSession+4,   %20:24
    4*TestperSession+7:5*TestperSession+6,   %27:31
    5*TestperSession+8:6*TestperSession+7,   %33:37
    6*TestperSession+10:7*TestperSession+9,   %40:44
    7*TestperSession+11:8*TestperSession+10,   %46:50
    8*TestperSession+13:9*TestperSession+12,   %53:57
    9*TestperSession+14:10*TestperSession+13];   %59:63
X = reshape(X.', 1, []);

% color the background for 2nd session in each day
div = [6, 12.5, 19, 25.5, 32, 38.5, 45, 51.5, 58, 64.5];
for i = 1:2:length(div)-1
    v = [div(i) 80; div(i+1) 80; div(i+1) 120; div(i) 120];
    f = [1 2 3 4];
    patch('Faces',f,'Vertices',v,...
        'EdgeColor','white','FaceColor','[.467 .078 .020]','LineWidth',0.5,'FaceAlpha',0.4);
end
hold on

% error bars and marker
for i = 1:SessionNum
    errorbar(X((i-1)*TestperSession+2:(i-1)*TestperSession+4), ...
        grandmn((i-1)*TestperSession+2:(i-1)*TestperSession+4), ...
        grandStdErr((i-1)*TestperSession+2:(i-1)*TestperSession+4), ...
        'color',[0.75,0.75,0.75],'LineWidth',2);
    hold on
    on_line = plot(X((i-1)*TestperSession+2:(i-1)*TestperSession+4), ...
        grandmn((i-1)*TestperSession+2:(i-1)*TestperSession+4), ...
        'k.-','MarkerSize',30,'Color',[0 0.4470 0.7410],'LineWidth',2);
    hold on
    errorbar(X((i-1)*TestperSession+5), ...
        grandmn((i-1)*TestperSession+5), ...
        grandStdErr((i-1)*TestperSession+5), ...
        'color',[0.75,0.75,0.75],'LineWidth',2);
    hold on
    after_line = plot(X((i-1)*TestperSession+5), ...
        grandmn((i-1)*TestperSession+5), ...
        'k.-','MarkerSize',30,'Color',[0.4660 0.6740 0.1880],'LineWidth',2,'MarkerFaceColor',[0.6,0.9,0.6]);    
    hold on
end
lgd = [on_line, after_line];

% line the baseline
baseline = plot(X(BaseIdx),grandmn(BaseIdx),'Color',[0 0 0],'LineStyle','-','MarkerSize',30,'LineWidth',2); 
hold on
for i = 1:length(BaseIdx)
    errorbar(X(BaseIdx(i)),grandmn(BaseIdx(i)),grandStdErr(BaseIdx(i)),'color',[0.75,0.75,0.75],'LineWidth',2);
    hold on
end

% mark the baseline
sz = 75;
c1 = [0 0 0];
mk1 = scatter(X(first_BaseIdx),grandmn(first_BaseIdx),sz,c1,'filled'); 
hold on
mk2 = scatter(X(second_BaseIdx),grandmn(second_BaseIdx),sz,c1,'filled');
hold on
lgd = [lgd, baseline];

% Figure explanation
ylabel('Aspect Ratio (%)');
xlabel('Day');
title('Sub8');
xticks([6:13:58]);
xticklabels({'1','2','3','4','5'});
xlim([0 64])
ylim([97 105])
% ylim for baseline corrected
% ylim([-80,20])
labels = {'Glasses on', 'Glasses off', 'Baseline'};
% legend_obj = legend(lgd, labels, 'Location', 'best');
% set(legend_obj, 'FontSize', 15);
set(gca,'FontSize',25);
box on
