clear, clc

%Load 2D field file of the same case and then load point cloud for dataset. Zero
%all the vectors of the field and then locate the points from the cloud and
%paste those points in.
%In the future add a fuction to shift points to set LE at (0,0).
%Maybe add a writer for an outfile that lists the fields written.


addpath '/home/may/Documents/scripts/MATLAB/nekmatlab-master'
    %Load Nek and txt field files
[data_2d,lr1,elmap,time,istep,fields,emode,wdsz,etag,header,status,metax,metau,metap,metat] = readnek('2D_RD_CH_ST_d20.f00001');
field = load("avg00.txt.sorted");

%%
field1 = zeros(size(data_2d,1),size(data_2d,2));
field2 = zeros(size(data_2d,1),size(data_2d,2));
field3 = zeros(size(data_2d,1),size(data_2d,2));

xmin = -0.15;
xmax = 3;
ymin = -0.3;
ymax = 0.3;
tol = 1e-6;

% for macro = 1:length(data_2d)
%     if data_2d(macro,1,1)<xmin || data_2d(macro,1,2)<ymin || data_2d(macro,1,1)>xmax || data_2d(macro,1,2) > ymax
%         data_2d(macro,:,3) = 0;
%         data_2d(macro,:,4) = 0;
%         data_2d(macro,:,5) = 0;
% 
% 
%     end
% end
% fprintf("done.\n")
% writenek('test0.f00001',data_2d,lr1,elmap,time,istep,fields,emode,wdsz,etag)

%%


for point = 1:length(field)

    x = field(point,1);
    y = field(point,2);
    
    for element = 1:length(data_2d)
        macroX = data_2d(element,1,1);
        macroY = data_2d(element,1,2);

        if macroX > xmin && macroX < xmax
            if macroY > ymin && macroY < ymax
                %then we search
                for spectral = 1:lr1(1)*lr1(2)*lr1(3)
                    %if x and y are in tolerance
                    if abs(x-data_2d(element,spectral,1))<tol && abs(y-data_2d(element,spectral,2))<tol
                        field1(element,spectral) = field(point,3);
                        field1(element,spectral) = field(point,4);
                        field1(element,spectral) = field(point,5);
                    end
                end                
    
            end
        end
    end
   
end

data_2d(:,:,3) = field1;
data_2d(:,:,4) = field2;
data_2d(:,:,5) = field3;
writenek('new0.f00001',data_2d,lr1,elmap,time,istep,fields,emode,wdsz,etag)
