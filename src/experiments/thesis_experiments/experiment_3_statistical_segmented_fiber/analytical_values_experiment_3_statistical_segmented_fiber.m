function analytics = analytical_values_experiment_3_statistical_segmented_fiber( ...
        num_segments_values, segment_dgd, sigma_omega)
% ANALYTICAL_VALUES_EXPERIMENT_3_STATISTICAL_SEGMENTED_FIBER
% Return controlled analytical benchmarks for Experiment 3.
%
% Objective:
%   Construct the analytical and statistical reference quantities available
%   for an isotropic segmented PMD fiber whose segments have identical DGD.
%
%   For N statistically independent isotropic PMD-vector contributions of
%   magnitude delta_tau_seg,
%
%       <tau_vector> -> 0,
%
%   while
%
%       sqrt(<||tau_vector||^2>)
%       =
%       delta_tau_seg * sqrt(N).
%
%   Isotropy additionally gives, for each Cartesian component,
%
%       sqrt(<tau_x^2>)
%       =
%       sqrt(<tau_y^2>)
%       =
%       sqrt(<tau_z^2>)
%       =
%       delta_tau_seg * sqrt(N / 3).
%
%   The N = 1 case is also analytically controlled. For a Gaussian marginal
%   spectrum with standard deviation sigma_omega,
%
%       g = exp[-(sigma_omega * delta_tau_seg)^2 / 2].
%
% Input:
%   num_segments_values - Positive integer vector containing segment counts.
%
%   segment_dgd         - Positive DGD of every segment [s].
%
%   sigma_omega         - Positive marginal angular-frequency standard
%                         deviation [rad/s].
%
% Output:
%   analytics - Structure containing:
%
%       .num_segments_values
%       .rms_total_dgd
%       .rms_component_dgd
%       .rms_normalized_pmd_strength
%       .single_segment
%
% Notes:
%   The random-walk expressions are statistical predictions for the
%   first-order PMD vector.
%
%   They are not an exact closed-form prediction for the complete
%   spectrally averaged quantum state of a general noncommuting segmented
%   fiber. Higher-order frequency dependence remains in the numerical model.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error( ...
            ['analytical_values_experiment_3_', ...
             'statistical_segmented_fiber:InvalidNumInputs'], ...
            ['Expected exactly 3 input arguments: num_segments_values, ', ...
             'segment_dgd, sigma_omega.']);
    end

    if ~isnumeric(num_segments_values) || ...
            ~isreal(num_segments_values) || ...
            ~isvector(num_segments_values) || ...
            isempty(num_segments_values)
        error( ...
            ['analytical_values_experiment_3_', ...
             'statistical_segmented_fiber:InvalidSegmentCounts'], ...
            'num_segments_values must be a non-empty real numeric vector.');
    end

    if any(~isfinite(num_segments_values), 'all') || ...
            any(num_segments_values < 1, 'all') || ...
            any(num_segments_values ~= floor(num_segments_values), 'all')
        error( ...
            ['analytical_values_experiment_3_', ...
             'statistical_segmented_fiber:InvalidSegmentCounts'], ...
            'num_segments_values must contain positive finite integers.');
    end

    if ~isnumeric(segment_dgd) || ...
            ~isscalar(segment_dgd) || ...
            ~isreal(segment_dgd) || ...
            ~isfinite(segment_dgd) || ...
            segment_dgd <= 0
        error( ...
            ['analytical_values_experiment_3_', ...
             'statistical_segmented_fiber:InvalidSegmentDGD'], ...
            'segment_dgd must be a positive finite real scalar.');
    end

    if ~isnumeric(sigma_omega) || ...
            ~isscalar(sigma_omega) || ...
            ~isreal(sigma_omega) || ...
            ~isfinite(sigma_omega) || ...
            sigma_omega <= 0
        error( ...
            ['analytical_values_experiment_3_', ...
             'statistical_segmented_fiber:InvalidSigmaOmega'], ...
            'sigma_omega must be a positive finite real scalar.');
    end


    % =========================
    % Input normalization
    % =========================

    num_segments_values = num_segments_values(:).';


    % =========================
    % Random-walk PMD statistics
    % =========================

    rms_total_dgd = ...
        segment_dgd * sqrt(num_segments_values);

    rms_component_dgd = ...
        segment_dgd * sqrt(num_segments_values / 3);

    rms_normalized_pmd_strength = ...
        sigma_omega * rms_total_dgd;


    % =========================
    % Single-segment benchmark
    % =========================

    xi_single = sigma_omega * segment_dgd;

    coherence_single = ...
        exp(-0.5 * xi_single^2);

    purity_single = ...
        0.5 * (1 + coherence_single^2);

    fidelity_single = ...
        0.5 * (1 + coherence_single);

    concurrence_single = coherence_single;

    tangle_single = concurrence_single^2;

    chsh_max_single = ...
        2 * sqrt(1 + coherence_single^2);

    if concurrence_single <= 0
        eof_single = 0;
    else
        argument = ...
            (1 + sqrt(max(0, 1 - concurrence_single^2))) / 2;

        eof_single = ...
            -argument * log2(argument) - ...
            (1 - argument) * log2(1 - argument);
    end


    % =========================
    % Store results
    % =========================

    analytics = struct();

    analytics.num_segments_values = num_segments_values;

    analytics.rms_total_dgd = rms_total_dgd;

    analytics.rms_component_dgd = ...
        rms_component_dgd;

    analytics.rms_normalized_pmd_strength = ...
        rms_normalized_pmd_strength;

    analytics.single_segment = struct();

    analytics.single_segment.xi = xi_single;
    analytics.single_segment.coherence = coherence_single;

    analytics.single_segment.purity = purity_single;
    analytics.single_segment.fidelity = fidelity_single;
    analytics.single_segment.concurrence = concurrence_single;
    analytics.single_segment.tangle = tangle_single;
    analytics.single_segment.entanglement_of_formation = eof_single;
    analytics.single_segment.chsh_max = chsh_max_single;

end