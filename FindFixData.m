function [PP,fix_point,rotation]=FindFixData(cal,threshold)

% author  Zhang Xin

%% 根据合角速度模长提取出静止状态下的数据段
% 矩阵P用来标记静止数据段的起止位置，行数代表段的数量，
% 每行的第一列指出该数据段的在原始数据的起始行，第二列为该段的结束行
n=size(cal,1);
j=1;
for i=1:n
    norm_gyro(i,1)=norm(cal(i,5:7));
    if i==1
        if norm_gyro(i)<threshold
            P(j,1)=i;
        end
    else
        if norm_gyro(i)<=threshold&&norm_gyro(i-1)>threshold
            P(j,1)=i;
        end
        if norm_gyro(i)>threshold&&norm_gyro(i-1)<=threshold
            P(j,2)=i-1;
            j=j+1;
        end
    end
end

%% 提取与分离原始数据
% 判断上述提取出的静止段的长度是否大于20，满足就将该段的数据求均值作为该静止状态下传感器的数值放进fix_point
% 将运动数据段放入到rotation中
j=1;
for i=1:size(P,1)-1
    if P(i,2)-P(i,1)>200
        PP(j,1)=P(i,1);
        PP(j,2)=P(i,2);        
        fix_point(j,:)=mean(cal(PP(j,1):PP(j,2),2:10),1);
        if j>=2
            rotation{j-1,1}=cal(PP(j-1,2)-30:PP(j,1)+30,:);
        end
        j=j+1;
    end
end

%% 绘图，标记出静止段
figure 
plot(1:n,norm_gyro,'b')
for j=1:size(PP,1)
   hold on
   plot(PP(j,1),norm_gyro(PP(j,1)),'ro');
   hold on
   plot(PP(j,2),norm_gyro(PP(j,2)),'ko');
end
xlabel('Samples[0.01s]');
ylabel('合角速度模长');
end
