function files = D_NORMA_script(files, template)
  global JOB_DIR
  files = cellstr(files);
  [pth,~,~] = fileparts(files{1});
  cur_dir = pwd()

  cd(pth)

  nrun = 1; % enter the number of runs here
  jobfile = fullfile(JOB_DIR, 'NORMA_script_job.m');
  jobs = repmat(jobfile, 1, nrun);
  inputs = cell(3, nrun);

  for crun = 1:nrun
    inputs{1, crun} = files; % Old Normalise: Estimate & Write: Source Image - cfg_files
    inputs{2, crun} = files; % Old Normalise: Estimate & Write: Images to Write - cfg_files
    inputs{3, crun} = cellstr(template); % Old Normalise: Estimate & Write: Template Image - cfg_files
  end
  spm('defaults', 'PET');
  spm_jobman('run', jobs, inputs{:});

  for iFile = 1:size(files,1)
    [path, basename, ext] = fileparts(files{iFile});
    % Need to be carefull if prefix 'sw' is not garanteed
    files{iFile} = fullfile(path, ['sw' basename, ext]);
    if ~exist(files{iFile}, 'file')
      error('expected normalized file %s not found. Probably wrong prefix', ...
            files{iFile});
    end
  end

  cd(cur_dir)

end
