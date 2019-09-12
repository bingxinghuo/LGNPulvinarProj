load('sectiontransition_ante.mat')
%%
% V1
figure
figax=cell(3,1);
for i=1:3
figax{i}=subplot(1,3,i);
imagesc([1:5],anteV1.dip,anteV1.cases{i}(:,3:7),[0 1])
axis xy
end
colormap gray
saveas(gcf,'V1transition_ante.eps')
close
% V2
figure
figax=cell(3,1);
for i=1:3
figax{i}=subplot(1,3,i);
imagesc([1:5],anteV1.dip,anteV2.cases{i}(:,3:7),[0 1])
axis xy
end
colormap gray
saveas(gcf,'V2transition_ante.eps')
close
% DM
figure
figax=cell(3,1);
for i=1:3
figax{i}=subplot(1,3,i);
imagesc([1:5],anteV1.dip,anteDM.cases{i}(:,3:7),[0 1])
axis xy
end
colormap gray
saveas(gcf,'DMtransition_ante.eps')
close
%%
for i=1:3
    casebinary=nansum(anteV1.cases{i})>0;
    V1cases(1:2,i)=casebinary(1:2);
    V1cases(3,i)=sum(casebinary(3:6))>0;
    V1cases(4,i)=casebinary(7);
end
%
for i=1:3
    casebinary=nansum(anteV2.cases{i})>0;
    V2cases(1:2,i)=casebinary(1:2);
    V2cases(3,i)=sum(casebinary(3:6))>0;
    V2cases(4,i)=casebinary(7);
end
%
for i=1:3
    casebinary=nansum(anteDM.cases{i})>0;
    DMcases(1:2,i)=casebinary(1:2);
    DMcases(3,i)=sum(casebinary(3:6))>0;
    DMcases(4,i)=casebinary(7);
end
%%
figure, subplot(1,3,1)
V1cases1=flip(V1cases,1);
bar(sum(V1cases1'))
ylim([0 3])
subplot(1,3,2)
V2cases1=flip(V2cases,1);
bar(sum(V2cases1'))
ylim([0 3])
subplot(1,3,3)
DMcases1=flip(DMcases,1);
bar(sum(DMcases1'))
ylim([0 3])
saveas(gcf,'regionterminals.eps')