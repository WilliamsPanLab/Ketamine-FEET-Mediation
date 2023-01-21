clear, clc, close all
DATADIR = '/Users/xuezhang/Desktop/oak/users/xuezhang/P50/KET/data/derivatives/fmriprep-20.2.3/fmriprep';
subjects_list = {'P50001', 'P50002', 'P50003', 'P50004', 'P50005', 'P50006', ...
    'P50007', 'P50008', 'P50009', 'P50010', 'P50011', 'P50012', 'P50013'};
sessions = {'00', '01', '02', '03'};
Task = {'nonconscious';};
Nscan = {149.0};

%% load real dosage
CSVDir = '/Users/xuezhang/Documents/Stanford/Projects/P50/Analysis/CSV';
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



%% define table variables 
col_name = {'Subjects','Session', 'Dosage','Task','SpikesPercent','MeanFD'};
sz = [1 6];
varTypes = ["string","int8","string","string",'double','double'];
motion_summary = table('Size',sz,'VariableTypes',varTypes,'VariableNames',col_name);

irow = 0;
for isub = 1: length(subjects_list)
    subjects_list{isub}
    for ses = 1: length(sessions)
        [~,sub_ind] = ismember(subjects_list{isub}, Dosage.ID);
        dosage_real_session = table2cell(Dosage(sub_ind,str2num(sessions{ses})+2));
        for itask = 1: length(Task)
            % regressor
            reg = dir([DATADIR,'/sub-',subjects_list{isub},'/ses-',sessions{ses},'/func/sub-', subjects_list{isub},...
                '_ses-',sessions{ses},'_task-',Task{itask},...
                '*_desc-confounds_timeseries.tsv']);
            if (ses > 0) && (length(reg) > 1)
                disp(['more than 1 runs found for ', subjects_list{isub}, ' session ', sessions{ses}, ' task ', Task{itask}]);
                continue
            else length(reg) == 0
                disp(['no run found for ', subjects_list{isub}, ' session ', sessions{ses}, ' task ', Task{itask}]);
                continue
            end
                
            reg_file = fullfile(reg.folder, reg.name);
            reg = tdfread(reg_file);
            reg_names = fieldnames(reg);
            % fd
            fd_mean = nanmean(str2double(cellstr(reg.framewise_displacement(2:end,:))));
            % spikes
            spikes = length(find(contains(reg_names,'motion_outlier')));
            spike_percent = spikes/Nscan{itask};
            irow = irow + 1;
            motion_summary(irow, :) = {subjects_list{isub}, str2num(sessions{ses}), dosage_real_session{1}, Task{itask}, spike_percent, fd_mean};
        end
    end
end
 
delete([CSVDir,'/KET_spikes_summary.csv'])
writetable(motion_summary,[CSVDir,'/KET_spikes_summary.csv']);   


% statistics and visualization of motion parameters
motion_summary = readtable([CSVDir,'/KET_spikes_summary.csv']);
figure, 
for itask = 1: length(Task)
    
    motion_summary_task = motion_summary(ismember(motion_summary.Task, Task{itask}),:);
    motion_summary_task = motion_summary_task(~ismember(motion_summary_task.Dosage, 'baseline'), :);
%     motion_summary_task.SpikesPercent(motion_summary_task.SpikesPercent>0.25) = NaN;
    motion_summary_task_wide = unstack(motion_summary_task(:,[1,3:5]), 'SpikesPercent', 'Dosage');
    motion_matrix_task = table2array(motion_summary_task_wide(:,3:5));
    % motion comparison between conditions
    model_equations = "SpikesPercent ~ Dosage + (1|Subjects)";
    motion_mixmodel = fitlme(motion_summary_task, model_equations,...
        'DummyVarCoding','effects','StartMethod','random');
    ss_imodel = anova(motion_mixmodel)
    
    % high dose vs. low dose
    [h, p1] = ttest(motion_matrix_task(:,1), motion_matrix_task(:, 2));
    
    % high dose vs placebo
    [h, p2] = ttest(motion_matrix_task(:,1), motion_matrix_task(:, 3));
    
    % low dose vs placebo
    [h, p3] = ttest(motion_matrix_task(:,2), motion_matrix_task(:, 3));
    
    comparison_label = {[1, 2], [1, 3], [2,3]}
    
    % visualization
    
    subplot(2,2, itask),boxplot(motion_matrix_task, 'Labels', {'0.5mg/kg', '0.05mg/kg', 'placebo'}),  %, 'baseline'
    sigstar(comparison_label, [p1, p2, p3]);
    xlabel('visits'), ylabel('motion spike percentage (%)');
    hold on;
    x=repmat(1:size(motion_matrix_task, 2),size(motion_matrix_task, 1),1);
    scatter(x(:),motion_matrix_task(:),'filled','MarkerFaceAlpha',0.6','jitter','on','jitterAmount',0.15);
    title([Task{itask}, ' motion percentage'])
    hold off
    
    % meanFD vs. percentage spikes
    [r,p] = corrcoef(motion_summary_task.SpikesPercent, motion_summary_task.MeanFD, 'Rows','pairwise');
end