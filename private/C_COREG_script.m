% List of open inputs
% Coregister: Estimate: Reference Image - cfg_files
% Coregister: Estimate: Source Image - cfg_files

function C_COREG_script(files, template)
  %declaring useful variables
  global JOB_DIR

  files = cellstr(files);

  nrun = 1; % enter the number of runs here
  jobfile = fullfile(JOB_DIR, 'COREG_job.m');
  jobs = repmat(jobfile, 1, nrun);
  inputs = cell(2, nrun);

  for crun = 1:nrun
      inputs{1, crun} = cellstr(template); % Coregister: Estimate: Reference Image - cfg_files
      inputs{2, crun} = files; % Coregister: Estimate: Source Image - cfg_files
  end
  spm('defaults', 'PET');
  spm_jobman('run', jobs, inputs{:});

  spm_check_registration(template, files{1});
  [path, ~, ~] = fileparts(files{1});
  saveas(gcf,fullfile(path, 'SET_ORIGIN_COREG.png'),'bmp');
end
