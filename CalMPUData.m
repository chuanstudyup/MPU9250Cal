%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 10);

% 指定范围和分隔符
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% 指定列名称和类型
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 导入数据
rawData20210528 = readtable("D:\研究生\研究\AHRS\MPU9250Cal\rawData.csv", opts);

%% 转换为输出类型
rawData = table2array(rawData20210528);

%% 清除临时变量
clear opts
close all;
%% 分离静态和动态数据
[~,fix_point,rotation]=FindFixData(rawData,3);

%% 加速度陀螺仪校准 cal_acc=Ta*Ka*(raw_acc+Ba)
[Ta,Ka,Ba]=ICRA2014_acc(fix_point);

%% 陀螺仪校准 cal_gyro=Tg*Kg*(raw_gyro+Bg)
fprintf('Bg[deg/s]');
Bg=-mean(fix_point(:,4:6),1)'
Bg = Bg*pi/180;
n=size(rotation,1);
rotation{n+1}=Ta;
rotation{n+2}=Ka;
rotation{n+3}=Ba;
rotation{n+4}=Bg;
[Tg,Kg]=ICRA_2014_gyro(rotation);

%% 磁力计校准 cal_mag = Km*(raw_mag-Bm)
raw_mag = [rawData(:,8),rawData(:,9),rawData(:,10)];
[A,b,expmfs] = magcal(raw_mag); % calibration coefficients
expmfs; % Dipaly expected  magnetic field strength in uT
cal_mag = (raw_mag-b)*A;
Km = A'
Bm = b'

figure
plot3(rawData(:,8),rawData(:,9),rawData(:,10),'LineStyle','none','Marker','X','MarkerSize',8)
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

%% 计算磁场北向分量和地向分量
[magN,magD] = magVector(fix_point,Ta,Ka,Ba,Km,Bm);