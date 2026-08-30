function results_experiment_2 = run_experiment_2_random_phase(experiment_2_cases, do_summary_plot, do_tensor_plot, do_save)
% RUN_EXPERIMENT_2_RANDOM_PHASE  Sweep Bell-state degradation under random-phase ensembles.
%
% Objective:
%   Run Experiment 2 by generating one or more random-phase ensemble cases,
%   building the corresponding ensemble-averaged two-qubit states, and
%   computing the associated state metrics, diagonal correlations, and
%   full correlation tensor.
%
% Input:
%   experiment_2_cases - optional cell array of case structures
%   do_summary_plot    - logical flag for standard plots (default = true)
%   do_tensor_plot     - logical flag for tensor plots (default = false)
%   do_save            - logical flag controlling figure export (default = false)
%
% Output:
%   results_experiment_2 - structure containing all results

    % =========================
    % Default input handling
    % =========================

    fprintf('\n\n==========================================\n');
    fprintf('Experiment 2 - Monitoring summary\n');
    fprintf('==========================================\n');

    num_samples = 100;

    if nargin < 1 || isempty(experiment_2_cases)
        experiment_2_cases = {
            struct('distribution_type','constant','num_samples',num_samples,'parameters',{{pi/4}}, ...
                'label','constant | θ = π/4'); ...

            struct('distribution_type','uniform','num_samples',num_samples,'parameters',{{0,2*pi}}, ...
                'label','uniform | θ ∈ [0, 2π]'); ...

            struct('distribution_type','gaussian','num_samples',num_samples,'parameters',{{0,1}}, ...
                'label','gaussian | θ ~ N(0,1)')
        };
    end

    if nargin < 2 || isempty(do_summary_plot)
        do_summary_plot = true;
    end

    if nargin < 3 || isempty(do_tensor_plot)
        do_tensor_plot = false;
    end

    if nargin < 4 || isempty(do_save)
        do_save = false;
    end


    % =========================
    % Robustness checks
    % =========================

    if ~iscell(experiment_2_cases)
        error('run_experiment_2_random_phase:InvalidCasesType', ...
              'experiment_2_cases must be a cell array.');
    end

    if ~islogical(do_summary_plot) || ~isscalar(do_summary_plot)
        error('run_experiment_2_random_phase:InvalidPlotFlag', ...
              'do_summary_plot must be a logical scalar.');
    end

    if ~islogical(do_tensor_plot) || ~isscalar(do_tensor_plot)
        error('run_experiment_2_random_phase:InvalidTensorPlotFlag', ...
              'do_tensor_plot must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('run_experiment_2_random_phase:InvalidSaveFlag', ...
              'do_save must be a logical scalar.');
    end


    % =========================
    % Initialization
    % =========================

    psi_plus = bell_state('psi_plus');
    num_cases = numel(experiment_2_cases);

    results_experiment_2.experiment_name = 'Experiment 2 - Random Phase Ensemble';
    results_experiment_2.reference_state_label = 'psi_plus';
    results_experiment_2.model_description = 'ensemble_averaged_random_phase';
    results_experiment_2.num_cases = num_cases;
    results_experiment_2.cases = cell(1, num_cases);


    % =========================
    % Main loop
    % =========================

    for case_idx = 1:num_cases

        current_case = experiment_2_cases{case_idx};

        required_case_fields = { ...
            'distribution_type', ...
            'num_samples', ...
            'parameters', ...
            'label' ...
        };

        check_required_fields(current_case, required_case_fields, ...
            'run_experiment_2_random_phase:MissingCaseField');

        distribution_type = char(current_case.distribution_type);
        case_label = char(current_case.label);

        fprintf('\n==========================================\n');
        fprintf('Distribution: %s\n', case_label);
        fprintf('==========================================\n');

        % =========================
        % Sampling
        % =========================

        theta_samples = generate_theta_samples( ...
            distribution_type, ...
            current_case.num_samples, ...
            current_case.parameters{:});

        theta_samples = theta_samples(:).';


        % =========================
        % Ensemble state
        % =========================

        rho_ensemble = random_phase_ensemble_state(theta_samples);

        rho_A = partial_trace_B(rho_ensemble);
        rho_B = partial_trace_A(rho_ensemble);


        % =========================
        % Observables
        % =========================

        correlation_tensor = compute_correlation_tensor(rho_ensemble);
        correlations = compute_correlations(rho_ensemble);

        purity_global = compute_purity(rho_ensemble);
        purity_A = compute_purity(rho_A);
        purity_B = compute_purity(rho_B);
        fidelity_psi_plus = compute_fidelity(rho_ensemble, psi_plus);
        concurrence = compute_concurrence(rho_ensemble);


        % =========================
        % Analytical quantities
        % =========================

        analytics = analytical_values_experiment_2(theta_samples);

        analytical_tensor = analytics.T;

        analytical_c_xx = analytics.c_xx;
        analytical_c_yy = analytics.c_yy;
        analytical_c_zz = analytics.c_zz;

        analytical_purity_global = analytics.gamma_AB;
        analytical_purity_A = analytics.gamma_A;
        analytical_purity_B = analytics.gamma_B;

        analytical_fidelity = analytics.F_psi_plus;
        analytical_concurrence = analytics.C;


        % =========================
        % Console monitoring
        % =========================

        fprintf('num_samples            : %d\n',   numel(theta_samples)); 
        fprintf('|mu|                   : %.6f\n', analytics.mu_abs);
        fprintf('c_xx |err|             : %.3e\n', abs(correlations.c_xx - analytical_c_xx));
        fprintf('c_yy |err|             : %.3e\n', abs(correlations.c_yy - analytical_c_yy));
        fprintf('c_zz |err|             : %.3e\n', abs(correlations.c_zz - analytical_c_zz));
        fprintf('T tensor ||err||_F     : %.3e\n', norm(correlation_tensor - analytical_tensor, 'fro'));
        fprintf('gamma_AB |err|         : %.3e\n', abs(purity_global - analytical_purity_global));
        fprintf('gamma_A |err|          : %.3e\n', abs(purity_A - analytical_purity_A));
        fprintf('gamma_B |err|          : %.3e\n', abs(purity_B - analytical_purity_B));
        fprintf('F_psi+ |err|           : %.3e\n', abs(fidelity_psi_plus - analytical_fidelity));
        fprintf('C |err|                : %.3e\n', abs(concurrence - analytical_concurrence));


        % =========================
        % Store results
        % =========================

        results_current = struct();

        results_current.case_label = case_label;
        results_current.distribution_type = distribution_type;
        results_current.theta_samples = theta_samples;

        results_current.rho = rho_ensemble;
        results_current.rho_A = rho_A;
        results_current.rho_B = rho_B;

        results_current.c_xx = correlations.c_xx;
        results_current.c_yy = correlations.c_yy;
        results_current.c_zz = correlations.c_zz;

        results_current.correlation_tensor = correlation_tensor;

        results_current.purity_global = purity_global;
        results_current.purity_A = purity_A;
        results_current.purity_B = purity_B;
        results_current.fidelity_psi_plus = fidelity_psi_plus;
        results_current.concurrence = concurrence;

        results_current.sample_mean_cos_theta = analytics.mu_real;
        results_current.sample_mean_sin_theta = analytics.mu_imag;
        results_current.sample_mean_exp_i_theta = analytics.mu;
        results_current.sample_abs_exp_i_theta = analytics.mu_abs;

        results_current.analytical = analytics;

        results_current.analytical.correlation_tensor = analytics.T;
        results_current.analytical.purity_global = analytics.gamma_AB;
        results_current.analytical.purity_A = analytics.gamma_A;
        results_current.analytical.purity_B = analytics.gamma_B;
        results_current.analytical.fidelity_psi_plus = analytics.F_psi_plus;
        results_current.analytical.concurrence = analytics.C;
        
        results_experiment_2.cases{case_idx} = results_current;


        % =========================
        % Plotting
        % =========================

        if do_summary_plot
            plot_random_phase_summary(results_current, do_save);
        end

        if do_tensor_plot
            plot_correlation_tensor_snapshot(results_current, do_save);
        end

    end
end
