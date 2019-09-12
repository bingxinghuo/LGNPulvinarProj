%% regionplot.m
% This function plot only the manually segmented regions and save as eps
% file
% loads output from readanno3.m
function regionplot(regiondata,savefile)
R=17;
M=64;
% get the section range

        regionpoly=cell(R,1);
        figure, hold on
        for r=1:R
            if ~isempty(regiondata{r})
                subpolys=size(regiondata{r},2)/2;
                if subpolys==1
                    regionpoly{r}=polyshape(regiondata{r}(:,1)/M,regiondata{r}(:,2)/M);
                else
                    X=[];
                    Y=[];
                    for s=1:subpolys
                        X=[X,{regiondata{r}(:,(s-1)*2+1)/M}];
                        Y=[Y,{regiondata{r}(:,s*2)/M}];
                    end
                    regionpoly{r}=polyshape(X,Y);
                end
                %             else
                %             if ismember(r,[4:5])
                %             regionpoly{r}=polyshape([10001:10003],[10001:10003]);
                %             end
            end
            plot(regionpoly{r})
        end
        axis ij
        axis image
        alpha 1
        saveas(gcf,savefile,'epsc')
    
end