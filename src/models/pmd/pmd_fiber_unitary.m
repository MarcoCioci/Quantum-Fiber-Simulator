function U_fiber = pmd_fiber_unitary( ...
        omega_offset, delta_phases, delta_taus, axes)
% PMD_FIBER_UNITARY  Return the polarization unitary of a segmented PMD fiber.
%
% Objective:
%   Concatenate the frequency-dependent polarization transformations of N
%   locally uniform birefringent fiber segments:
%
%       U_fiber(Ω) = U_N(Ω) ... U_2(Ω) U_1(Ω).
%
%   Segment 1 is crossed first and is therefore the rightmost factor.
%
% Input:
%   omega_offset - Angular-frequency offset
%
%                      Ω = ω - ω_0
%
%                  [rad/s]. Finite real numeric scalar.
%
%   delta_phases - Nx1 or 1xN vector of signed differential phases
%
%                      Δφ_j = Δφ_j(ω_0)
%
%                  accumulated between the two local polarization
%                  eigenmodes at the carrier frequency [rad].
%
%   delta_taus  - Nx1 or 1xN vector of signed differential delays
%
%                      Δτ_j = dΔφ_j/dω |_(ω_0)
%
%                  [s]. The physical differential group delay of segment j
%                  is DGD_j = |Δτ_j|.
%
%   axes        - Nx3 matrix of oriented Bloch vectors n_j. Row j
%                 identifies the birefringence eigenmode axis of segment j.
%                 With the convention adopted in the thesis, +n_j
%                 corresponds to the slow local eigenmode and -n_j to the
%                 fast local eigenmode.
%
% Output:
%   U_fiber     - 2x2 unitary polarization operator U_fiber(Ω).
%
% Notes:
%   Each segment is constructed as
%
%       U_j(Ω) = pmd_segment_unitary( ...
%           Ω, Δφ_j, Δτ_j, n_j).
%
%   The segment model retains the polarization-dependent SU(2) part of the
%   propagation operator. Polarization-independent common phase factors are
%   omitted because they do not affect the reduced polarization state.
%
%   Each axis n_j is normalized internally by pmd_segment_unitary.
%   Therefore, axes specifies oriented eigenmode directions but its rows
%   need not initially have unit norm.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 4
        error('pmd_fiber_unitary:InvalidNumInputs', ...
            ['Expected exactly 4 input arguments: omega_offset, ', ...
             'delta_phases, delta_taus, axes.']);
    end

    if ~isnumeric(omega_offset) || ~isscalar(omega_offset) || ...
            ~isreal(omega_offset) || ~isfinite(omega_offset)
        error('pmd_fiber_unitary:InvalidOmegaOffset', ...
            'omega_offset must be a finite real numeric scalar.');
    end

    if ~isnumeric(delta_phases) || ~isreal(delta_phases) || ...
            ~isvector(delta_phases) || isempty(delta_phases)
        error('pmd_fiber_unitary:InvalidDeltaPhases', ...
            'delta_phases must be a non-empty real numeric vector.');
    end

    if any(~isfinite(delta_phases), 'all')
        error('pmd_fiber_unitary:InvalidDeltaPhaseValues', ...
            'delta_phases must contain only finite values.');
    end

    if ~isnumeric(delta_taus) || ~isreal(delta_taus) || ...
            ~isvector(delta_taus) || isempty(delta_taus)
        error('pmd_fiber_unitary:InvalidDeltaTaus', ...
            'delta_taus must be a non-empty real numeric vector.');
    end

    if any(~isfinite(delta_taus), 'all')
        error('pmd_fiber_unitary:InvalidDeltaTauValues', ...
            'delta_taus must contain only finite values.');
    end

    if ~isnumeric(axes) || ~isreal(axes) || ...
            ~ismatrix(axes) || size(axes, 2) ~= 3
        error('pmd_fiber_unitary:InvalidAxes', ...
            'axes must be a real numeric N-by-3 matrix.');
    end

    if any(~isfinite(axes), 'all')
        error('pmd_fiber_unitary:InvalidAxisValues', ...
            'axes must contain only finite values.');
    end

    delta_phases = delta_phases(:);
    delta_taus = delta_taus(:);

    num_segments = numel(delta_phases);

    if numel(delta_taus) ~= num_segments
        error('pmd_fiber_unitary:InconsistentSegmentCount', ...
            ['delta_phases and delta_taus must contain the same ', ...
             'number of elements.']);
    end

    if size(axes, 1) ~= num_segments
        error('pmd_fiber_unitary:InconsistentAxisCount', ...
            'axes must contain one row for each segment.');
    end

    if any(vecnorm(axes, 2, 2) == 0)
        error('pmd_fiber_unitary:NullAxis', ...
            'Each row of axes must be a non-null three-component vector.');
    end


    % =========================
    % Main computation
    % =========================

    % Start from the identity. Left multiplication by each successive
    % segment ensures that segment 1 acts first:
    %
    %     U_fiber = U_N ... U_2 U_1.

    U_fiber = eye(2);

    for i = 1:num_segments

        delta_phase_i = delta_phases(i);
        delta_tau_i = delta_taus(i);
        axis_i = axes(i, :);

        U_segment = pmd_segment_unitary( ...
            omega_offset, delta_phase_i, delta_tau_i, axis_i);

        U_fiber = U_segment * U_fiber;

    end

end