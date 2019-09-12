% read manual annotated cells
% startcue: e.g. 'Add:[['
function cellcoord=readcellcoord(annotationtxt,startcue)
%% 1. Convert text file to cell coordinates
% from readanno3.m
% import text file as cell array
C=fileread(annotationtxt);
if nargin==1 % did not specify startcue
    addind0=strfind(C,'[');
    if length(addind0)>1
        cellseq=C(addind0(2):end); % ignore all the deleted regions
    end
elseif nargin>1
    addind0=strfind(C,startcue);
    C=C(addind0:end);
    cellseq=C((1+length(startcue)):end);
end
%
if ~isempty(cellseq)
    % read out cell coordinates
    cellseq(strfind(cellseq,'['))=[' '];
    cellseq(strfind(cellseq,']'))=[' '];
    cellseq(strfind(cellseq,','))=[' '];
    cellcoord_temp=sscanf(cellseq,'%f');
    % reorganize into x and y coordinates
    cellcoord=zeros(length(cellcoord_temp)/2,2);
    for i=1:length(cellcoord_temp)/2
        cellcoord(i,:)=cellcoord_temp((i-1)*2+1:i*2);
    end
    cellcoord=round(abs(cellcoord));
else
    cellcoord=[];
end
% %% 4. transform cell coordinates
% % from  xreg_cell.m
%     if ~isempty(cellcoord)
%         M=64;
%         tf=dlmread(transformtxt);
%         rotmat=[tf(1),tf(3);tf(2),tf(4)]; % rotation
%         transmat=tf(5:6)*M; % translation
%         % transform all cell coordinates
%         fbcelltf=rotmat*cellcoord'-transmat*ones(1,size(cellcoord,1));
%         % hold on, scatter(fbcelltf(1,:),fbcelltf(2,:),'y*')
%         %% 5. save cell coordinates for each Nissl section
%         FBnissl{fileinds_nissl(n)}=fbcelltf';
%     else
%         FBnissl{fileinds_nissl(n)}=[];
%     end