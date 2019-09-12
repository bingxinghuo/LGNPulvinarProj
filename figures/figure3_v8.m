% Fig 3B.
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
% regseq=[2,9,3,8,4,7,5,6,10];
% load('celldensity.mat')
% load('celldensity_v2.mat') % adjusted for injection areas (case swap)
load('celldensity_v3.mat') % adjusted M1144 cell count
% regions={'P';'M';'K234';'K1';'ip'};
regions={'P';'M';'K';'ip'};
cortex={'V1';'V2';'V6'};
inds.P=[2,3];
inds.M=[4,5];
% inds.K234=[7:9];
% inds.K1=6;
inds.K=[6:9];
inds.ip=10;
% Vs=load('celldensity.mat','V1','V2','V6');
% Vs=load('celldensity_v2.mat','V1','V2','V6');
Vs=load('celldensity_v3.mat','V1','V2','V6');
%% Fig. 3B
Vplot=cell(3,1);
Vbinary=cell(3,1);
Vbinaryall=cell(3,1);
for v=1:3
    C=cortex{v};
    for i=1:4
        T=regions{i};
        Vplot{v}.(T)=Vs.(C)(:,inds.(T));
        Vbinary{v}.(T)=mean(sum(Vplot{v}.(T),2)>0);
    end
end
figure
for v=1:3
    Vbinaryall{v}=cell2mat(struct2cell(Vbinary{v}));
    subplot(1,3,v), bar(Vbinaryall{v})
    ylim([0 1])
    title(cortex{v})
end
Vbinaryall1=cell2mat(Vbinaryall');
figure, bar(Vbinaryall1')
%% Fig. 3A
anteroV=load('anteromatrix.mat');
acortex={'anteroV1';'anteroV2';'anteroV6'};
regions={'P';'M';'K';'ip'};
ainds.P=[1,3];
ainds.M=[5,7];
ainds.K=[2,4,6,8];
ainds.ip=9;
aVplot=cell(3,1);
aVbinary=cell(3,1);
aVbinaryall=cell(3,1);
for v=1:3
    C=acortex{v};
    for i=1:4
        T=regions{i};
        aVplot{v}.(T)=anteroV.(C)(:,ainds.(T));
        aVbinary{v}.(T)=mean((sum(aVplot{v}.(T),2))>0);
    end
end
figure
for v=1:3
    aVbinaryall{v}=cell2mat(struct2cell(aVbinary{v}));
    subplot(1,3,v), bar(aVbinaryall{v})
    ylim([0 1])
    title(acortex{v})
end
aVbinaryall1=cell2mat(aVbinaryall');
figure, bar(aVbinaryall1')
%% calculate K layer and M&P layer average for Results report
pc=1.75;
% regions={'P';'M';'K234';'K1';'ip'};
V1seg.MP=V1(:,[inds.P,inds.M]);
V1seg.K=V1(:,inds.K);
V1seg.IPul=V1(:,inds.ip);
for i=1:2
    if V1seg.IPul(i)==0
        V1seg.IPul(i)=sum(V1(i,11:14));
    end
end
V2seg.MP=V2(:,[inds.P,inds.M]);
V2seg.K=V2(:,inds.K);
V2seg.IPul=V2(:,inds.ip);
for i=1:4
    if V2seg.IPul(i)==0
        V2seg.IPul(i)=sum(V2(i,11:14));
    end
end
V6seg.MP=V6(:,[inds.P,inds.M]);
V6seg.K=V6(:,inds.K);
V6seg.IPul=V6(:,inds.ip);
% area *4 is to correct the resolution problem; *.02 is the section thickness
V1segdensity.MP=sum(V1seg.MP,2)./pc./sum(V1regionarea(:,2:5)*4*.02,2);
V1segdensity.K=sum(V1seg.K,2)./pc./sum(V1regionarea(:,6:9)*4*.02,2);
V2segdensity.MP=sum(V2seg.MP,2)./pc./sum(V2regionarea(:,2:5)*4*.02,2);
V2segdensity.K=sum(V2seg.K,2)./pc./sum(V2regionarea(:,6:9)*4*.02,2);
disp(mean(V1segdensity.MP))
disp(mean(V1segdensity.K))
disp(mean(V2segdensity.MP))
disp(mean(V2segdensity.K))
% disp(mean(V6density1(:,[1,3,5,7])))
% disp(mean(V6density1(:,[2,4,6,8])))
%% Fig. 3C cell count, consolidate layers
pc=1.75;
Vscells=cell(3,1);
Vlayer=cell(3,1);
layercells=cell(3,1);
layercellsmean=cell(3,1);
for v=1:3
    C=cortex{v};
    Vsc=Vs.(C);
    for i=1:length(regions)
        T=regions{i};
        % cell count *4 to account for the gap between sections
        Vscells{v}.(T)=round(Vsc(:,inds.(T))/pc*4); % cell count for each layer and each case
        Vlayer{v}.(T)=sum(Vscells{v}.(T),2); % sum up cell count for consolidated layers
    end
    layercells{v}=cell2mat(transpose(struct2cell(Vlayer{v}))); % columns contain consolidated layers, rows contain cases
    layercellsmean{v}=mean(layercells{v},1); % average cell count across cases
end
layercells1=round(cell2mat(layercellsmean));
figure, bar(layercells1')
set(gca,'fontsize',14)
legend('V1','V2','V6')
set(gca,'fontsize',18)
hold on
for i=1:2
    plot(layercells{1}(i,:),'d')
end
for i=1:4
    plot(layercells{2}(i,:),'s')
end

plot(layercells{3},'o')
% figure, bar(layercells1)
%%
for v=1:3
    figure(v), clf, bar(flip(layercellsmean{v}))
    hold on
    cellerror=std(layercells{v},[],1);
    errorbar(flip(layercellsmean{v}),flip(cellerror),'Linestyle','none')
%     for i=1:size(layercells{v},1)
%         plot(layercells{v}(i,:),'o')
%     end
print(['regioncell_',cortex{v},'_v2.eps'],'-deps')
end