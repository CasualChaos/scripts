clear, clc
%OUTDATED
%Writes an index to rearrange a full field file. Also contains the chunks
%from first testing using the index to create a reorganised dataset to
%write.


addpath '/home/may/Documents/MATLAB/nekmatlab-master'
    %Load Nek and txt field files
[data_2d,lr1,elmap,time,istep,fields,emode,wdsz,etag,header,status,metax,metau,metap,metat] = readnek('2D_RD_CH_ST_d20.f00001');
field = load("avg08.txt.sorted");
%%
data_2d(:,:,5) = [];
data_2d(:,:,4) = [];
data_2d(:,:,3) = [];
match = zeros(size(data_2d,1),size(data_2d,2));
fprintf("Loaded.\n")
%%
for element = 1:length(data_2d)
    for point = 1:lr1(1)*lr1(2)*lr1(3)
        x = data_2d(element,point,1);
        y = data_2d(element,point,2);

        idx = finder(x,y,field);
        if idx == -1
            fprintf("Hek. [%d,%d] \n",element,point)
        end

        match(element,point) = idx;       

    end
end
%%
field = load("avg08.txt.sorted");
u = field(:,3);
newf = u(match);
data_2d(:,:,3) = newf;
u = field(:,4);
newf = u(match);
data_2d(:,:,4) = newf;
u = field(:,6);
newf = u(match);
data_2d(:,:,5) = newf;
writenek('newFld0.f00001',data_2d,lr1,elmap,time,istep,fields,emode,wdsz,etag)

%%
function idx = finder(x,y,field)
idx = -1;
tol = 1e-6;
for i = 1:length(field)

    if and(abs(field(i,1)-x)<tol,abs(field(i,2)-y)<tol)
        idx = i;
    end
        
end
end