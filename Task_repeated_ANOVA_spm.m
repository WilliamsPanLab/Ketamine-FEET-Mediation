clear, clc, close all

%% Subjects
subjects_list = {'P50001', 'P50002', 'P50003', 'P50004', 'P50005', 'P50006', ...
    'P50007', 'P50008', 'P50009', 'P50010', 'P50011', 'P50012', 'P50013'};

%% folder
OverallDir = '/Users/xuezhang/Documents/Stanford/Projects/P50/Analysis';
fMRIDir = ['/Volumes/group/xuezhang/Projects/P50/fmriprep-20.2.3/models']%[OverallDir,'/fMRI'];
CSVDir = [OverallDir,'/CSV'];

which_proc = 'matlab'; %'matlab', 'r'

if strcmp(which_proc, 'matlab')
    Session_org = {1, 2, 3}; % fmri data
    Dosage_real = {'0.5mg/kg','0.05mg/kg','Placebo'};
    Dosage_real_foldername = {'HighK', 'LowK', 'Placebo'};
    
    Task = {'nonconscious';};
    Contrasts_nums_all = {[9, 18]};
    Contrasts_name_all = {{'HappyvsNeutral','ThreatvsNeutral'}};
    
else
    Session_org = {0, 1, 2, 3}; % fmri data
    Dosage_real = {'Baseline','0.5mg/kg','0.05mg/kg','Placebo'};
    Dosage_real_foldername = {'Baseline', 'HighK', 'LowK', 'Placebo'};
    Task = {'nonconscious';};
    Contrasts_nums_all = {[9, 18]};
    Contrasts_name_all = {{'HappyvsNeutral','ThreatvsNeutral'}};
end


OutDir = [OverallDir, '/SPM/Level2/Repeated_ANOVA_SPM'];
mkdir(OutDir);
PlotDir = [OverallDir, '/SPM/Figures_SPM'];
mkdir(PlotDir);

% create a mask that contains bilateral anterior insula and amygdala
mask_list = {
    '/Users/xuezhang/Documents/Stanford/Projects/P50/Analysis/ROIs/Neurosynth_anterior insula_association-test_z_5_L_mask.nii';...
    '/Users/xuezhang/Documents/Stanford/Projects/P50/Analysis/ROIs/Neurosynth_anterior insula_association-test_z_5_R_mask.nii';...
    '/Users/xuezhang/Documents/Stanford/Projects/IRIS/ROIs/plip/176064_Right_Amygdala_NegativeAffect.nii.gz';...
    '/Users/xuezhang/Documents/Stanford/Projects/IRIS/ROIs/plip/779062_Left_Amygdala_NegativeAffect.nii.gz';...
    };
mask_combined_name = '/Users/xuezhang/Documents/Stanford/Projects/P50/Analysis/ROIs/AnInsula_Amy.nii';
mask_combined = 0;
for i_mask = 1: length(mask_list)     
    [mask_i, ~, ~, Header] = y_ReadAll(mask_list{i_mask});
    mask_binary = zeros(size(mask_i));
    mask_binary(mask_i > 0) = 1; 
    mask_combined = mask_combined + mask_binary;
end
y_Write(mask_combined, Header, mask_combined_name);


% mask for analysis
MASK = [mask_combined_name];


%% load real dosage
Dosage = readtable([CSVDir, '/Dose_info_unblinded_07062021.xlsx']);
Dosage_ID = table2array(Dosage(:, 'ID'));
Dosage_ID_cell = cell([length(Dosage_ID), 1]);
for i_id = 1: length(Dosage_ID)
    if Dosage_ID(i_id) < 10
        Dosage_ID_cell{i_id} = ['P5000', num2str(Dosage_ID(i_id))];
    else
        Dosage_ID_cell{i_id} = ['P500', num2str(Dosage_ID(i_id))];
    end
end
Dosage.ID = Dosage_ID_cell;
        

