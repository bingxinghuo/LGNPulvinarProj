% Fig 3B.
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
regseq=[2,9,3,8,4,7,5,6,10];
%%
load('celldensity.mat')
V1plot=V1(:,regseq);
V2plot=V2(:,regseq);
V1binary=V1>0;
V2binary=V2>0;
Vprobability(1,:)=mean(V1binary);
Vprobability(2,:)=mean(V2binary);
V6=[3,1,1,0,1,0,0,1,129]; % in final output order already
V6binary=V6>0;
Vprobability(3,:)=V6binary;
figure, imagesc(Vprobability), colormap gray
%% Fig. 3C
pc=1.75;
V1density1=V1density(:,regseq)/pc;
V2density1=V2density(:,regseq)/pc;
% m920 V6 case
V6regionarea1=V6regionarea([1:3,5:7,9:end],regseq);
V6vol=sum(V6regionarea1)*4*.02;
V6density1=V6./V6vol/pc;
%
Vdensity=[mean(V1density1,1);mean(V2density1,1);mean(V6density1,1)];
figure, bar(Vdensity')
set(gca,'fontsize',14)
legend('V1','V2','V6')
set(gca,'fontsize',18)
hold on
for i=1:2
    plot([1:9],V1density1(i,:),'d')
end
for i=1:4
    plot([1:9],V2density1(i,:),'s')
end
%% calculate K layer and M&P layer average for Results report
V1seg.MP=V1(:,2:5);
V1seg.K=V1(:,6:9);
V1seg.IPul=V1(:,10);
for i=1:2
    if V1seg.IPul(i)==0
        V1seg.IPul(i)=sum(V1(i,11:14));
    end
end
V2seg.MP=V2(:,2:5);
V2seg.K=V2(:,6:9);
V2seg.IPul=V2(:,10);
for i=1:4
    if V2seg.IPul(i)==0
        V2seg.IPul(i)=sum(V2(i,11:14));
    end
end
V6seg.MP=V6(:,[1,3,5,7]);
V6seg.K=V6(:,[2,4,6,8]);
V6seg.IPul=V6(:,9);
%
V1segdensity.MP=sum(V1seg.MP,2)./pc./sum(V1regionarea(:,2:5)*4*.02,2);
V1segdensity.K=sum(V1seg.K,2)./pc./sum(V1regionarea(:,6:9)*4*.02,2);
V2segdensity.MP=sum(V2seg.MP,2)./pc./sum(V2regionarea(:,2:5)*4*.02,2);
V2segdensity.K=sum(V2seg.K,2)./pc./sum(V2regionarea(:,6:9)*4*.02,2);
disp(mean(V1segdensity.MP))
disp(mean(V1segdensity.K))
disp(mean(V2segdensity.MP))
disp(mean(V2segdensity.K))
disp(mean(V6density1(:,[1,3,5,7])))
disp(mean(V6density1(:,[2,4,6,8])))
%% Fig. 3C new
pc=1.75;
V11=round(V1(:,regseq)/pc);
V21=round(V2(:,regseq)/pc);
% m920 V6 case
% V6regionarea1=V6regionarea([1:3,5:7,9:end],regseq);
V6vol=sum(V6regionarea1)*4*.02;
V6density1=V6./V6vol/pc;
V61=round(V6/pc);
%
Vcount=[mean(V11,1);mean(V21,1);mean(V61,1)];
for v=1:3
    figure(v), clf
    h1=subplot(1,3,1:2); bar(Vcount(v,1:8)'); hold on
    set(gca,'fontsize',14)
    % legend('V1','V2','V6')
    % set(gca,'fontsize',18)
    h2=subplot(1,3,3); bar(Vcount(v,9)'); hold on
    if v==1
        for i=1:2
            plot(h1,[1:8],V11(i,1:8),'d')
            plot(h2,1,V11(i,9),'d')
        end
    elseif v==2
        for i=1:4
            plot(h1,[1:8],V21(i,1:8),'d')
            plot(h2,1,V21(i,9),'d')
        end
    end
    saveas(gcf,['V',num2str(v),'cellcount.eps'],'epsc')
end
%%
V=[mean(V11,1);mean(V21,1);mean(V61,1)];
figure, bar(V')
set(gca,'fontsize',14)
legend('V1','V2','V6')
set(gca,'fontsize',18)
hold on
for i=1:2
    plot([1:9],V11(i,:),'d')
end
for i=1:4
    plot([1:9],V21(i,:),'s')
end