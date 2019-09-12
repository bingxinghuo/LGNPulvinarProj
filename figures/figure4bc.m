close all
clear all
% load('sectiontransition_review1.mat')
% load('sectiontransition_review1_v2.mat')
load('sectiontransition_review1_v3.mat')
%% V1
cases1=size(V1cellcount,1);
V1cellall=uint8(zeros(15,5,cases1));
Dip=V1cellcount{1}(:,1);
for a=1:cases1
    for i=1:5
        for j=1:length(Dip)
            V1cellall(j,i,a)=V1cellcount{a}(j,i+1);
        end
    end
end
V1cellave=nanmean(V1cellall,3);
%% V2
cases2=size(V2cellcount,1);
V2cellall=uint8(zeros(14,5,cases2));
Dip=V2cellcount{1}(:,1);
for a=1:cases2
    for i=1:5
        for j=1:length(Dip)
            V2cellall(j,i,a)=V2cellcount{a}(j,i+1);
        end
    end
end
V2cellave=nanmean(V2cellall,3);
%% V6
cases3=size(V6cellcount,1);
V6cellall=uint8(zeros(15,5,cases3));
Dip=V6cellcount{1}(:,1);
for a=1:cases3
    for i=1:5
        for j=1:length(Dip)
            V6cellall(j,i,a)=V6cellcount{a}(j,i+1);
        end
    end
end
V6cellave=nanmean(V6cellall,3);
%% individual plot
figure(1), colormap hot
for a=1:cases1
    subplot(1,cases1,a), imagesc(V1cellcount{a}(1:15,2:end))
    title(['V1, ',V1cellanimals{a}])
    %     axis off
    yticks([2,4,6,8,10,12,14])
    yticklabels(num2str(V1cellcount{a}([2,4,6,8,10,12,14],1)))
    caxis([0 30])
end

figure(2), colormap hot
for a=1:cases2
    subplot(1,cases2,a), imagesc(V2cellcount{a}(1:14,2:end))
    title(['V2, ',V2cellanimals{a}])
    %     axis off
    yticks([2,4,6,8,10,12,14])
    yticklabels(num2str(V2cellcount{a}([2,4,6,8,10,12,14],1)))
    caxis([0 30])
end

figure(3), colormap hot
for a=1:cases3
    subplot(1,cases3,a), imagesc(V6cellcount{a}(1:15,2:end))
    title(['V6, ',V6cellanimals{a}])
    %     axis off
    yticks([2,4,6,8,10,12,14])
    yticklabels(num2str(V6cellcount{a}([2,4,6,8,10,12,14],1)))
    caxis([0 30])
end
%% correct for profile-to-cell ratio
Vallcellcount{1}=V1cellcount;
Vallcellcount{2}=V2cellcount;
Vallcellcount{3}=V6cellcount;
figure
for i=1:3
    for r=1:5
    subplot(5,3,(r-1)*3+i), hold on
    for a=1:size(Vallcellcount{i},1)
        plot(Vallcellcount{i}{a}(:,1),Vallcellcount{i}{a}(:,r+1)/1.75*4)
    end
    end
end