%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 10);

% ָ����Χ�ͷָ���
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% ָ�������ƺ�����
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% ָ���ļ�������
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% ��������
rawData20210528 = readtable("D:\�о���\�о�\AHRS\MPU9250Cal\rawData.csv", opts);

%% ת��Ϊ�������
rawData = table2array(rawData20210528);

%% �����ʱ����
clear opts
close all;
%% ���뾲̬�Ͷ�̬����
[~,fix_point,rotation]=FindFixData(rawData,3);

%% ���ٶ�������У׼ cal_acc=Ta*Ka*(raw_acc+Ba)
[Ta,Ka,Ba]=ICRA2014_acc(fix_point);

%% ������У׼ cal_gyro=Tg*Kg*(raw_gyro+Bg)
fprintf('Bg[deg/s]');
Bg=-mean(fix_point(:,4:6),1)'
Bg = Bg*pi/180;
n=size(rotation,1);
rotation{n+1}=Ta;
rotation{n+2}=Ka;
rotation{n+3}=Ba;
rotation{n+4}=Bg;
[Tg,Kg]=ICRA_2014_gyro(rotation);

%% ������У׼ cal_mag = Km*(raw_mag-Bm)
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

%% ����ų���������͵������
[magN,magD] = magVector(fix_point,Ta,Ka,Ba,Km,Bm);