%% Statistics
for i_task = 1: length(Task)
    % contrasts for each task
    Contrasts_nums = Contrasts_nums_all{i_task};
    Contrasts_name = Contrasts_name_all{i_task};
     
    for i_con = 1: length(Contrasts_nums)
       
        % identify usable subjects
        subjects_list_use = cell([0]);
        subjects_list_use_ind = cell([0]);
        Session_real = zeros(length(subjects_list), length(Dosage_real));
        for i_sub = 1: length(subjects_list)
            data_complete = 0;
            [~,sub_ind] = ismember(subjects_list{i_sub}, Dosage.ID);
            dosage_real_sub = table2cell(Dosage(sub_ind,(6-length(Dosage_real)):5));
            [~,session_real_sub] = ismember(Dosage_real(1:end), dosage_real_sub);
            Session_real(i_sub,:) = cell2mat(Session_org(session_real_sub));
            for i_ses = 1: length(session_real_sub)
                subj_folder = [fMRIDir,'/',subjects_list{i_sub},'/s',num2str(Session_real(i_sub, i_ses)),'/',Task{i_task},...
                    '/activation'];
                if Contrasts_nums(i_con) > 9

                    subj_dir = [subj_folder, '/con_00',num2str(Contrasts_nums(i_con)),'.hdr'];
                else
                    subj_dir = [subj_folder, '/con_000',num2str(Contrasts_nums(i_con)),'.hdr'];
                end
                if exist(subj_dir,'file')
                    data_complete = data_complete + 1;
                end
            end
            if data_complete == length(Dosage_real)
                subjects_list_use = [subjects_list_use, subjects_list{i_sub}];
                subjects_list_use_ind = [subjects_list_use_ind, i_sub];
            end  
        end
        % identify file for ANOVA
        DataDir = {};
        for i_ses = 1: length(Dosage_real)

            if Contrasts_nums(i_con) > 9
                ses_dir = cellfun(@(x)[fMRIDir,'/',subjects_list{x},'/s',num2str(Session_real(x, i_ses)), '/',...
                    Task{i_task},'/activation/con_00',num2str(Contrasts_nums(i_con)),'.img'], subjects_list_use_ind, 'UniformOutput', false);
            else
                ses_dir = cellfun(@(x)[fMRIDir,'/',subjects_list{x},'/s',num2str(Session_real(x, i_ses)), '/',...
                    Task{i_task},'/activation/con_000',num2str(Contrasts_nums(i_con)),'.img'], subjects_list_use_ind, 'UniformOutput', false);
            end
            DataDir = [DataDir, {ses_dir}];
            
            %% one sample t-test
            cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
            OutputName = [OutDir,'/', Task{i_task}, '/', Contrasts_name{i_con},'/onesample/', Dosage_real_foldername{i_ses}];
            mkdir(OutputName)
            onesamplettest(OutputName, ses_dir', cov, MASK, {0.05});
        end
        
        %% ANOVA
        OutputName = [OutDir,'/', Task{i_task}, '/', Contrasts_name{i_con}];
        mkdir(OutputName)
        cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        onewayrepeatedANOVA(OutputName, DataDir, cov, MASK, {0.05})
 
    end
end


%% generating z score and visulizing results
VoxelPThreshold = 0.001;
ClusterPThreshold = 0.05;
MaskFile2 = mask_combined_name;
for i_task = 1: length(Task)
    % contrasts for each task
    Contrasts_nums = Contrasts_nums_all{i_task};
    Contrasts_name = Contrasts_name_all{i_task};
    for i_con = 1:length(Contrasts_nums)
        %% ANOVA
        OutputName = [OutDir,'/', Task{i_task}, '/', Contrasts_name{i_con}];
        OutputName2 = [OutputName,'/spmF_0001_GRF.nii'];
        IsTwoTailed = 0;
        y_GRF_Threshold([OutputName,'/spmF_0001.nii'],VoxelPThreshold,IsTwoTailed,ClusterPThreshold,OutputName2,MaskFile2);
        %% one sample t-test
        IsTwoTailed = 1;
        for i_dos = 1: 3
            OutputName = [OutDir,'/', Task{i_task}, '/', Contrasts_name{i_con},'/onesample/', Dosage_real_foldername{i_dos}];
            OutputName2 = [OutputName,'/spmT_0001_GRF.nii'];
            y_GRF_Threshold([OutputName,'/spmT_0001.nii'],VoxelPThreshold,IsTwoTailed,ClusterPThreshold,OutputName2,MaskFile2);
            
            OutputName2 = [OutputName,'/spmT_0002_GRF.nii'];
            y_GRF_Threshold([OutputName,'/spmT_0002.nii'],VoxelPThreshold,IsTwoTailed,ClusterPThreshold,OutputName2,MaskFile2);
        end
        
    end
end


%% visualization
[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
PMin = 3;NMin = -1*PMin; 
NMax = -4; PMax = 4;
ClusterSize = 0;
ConnectivityCriterion = 18;
slice_interval = 6;
UnderlayFileName = [DPABIPath, filesep, 'Templates', filesep, 'ch2.nii'];
slices_all = {[-22:slice_interval:2;2:slice_interval:26];...
    [-22:slice_interval:2;2:slice_interval:26];...
    [-16:7:12;19:7:47];...
    [-22:slice_interval:2;2:slice_interval:26];};

slices_onesample_all = {[-22:slice_interval:2;2:slice_interval:26];...
    [-22:slice_interval:2;2:slice_interval:26];...
    [-16:7:12;19:7:47];...
    [-22:slice_interval:2;2:slice_interval:26];};
ColorMap = y_AFNI_ColorMap(12);%jet(128);%
for i_task = 1: length(Task)
    % contrasts for each task
    Contrasts_nums = Contrasts_nums_all{i_task};
    Contrasts_name = Contrasts_name_all{i_task};
    for i_con = 1: length(Contrasts_nums)
        % ANOVA
        OutputName = [OutDir,'/', Task{i_task}, '/', Contrasts_name{i_con}];
        PlotName = [PlotDir,'/', Task{i_task}, '/', Contrasts_name{i_con}];
        mkdir(PlotName)
        
        % pre-GRF corr
        ImageFile0 = [OutputName,'/Z_BeforeThreshold_spmF_0001_GRF.nii'];
        H0=w_Call_DPABI_VIEW(ImageFile0,-1000,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,-1000,PMax);
        [ImageA0,Space0]=w_MontageImage([-46:slice_interval:-22;-22:slice_interval:2;2:slice_interval:26;26:slice_interval:50;50:slice_interval:74],'T',H0);
        ImageA0=flipdim(ImageA0,1);
        imwrite(ImageA0,[PlotName,'/Z_BeforeThreshold_spmF_0001_GRF_thresh_',num2str(PMin),'.tif']);
        % post-GRF corr
        ImageFile0 = [OutputName,'/Z_ClusterThresholded_spmF_0001_GRF.nii'];
        H0=w_Call_DPABI_VIEW(ImageFile0,-1000,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,-1000,PMax);
        [ImageA0,Space0]=w_MontageImage([-46:slice_interval:-22;-22:slice_interval:2;2:slice_interval:26;26:slice_interval:50;50:slice_interval:74],'T',H0);
        ImageA0=flipdim(ImageA0,1);
        imwrite(ImageA0,[PlotName,'/Z_ClusterThresholded_spmF_0001_GRF_thresh_',num2str(PMin),'.tif']);
        
        %% one sample
        for i_dos = 1: 3
            OutputName = [OutDir,'/', Task{i_task}, '/', Contrasts_name{i_con},'/onesample/', Dosage_real_foldername{i_dos}];
            PlotName = [PlotDir,'/', Task{i_task}, '/', Contrasts_name{i_con},'/onesample/', Dosage_real_foldername{i_dos}];
            mkdir(PlotName)
            % pre-GRF correction
            ImageFile0 = [OutputName,'/Z_BeforeThreshold_spmT_0001_GRF.nii'];
            H0=w_Call_DPABI_VIEW(ImageFile0,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax);
            [ImageA0,Space0]=w_MontageImage([-46:slice_interval:-22;-22:slice_interval:2;2:slice_interval:26;26:slice_interval:50;50:slice_interval:74],'T',H0); % slices_onesample_all{i_task}
            ImageA0=flipdim(ImageA0,1);
            imwrite(ImageA0,[PlotName,'/Z_BeforeThreshold_spmT_0001_GRF_thresh_',num2str(PMin),'.tif']);
            
            % post-GRF correction
            ImageFile0 = [OutputName,'/Z_ClusterThresholded_spmT_0001_GRF.nii'];
            H0=w_Call_DPABI_VIEW(ImageFile0,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax);
            [ImageA0,Space0]=w_MontageImage([-46:slice_interval:-22;-22:slice_interval:2;2:slice_interval:26;26:slice_interval:50;50:slice_interval:74],'T',H0);
            ImageA0=flipdim(ImageA0,1);
            imwrite(ImageA0,[PlotName,'/Z_ClusterThresholded_spmT_0001_GRF_thresh_',num2str(PMin),'.tif']);
            
            
            % pre-GRF correction
            ImageFile0 = [OutputName,'/Z_BeforeThreshold_spmT_0002_GRF.nii'];
            H0=w_Call_DPABI_VIEW(ImageFile0,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax);
            [ImageA0,Space0]=w_MontageImage([-46:slice_interval:-22;-22:slice_interval:2;2:slice_interval:26;26:slice_interval:50;50:slice_interval:74],'T',H0); % slices_onesample_all{i_task}
            ImageA0=flipdim(ImageA0,1);
            imwrite(ImageA0,[PlotName,'/Z_BeforeThreshold_spmT_0002_GRF_thresh_',num2str(PMin),'.tif']);
            
            % post-GRF correction
            ImageFile0 = [OutputName,'/Z_ClusterThresholded_spmT_0002_GRF.nii'];
            H0=w_Call_DPABI_VIEW(ImageFile0,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax);
            [ImageA0,Space0]=w_MontageImage([-46:slice_interval:-22;-22:slice_interval:2;2:slice_interval:26;26:slice_interval:50;50:slice_interval:74],'T',H0);
            ImageA0=flipdim(ImageA0,1);
            imwrite(ImageA0,[PlotName,'/Z_ClusterThresholded_spmT_0002_GRF_thresh_',num2str(PMin),'.tif']);
        end
        close all
    end
end



