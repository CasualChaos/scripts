addpath '/d/mlsmith/Documents/scripts/MATLAB/nekmatlab-master'
[data_2d,lr1,elmap,time,istep,fields,emode,wdsz,etag,header,status,metax,metau,metap,metat] = readnek('2D_RD_CH_ST_d20.f00001');

match = load('SPODmatchidx.txt'); %Load the created index. Made with createNekidx.m
idx = match;
idx(idx(:)== -1)= 1139943; %Set everything that did not find a match to and index of 1+ the length of the field file
                                %This number might need to be checked

list = dir('SPOD_P_*.txt');

for file = 1:length(list)
    clear field name outname splitName u newf
    fprintf('Loading %s \n',list(file).name)
    field = load(list(file).name); %load the point cloud
    splitName = split(list(file).name,'.txt'); % get file name
    name = cell2mat(splitName(1));
    outname = [name '0.f00001'];
    fprintf("Loaded")

    u = field(:,3);
    u(1139943) = 0; %Add an extra row to u with a value of 0
    
    newf = u(idx); %Match all the rows via the including the new zero row
    data_2d(:,:,3) = newf;

    newf = zeros(size(data_2d,1),size(data_2d,2)); %set other 2 fields to 0
    data_2d(:,:,4) = newf;
    data_2d(:,:,5) = newf;

    writenek("fldfiles/" + outname,data_2d,lr1,elmap,time,istep,fields,emode,wdsz,etag)
    fprintf("Saved %s \n", outname)
end