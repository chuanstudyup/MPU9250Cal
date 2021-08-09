%% 从文本文件中导入数据
% 用于从以下文本文件中导入数据的脚本:
%
%    filename: D:\研究生\研究\AHRS\MPU9250Cal\magData.csv
%
% 由 MATLAB 于 2021-06-26 17:14:44 自动生成

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);

% 指定范围和分隔符
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% 指定列名称和类型
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4"];
opts.VariableTypes = ["double", "double", "double", "double"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 导入数据
magData = readtable("D:\研究生\研究\AHRS\MPU9250Cal\magData.csv", opts);

%% 转换为输出类型
magData = table2array(magData);

%% 清除临时变量
clear opts
close all;
%% 磁力计校准 cal_mag = Km*(raw_mag-Bm)
raw_mag = [magData(:,2),magData(:,3),magData(:,4)];
[A,b,expmfs] = magcal(raw_mag); % calibration coefficients
expmfs; % Dipaly expected  magnetic field strength in uT
cal_mag = (raw_mag-b)*A;
Km = A'
Bm = b'

figure
plot3(magData(:,2),magData(:,3),magData(:,4),'LineStyle','none','Marker','X','MarkerSize',8)
hold on
grid(gca,'on')
plot3(cal_mag(:,1),cal_mag(:,2),cal_mag(:,3),'LineStyle','none','Marker', ...
            'o','MarkerSize',8,'MarkerFaceColor','r') 
axis equal
xlabel('uG')
ylabel('uG')
zlabel('uG')
legend('Uncalibrated Samples', 'Calibrated Samples','Location', 'southoutside')
title("Uncalibrated vs Calibrated" + newline + "Magnetometer Measurements")
hold off