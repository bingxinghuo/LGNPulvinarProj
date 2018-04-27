% brainROI.m
% Bingxing Huo, July 2011
% This script specifies the regions of interest in the OIS image
function ROIinfo=brainROI(sampleimg,regionalmap)
[rows,cols,c]=size(sampleimg);
figure
imagesc(sampleimg)
if c==1
    colormap('gray')
end
if nargin>1
    hold on, contour(regionalmap,'r')
end
% axis xy
axis image
title('Please select the subregions of interest:','fontsize',18)
ROI_count=input('How many small regions of interest do you want?  ');
disp('Please DOUBLE CLICK on the starting point upon completion of the polygon')
subarea=cell(ROI_count,3);
for i=1:ROI_count
    ystring=['y'];
    theinput=['n'];
    disp(['Select Region ' num2str(i) ' from the figure '])
    while (strcmp(ystring,theinput)~=1)
        [subarea{i},subarea{i,2},subarea{i,3}]=roipoly;
        area_obj=impoly(gca,[subarea{i,2},subarea{i,3}]);
        theinput=input('sub-region ok? y/n ','s');
        if    theinput=='n'
            delete(area_obj)
        end
    end
end
subROIsum=zeros(rows,cols);
for j=1:ROI_count
    subROIsum=subROIsum+subarea{j,1};
end
%plot sample Dalsa image
if c==1
    imagesc(subROIsum.*double(sampleimg))
    colormap('gray')
else
    sampleimggray=double(mean(sampleimg,3));
    imagesc(subROIsum.*sampleimggray)
end
ROIinfo.ROImap=subROIsum;
ROIinfo.ROIboundary=subarea;