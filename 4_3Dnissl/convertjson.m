%% This file converts the output data into json format
% It calls for savejson.m function from jsonlab-1.5 (Copyright to the
% author)
filelist=filelsread('*.mat');
% reorganize as brain regions
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
R=length(regionlist);
regions=cell(R,1);
secstart0=strfind(filelist{1},'N')+1;
secstart1=strfind(filelist{1},'--')-1;
sec1=str2double(filelist{1}(secstart0:secstart1));
%%
for f=1:length(filelist)
    load(filelist{f})
    for r=1:R
        
        secstart0=strfind(filelist{f},'N')+1;
        secstart1=strfind(filelist{f},'--')-1;
        secf=str2double(filelist{f}(secstart0:secstart1));
        if secf<120
            regions{r}{f}.z=(secf-sec1)*80;
        else
            regions{r}{f}.z=regions{r}{f-1}.z+80;
        end
        if ~isempty(regiondata{r})
            regions{r}{f}.xy=regiondata{r};
        end
    end
end
%%
jmesh=cell2struct(regions,regionlist,1);
savejson('',jmesh,'m920LGN.json');