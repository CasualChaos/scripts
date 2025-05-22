clear, clc

%Load the target 2d field file and an example point cloud file. Match the
%x,y values in the cloud to the format of the Nek idx. Fill anything that
%is not matched with -1. This value will then be used to fill those with
%zeroes later. 

addpath '/home/masmith/nekmatlab-master'
%addpath '/home/may/Documents/MATLAB/nekmatlab-master'
    %Load Nek and txt field files
[data_2d,lr1] = readnek('2D_RD_CH_ST_d20.f00001');
field = load("SPOD_P_mode_n_1_f_0.txt");

data_2d(:,:,5) = []; %Delete unnecessary u,v,p
data_2d(:,:,4) = [];
data_2d(:,:,3) = [];
%%
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

writematrix(match,"SPODmatchidx.txt")

function idx = finder(x,y,field)
idx = -1;
tol = 1e-6;
for i = 1:length(field)

    if and(abs(field(i,1)-x)<tol,abs(field(i,2)-y)<tol)
        idx = i;
    end

end
end

