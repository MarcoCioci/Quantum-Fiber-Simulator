function results_experiment_2 = run_experiment_2_random_phase(experiment_2_cases, do_plot)
% RUN_EXPERIMENT_2_RANDOM_PHASE  Sweep Bell-state degradation under random-phase ensembles.
%
% Objective:
%   Run Experiment 2 by generating one or more random-phase ensemble cases,
%   building the corresponding ensemble-averaged two-qubit states, and
%   computing the associated state metrics and correlation observables.
%
%   For each case, the experiment constructs
%
%       rho_ensemble = (1/N) sum_k |psi(theta_k)><psi(theta_k)|
%
%   where the phases theta_k are sampled from a prescribed distribution and
%   |psi(theta)> is the phase-evolved Bell-like state derived from |Psi+>.
%
% Input:
%   experiment_2_cases - optional cell array of case structures.
%                        Each case must contain:
%                           .distribution_type
%                           .num_samples
%                           .parameters
%                           .label
%
%                        If omitted or empty, default cases are used.
%
%   do_plot            - optional logical scalar controlling automatic
%                        plotting (default = true).
%
% Output:
%   results_experiment_2 - structure containing:
%
%       .experiment_name       - descriptive experiment name
%       .reference_state_label - Bell-state label used as input
%       .model_description     - model identifier
%       .num_cases             - number of ensemble cases
%       .cases                 - 1 x N cell array, one result structure per case
%
% Notes:
%   This runner acts at experiment level and reuses the existing Core
%   routines for density-matrix manipulation, partial traces, purity,
%   fidelity, concurrence, and correlation evaluation.
%
%   In the reduced random-phase model, the coherence parameter is
%
%       mu = <exp(i theta)>,
%
%   and the corresponding analytical concurrence is
%
%       C = |mu|.

    % =========================
    % Default input handling
    % =========================

    if nargin == 0
        experiment_2_cases = {
            struct( ...
                'distribution_type', 'constant', ...
                'num_samples', 100, ...
                'parameters', {{pi/4}}, ...
                'label', 'constant: theta = pi/4' ...
            ), ...
            struct( ...
                'distribution_type', 'uniform', ...
                'num_samples', 100, ...
                'parameters', {{0, 2*pi}}, ...
                'label', 'uniform: [0, 2*pi]' ...
            ), ...
            struct( ...
                'distribution_type', 'gaussian', ...
                'num_samples', 100, ...
                'parameters', {{0, 1}}, ...
                'label', 'gaussian: mu = 0, sigma = 1' ...
            )
        };
        do_plot = true;

    elseif nargin == 1
        if islogical(experiment_2_cases) && isscalar(experiment_2_cases)
            do_plot = experiment_2_cases;

            experiment_2_cases = {
                struct( ...
                    'distribution_type', 'constant', ...
                    'num_samples', 100, ...
                    'parameters', {{pi/4}}, ...
                    'label', 'constant: theta = pi/4' ...
                ), ...
                struct( ...
                    'distribution_type', 'uniform', ...
                    'num_samples', 100, ...
                    'parameters', {{0, 2*pi}}, ...
                    'label', 'uniform: [0, 2*pi]' ...
                ), ...
                struct( ...
                    'distribution_type', 'gaussian', ...
                    'num_samples', 100, ...
                    'parameters', {{0, 1}}, ...
                    'label', 'gaussian: mu = 0, sigma = 1' ...
                )
            };
        elseif isempty(experiment_2_cases)
            experiment_2_cases = {
                struct( ...
                    'distribution_type', 'constant', ...
                    'num_samples', 100, ...
                    'parameters', {{pi/4}}, ...
                    'label', 'constant: theta = pi/4' ...
                ), ...
                struct( ...
                    'distribution_type', 'uniform', ...
                    'num_samples', 100, ...
                    'parameters', {{0, 2*pi}}, ...
                    'label', 'uniform: [0, 2*pi]' ...
                ), ...
                struct( ...
                    'distribution_type', 'gaussian', ...
                    'num_samples', 100, ...
                    'parameters', {{0, 1}}, ...
                    'label', 'gaussian: mu = 0, sigma = 1' ...
                )
            };
            do_plot = true;
        else
            do_plot = true;
        end

    elseif nargin == 2
        if isempty(experiment_2_cases)
            experiment_2_cases = {
                struct( ...
                    'distribution_type', 'constant', ...
                    'num_samples', 100, ...
                    'parameters', {{pi/4}}, ...
                    'label', 'constant: theta = pi/4' ...
                ), ...
                struct( ...
                    'distribution_type', 'uniform', ...
                    'num_samples', 100, ...
                    'parameters', {{0, 2*pi}}, ...
                    'label', 'uniform: [0, 2*pi]' ...
                ), ...
                struct( ...
                    'distribution_type', 'gaussian', ...
                    'num_samples', 100, ...
                    'parameters', {{0, 1}}, ...
                    'label', 'gaussian: mu = 0, sigma = 1' ...
                )
            };
        end
    else
        error('run_experiment_2_random_phase:InvalidNumInputs', ...
              'Expected zero, one, or two input arguments: experiment_2_cases, do_plot.');
    end

    % =========================
    % Robustness checks
    % =========================

    if ~iscell(experiment_2_cases)
        error('run_experiment_2_random_phase:InvalidCasesType', ...
              'experiment_2_cases must be a cell array.');
    end

    if isempty(experiment_2_cases)
        error('run_experiment_2_random_phase:EmptyCases', ...
              'experiment_2_cases must not be empty.');
    end

    if ~islogical(do_plot) || ~isscalar(do_plot)
        error('run_experiment_2_random_phase:InvalidPlotFlag', ...
              'do_plot must be a logical scalar.');
    end


    % =========================
    % Main computation
    % =========================

    psi_plus = bell_state('psi_plus');
    num_cases = numel(experiment_2_cases);

    results_experiment_2.experiment_name = 'Experiment 2 - Random Phase Ensemble';
    results_experiment_2.reference_state_label = 'psi_plus';
    results_experiment_2.model_description = 'ensemble_averaged_random_phase';
    results_experiment_2.num_cases = num_cases;
    results_experiment_2.cases = cell(1, num_cases);

    for case_idx = 1:num_cases

        current_case = experiment_2_cases{case_idx};

        if ~isstruct(current_case)
            error('run_experiment_2_random_phase:InvalidCaseType', ...
                  'Each entry of experiment_2_cases must be a structure.');
        end

        required_fields = {'distribution_type', 'num_samples', 'parameters', 'label'};

        for field_idx = 1:numel(required_fields)
            if ~isfield(current_case, required_fields{field_idx})
                error('run_experiment_2_random_phase:MissingCaseField', ...
                      'Each case must contain the field ''%s''.', required_fields{field_idx});
            end
        end

        if ~ischar(current_case.distribution_type) && ...
                ~(isstring(current_case.distribution_type) && isscalar(current_case.distribution_type))
            error('run_experiment_2_random_phase:InvalidDistributionType', ...
                  'distribution_type must be a character vector or scalar string.');
        end

        if ~isnumeric(current_case.num_samples) || ~isscalar(current_case.num_samples) || ...
                current_case.num_samples <= 0 || mod(current_case.num_samples, 1) ~= 0
            error('run_experiment_2_random_phase:InvalidNumSamples', ...
                  'num_samples must be a positive integer scalar.');
        end

        if ~iscell(current_case.parameters)
            error('run_experiment_2_random_phase:InvalidParametersType', ...
                  'parameters must be a cell array.');
        end

        if ~ischar(current_case.label) && ...
                ~(isstring(current_case.label) && isscalar(current_case.label))
            error('run_experiment_2_random_phase:InvalidCaseLabel', ...
                  'label must be a character vector or scalar string.');
        end

        distribution_type = char(current_case.distribution_type);
        case_label = char(current_case.label);

        fprintf('\n');
        fprintf('==========================================\n');
        fprintf('Experiment 2 - Case %d\n', case_idx);
        fprintf('Distribution: %s\n', case_label);
        fprintf('Monitoring summary\n');
        fprintf('==========================================\n');

        theta_samples = generate_theta_samples( ...
            distribution_type, ...
            current_case.num_samples, ...
            current_case.parameters{:});

        if ~isnumeric(theta_samples) || ~isvector(theta_samples)
            error('run_experiment_2_random_phase:InvalidGeneratedSamples', ...
                  'generate_theta_samples must return a numeric vector.');
        end

        if isempty(theta_samples)
            error('run_experiment_2_random_phase:EmptyGeneratedSamples', ...
                  'Generated theta_samples must not be empty.');
        end

        if ~isreal(theta_samples)
            error('run_experiment_2_random_phase:ComplexGeneratedSamples', ...
                  'Generated theta_samples must be real-valued.');
        end

        if any(~isfinite(theta_samples))
            error('run_experiment_2_random_phase:NonFiniteGeneratedSamples', ...
                  'Generated theta_samples must contain only finite values.');
        end

        theta_samples = theta_samples(:).';


        % =========================
        % Ensemble state generation
        % =========================

        rho_ensemble = random_phase_ensemble_state(theta_samples);


        % =========================
        % Reduced states
        % =========================

        rho_A = partial_trace_B(rho_ensemble);
        rho_B = partial_trace_A(rho_ensemble);


        % =========================
        % Correlations and metrics
        % =========================

        correlations = compute_correlations(rho_ensemble);

        purity_global = compute_purity(rho_ensemble);
        purity_A = compute_purity(rho_A);
        purity_B = compute_purity(rho_B);
        fidelity_psi_plus = compute_fidelity(rho_ensemble, psi_plus);
        concurrence = compute_concurrence(rho_ensemble);

        sample_mean_cos_theta = mean(cos(theta_samples));
        sample_mean_sin_theta = mean(sin(theta_samples));
        sample_mean_exp_i_theta = mean(exp(1i * theta_samples));

        theory_c_xx = sample_mean_cos_theta;
        theory_c_yy = sample_mean_cos_theta;
        theory_c_zz = -1;

        theory_purity_global = ...
            (1 + sample_mean_cos_theta^2 + sample_mean_sin_theta^2) / 2;
        theory_purity_A = 1/2;
        theory_purity_B = 1/2;
        theory_fidelity_psi_plus = (1 + sample_mean_cos_theta) / 2;
        theory_concurrence = abs(sample_mean_exp_i_theta);

        fprintf('  theta stats   : N = %d, mean(theta) = %.6f, std(theta) = %.6f\n', ...
            numel(theta_samples), mean(theta_samples), std(theta_samples));
        fprintf('  c_xx          : num = %+.6f, theory = %+.6f, |err| = %.3e\n', ...
            real(correlations.c_xx), theory_c_xx, ...
            abs(real(correlations.c_xx) - theory_c_xx));
        fprintf('  c_yy          : num = %+.6f, theory = %+.6f, |err| = %.3e\n', ...
            real(correlations.c_yy), theory_c_yy, ...
            abs(real(correlations.c_yy) - theory_c_yy));
        fprintf('  c_zz          : num = %+.6f, theory = %+.6f, |err| = %.3e\n', ...
            real(correlations.c_zz), theory_c_zz, ...
            abs(real(correlations.c_zz) - theory_c_zz));
        fprintf('  purity_global : num = %.6f, theory = %.6f, |err| = %.3e\n', ...
            purity_global, theory_purity_global, ...
            abs(purity_global - theory_purity_global));
        fprintf('  purity_A      : num = %.6f, theory = %.6f, |err| = %.3e\n', ...
            purity_A, theory_purity_A, ...
            abs(purity_A - theory_purity_A));
        fprintf('  purity_B      : num = %.6f, theory = %.6f, |err| = %.3e\n', ...
            purity_B, theory_purity_B, ...
            abs(purity_B - theory_purity_B));
        fprintf('  fidelity_Psi+ : num = %.6f, theory = %.6f, |err| = %.3e\n', ...
            fidelity_psi_plus, theory_fidelity_psi_plus, ...
            abs(fidelity_psi_plus - theory_fidelity_psi_plus));
        fprintf('  concurrence   : num = %.6f, theory = %.6f, |err| = %.3e\n', ...
            concurrence, theory_concurrence, ...
            abs(concurrence - theory_concurrence));


        % =========================
        % Assemble case output structure
        % =========================

        results_current = struct();

        results_current.case_index = case_idx;
        results_current.case_label = case_label;
        results_current.distribution_type = distribution_type;
        results_current.distribution_parameters = current_case.parameters;

        results_current.theta_samples = theta_samples;
        results_current.num_samples = numel(theta_samples);

        results_current.rho = rho_ensemble;
        results_current.rho_A = rho_A;
        results_current.rho_B = rho_B;

        results_current.purity_global = purity_global;
        results_current.purity_A = purity_A;
        results_current.purity_B = purity_B;
        results_current.fidelity_psi_plus = fidelity_psi_plus;
        results_current.concurrence = concurrence;

        results_current.c_xx = real(correlations.c_xx);
        results_current.c_yy = real(correlations.c_yy);
        results_current.c_zz = real(correlations.c_zz);
        results_current.correlations = correlations;

        results_current.sample_mean_cos_theta = sample_mean_cos_theta;
        results_current.sample_mean_sin_theta = sample_mean_sin_theta;
        results_current.sample_mean_exp_i_theta = sample_mean_exp_i_theta;

        results_current.analytical.purity_global = theory_purity_global;
        results_current.analytical.purity_A = theory_purity_A;
        results_current.analytical.purity_B = theory_purity_B;
        results_current.analytical.fidelity_psi_plus = theory_fidelity_psi_plus;
        results_current.analytical.concurrence = theory_concurrence;
        results_current.analytical.c_xx = theory_c_xx;
        results_current.analytical.c_yy = theory_c_yy;
        results_current.analytical.c_zz = theory_c_zz;

        results_experiment_2.cases{case_idx} = results_current;


        % =========================
        % Optional plotting
        % =========================

        if do_plot
            plot_random_phase_summary(results_current);
        end
    end

end