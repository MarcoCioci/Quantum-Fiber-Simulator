function rho_average = pmd_spectral_average_state( ...
        frequency_states, spectral_weights)
% PMD_SPECTRAL_AVERAGE_STATE  Trace over the discrete joint spectrum.
%
% Objective:
%   Construct the reduced two-qubit polarization density matrix by
%   averaging the frequency-resolved polarization states over the
%   normalized discrete joint spectral probabilities:
%
%       rho_average =
%       sum_k sum_l Q(k,l) * rho(k,l).
%
%   This is the discrete approximation of the spectral partial trace.
%
% Input:
%   frequency_states - 4-by-4-by-N_A-by-N_B complex array such that
%
%       frequency_states(:, :, k, l) = rho(k,l),
%
%                     where rho(k,l) is the two-qubit polarization density
%                     matrix associated with the spectral pair
%                     (Omega_A,k, Omega_B,l).
%
%   spectral_weights - N_A-by-N_B real non-negative matrix containing the
%                      normalized discrete joint spectral probabilities
%
%                          Q(k,l) >= 0,
%
%                      satisfying
%
%                          sum_k sum_l Q(k,l) = 1.
%
% Output:
%   rho_average     - 4-by-4 reduced two-qubit polarization density matrix
%                     obtained after tracing over the unresolved spectral
%                     degree of freedom.
%
% Notes:
%   The operation performed here is the discrete spectral trace, not an
%   additional statistical average over different fiber realizations.
%
%   Each frequency pair is first propagated independently. Only afterwards
%   are the resulting polarization density matrices combined using the
%   joint spectral probabilities Q(k,l).
%
%   The frequency-dependent Jones operators themselves must not be averaged
%   before acting on the input state, because that would describe a
%   different physical transformation.
%
%   A separate ensemble average is required if different stochastic fiber
%   realizations are to be combined.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('pmd_spectral_average_state:InvalidNumInputs', ...
            ['Expected exactly 2 input arguments: frequency_states, ', ...
             'spectral_weights.']);
    end

    if ~isnumeric(frequency_states)
        error('pmd_spectral_average_state:InvalidFrequencyStates', ...
            'frequency_states must be a numeric array.');
    end

    if any(~isfinite(frequency_states), 'all')
        error('pmd_spectral_average_state:InvalidFrequencyStateValues', ...
            'frequency_states must contain only finite values.');
    end

    if size(frequency_states, 1) ~= 4 || ...
            size(frequency_states, 2) ~= 4
        error('pmd_spectral_average_state:InvalidFrequencyStateSize', ...
            'frequency_states must have leading dimensions 4-by-4.');
    end

    if ndims(frequency_states) > 4
        error('pmd_spectral_average_state:InvalidFrequencyStateDimensions', ...
            'frequency_states must be a 4-by-4-by-N_A-by-N_B array.');
    end

    if ~isnumeric(spectral_weights) || ...
            ~isreal(spectral_weights) || ...
            ~ismatrix(spectral_weights) || ...
            isempty(spectral_weights)
        error('pmd_spectral_average_state:InvalidSpectralWeights', ...
            'spectral_weights must be a non-empty real numeric matrix.');
    end

    if any(~isfinite(spectral_weights), 'all')
        error('pmd_spectral_average_state:InvalidSpectralWeightValues', ...
            'spectral_weights must contain only finite values.');
    end

    if any(spectral_weights < 0, 'all')
        error('pmd_spectral_average_state:NegativeSpectralWeights', ...
            'spectral_weights must be non-negative.');
    end

    total_weight = sum(spectral_weights, 'all');

    normalization_tolerance = 1e-12;

    if abs(total_weight - 1) > normalization_tolerance
        error('pmd_spectral_average_state:UnnormalizedSpectralWeights', ...
            ['spectral_weights must satisfy ', ...
             'sum(spectral_weights, ''all'') = 1 within tolerance.']);
    end

    num_frequencies_A = size(spectral_weights, 1);
    num_frequencies_B = size(spectral_weights, 2);

    if size(frequency_states, 3) ~= num_frequencies_A || ...
            size(frequency_states, 4) ~= num_frequencies_B
        error('pmd_spectral_average_state:InconsistentSpectralDimensions', ...
            ['frequency_states and spectral_weights must describe the ', ...
             'same N_A-by-N_B frequency-pair grid.']);
    end


    % =========================
    % Main computation
    % =========================

    % Initialize the reduced polarization density matrix.

    rho_average = complex(zeros(4, 4));

    % Perform the discrete spectral trace:
    %
    %     rho_average = sum_k sum_l Q(k,l) rho(k,l).

    for k = 1:num_frequencies_A

        for l = 1:num_frequencies_B

            rho_k_l = frequency_states(:, :, k, l);
            Q_k_l = spectral_weights(k, l);

            rho_average = ...
                rho_average + Q_k_l * rho_k_l;

        end

    end


    % =========================
    % Output validation
    % =========================

    state_tolerance = 1e-10;

    if norm(rho_average - rho_average', 'fro') > state_tolerance
        error('pmd_spectral_average_state:NonHermitianOutput', ...
            ['The spectrally averaged output state is not Hermitian ', ...
             'within numerical tolerance.']);
    end

    if abs(trace(rho_average) - 1) > state_tolerance
        error('pmd_spectral_average_state:InvalidOutputTrace', ...
            ['The spectrally averaged output state does not have unit ', ...
             'trace within numerical tolerance.']);
    end

    rho_hermitian = (rho_average + rho_average') / 2;
    rho_eigenvalues = eig(rho_hermitian);

    if any(real(rho_eigenvalues) < -state_tolerance)
        error('pmd_spectral_average_state:NonPositiveOutput', ...
            ['The spectrally averaged output state is not positive ', ...
             'semidefinite within numerical tolerance.']);
    end

end