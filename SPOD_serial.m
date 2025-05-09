clear, clc

addpath '/home/may/Documents/scripts/spod_matlab-master'
    %Set params
first_samp = 0;
last_samps = 25;
samps_per_run = 2000;

folder_root = '100hzRD_d2_';

    %Calc variables

tot_samps = last_samps - first_samp;

snapshots = cell(tot_samps,1);
folders = ceil(tot_samps/samps_per_run);
lastSamp = fullfile(pwd,[folder_root num2str(folders,'%01d')], ...
    ['avg' num2str((last_samps-1) - (floor(tot_samps/samps_per_run))*samps_per_run,'%02d') '.txt.sorted']);
%Matlab indexing starts at 1 not 0
fprintf('SPOD get!\n')
fprintf('Total samples: %i \n',tot_samps)
fprintf('Folders: %i \n', folders)
fprintf('Creating list of snapshots to load...\n')

for i = 1:folders
    Folder=fullfile(pwd,[folder_root num2str(i,'%01d')]);
    % fprintf('%s \n', Folder)
    for j = 0:samps_per_run
        filename = ['avg' num2str(j,'%02d') '.txt.sorted'];
        filepath = fullfile(Folder,filename);
        snapshots{(i-1)*samps_per_run + (j+1),1} = filepath;
        if strcmp(filepath,lastSamp) == 1
            break % for wotsits that don't break even with samples per run
        end
    end
end
fprintf('Snapshot list created. \n First: %s \n Last:  %s \n',snapshots{1,1},snapshots{tot_samps,1})

%%
fprintf('Load index file.\n')
idx_file = load(snapshots{1});
idx = zeros(length(idx_file),1);
fprintf('Loaded\n')
xmin = -0.15;
xmax = 3;
ymin = -0.3;
ymax = 0.3;
fprintf('Domain will extend from (%.2f,%.2f) to (%.2f,%.2f)\n',xmin,ymin,xmax,ymax)
%% Create an index to cut 
fprintf('Create domain index.\n')
for i = 1:length(idx_file)
    if and(idx_file(i,1)==0,idx_file(i,2)==0)
        idx(i) = i;
    end
    if and(idx_file(i,1)>xmin,idx_file(i,1)<xmax)
        if and(idx_file(i,2)>ymin,idx_file(i,2)<ymax)
        else
            idx(i) = i;
        end
    else
        idx(i) = i;
    end
end
idx(idx(:, 1)== 0, :)= [];

xvals = idx_file(:,1);
yvals = idx_file(:,2);
    % Delete values outside domain
xvals( idx, : ) = []; 
yvals( idx,:) = [];

pres = idx_file(:,6);
pres(idx,:) = [];

coords = [xvals yvals];

data = zeros(length(xvals),length(snapshots));
% coords(:,1) = xvals;
% coords(:,2) = yvals;
data(:,1) = pres;

clear xvals yvals pres idx_file

formatSpec = ['%*f %*f %*f %*f %*f %f'];
delim = ' ';

for i = 2:length(snapshots)
    % load the thing

    fid = fopen(snapshots{i},'r');
    testArray = textscan(fid, formatSpec,'Delimiter', delim, 'MultipleDelimsAsOne',1);
    fclose(fid);
    
    vector = testArray{1};
    vector(idx,:) = [];

    fprintf('%s \n',snapshots{i})
    
    data(:,i) = vector;

end
data = data.';


%% SPOD
%   Calculate the SPOD of the data matrix 'data' and use the timestep 'dt'
%   between snapshots to obtain the physical frequency 'f'. 'L' is the
%   matrix of modal energies, as before, and 'P' the data matrix of SPOD
%   modes.
VAR ='P';
dt = 0.01;                       % dt
nFFT = 600;                     % Size of the blocks
ovlp = round(nFFT*0.75);               % overlap
nblk = floor((tot_samps-ovlp)/(nFFT-ovlp));
opts.savefft    = true;          % Save FFT blocks instead of keeping them in memory (to save RAM)
modedir = "Nfft" + nFFT + "-ovlp" + olvp + "-blks"+nblk;
opts.savedir    = modedir;        % Save results to 'results' folder in the current directory

[L,P,f] = spod(data,nFFT,[],ovlp,dt,opts);
%% Plot some reference figures
figure
loglog(f,L)
xlabel('Frequency'), ylabel('SPOD mode energy')
txt = ['nFFT - ' num2str(nFFT) ', nblk - ' num2str(nblk)];
dim = [0.15 0.1 .3 .1];
annotation('textbox',dim,'String',txt,'EdgeColor','none')
saveas(gcf,modedir+'/loglogfL.png')

figure
semilogy(f,L)
xlabel('Frequency'), ylabel('SPOD mode energy')
saveas(gcf,modedir+'/semilogL.png')

l5 = L(:,1:5);
figure
semilogy(f,l5)
xlabel('Frequency'), ylabel('SPOD mode energy')
saveas(gcf,modedir+'/top5f.png')

l10 = L(:,1:10);
figure
semilogy(f,l10)
xlabel('Frequency'), ylabel('SPOD mode energy')
saveas(gcf,modedir+'/top10f.png')

figure
semilogy(f,l10)
xlabel('Frequency'), ylabel('SPOD mode energy')
xlim([25 inf]) 
saveas(gcf,modedir+'/highfreq.png')

%%
fprintf("Savings modes\n")
for fi = 1:10
    for mi = [1 2]
        
        A = single(real(squeeze(P(fi,mi))));
        writematrix([coords, A],modedir+"/SPOD_"+VAR+"_mode_n_"+mi+"_f_"+f(fi)+".txt");
        A = single(imag(squeeze(P(fi,mi))));
        writematrix([coords, A],modedir+"/SPOD_"+VAR+"_mode_n_"+mi+"_f_"+f(fi)+"_imag.txt");

    end
end

fprintf('SPOD done!')
