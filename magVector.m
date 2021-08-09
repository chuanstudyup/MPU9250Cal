function [Vn,Vd]=magVector(fixData,Ta,Ka,Ba,Km,Bm)

raw_acc = Ta*Ka*(fixData(1,1:3)'+Ba);
cal_acc = [-raw_acc(1);raw_acc(2);raw_acc(3)];
cal_acc = cal_acc/norm(cal_acc);
raw_mag = Km*(fixData(1,7:9)'-Bm);
cal_mag = [raw_mag(2);-raw_mag(1);raw_mag(3)];
Vn = norm(cross(cal_mag,cal_acc));
Vd = dot(cal_mag,cal_acc);
fprintf('寻优起点: Vn=%f,Vd=%f',Vn,Vd);
a0 = [Vn Vd]; %寻优起点

options=optimset('TolX',1e-6,'TolFun',1e-6,'Algorithm','Levenberg-Marquardt',...
  'Display','iter','MaxIter',50);

input = {fixData,Ta,Ka,Ba,Km,Bm};

[a,resnorm]=lsqnonlin(@calMagVecotr,a0,[],[],options,input);

Vn = a(1);
Vd = a(2);
fprintf('寻优终点: Vn=%f,Vd=%f',Vn,Vd);
magVector = [Vn,0,Vd];
magVector = magVector/norm(magVector)
end

function E=calMagVecotr(a, x)

fixData = x{1};
Ta = x{2};
Ka = x{3};
Ba = x{4};
Km = x{5};
Bm = x{6};

for i=1:size(fixData,1)
    raw_acc = Ta*Ka*(fixData(i,1:3)'+Ba);
    cal_acc = [-raw_acc(1);raw_acc(2);raw_acc(3)];
    cal_acc = cal_acc/norm(cal_acc);
    
    raw_mag = Km*(fixData(i,7:9)'-Bm);
    cal_mag = [raw_mag(2);-raw_mag(1);raw_mag(3)];
   
    E((i-1)*2+1,1) = (a(1)-norm(cross(cal_mag,cal_acc)));
    E((i-1)*2+2,1) = (a(2)-dot(cal_mag,cal_acc));
end

end
