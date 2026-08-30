function U = pmd_segment_unitary( ...
        omega_offset, delta_phase, delta_tau, axis)
% PMD_SEGMENT_UNITARY  Return the polarization unitary of one birefringent segment.
%
% Objective:
%   Compute the lossless first-order frequency-dependent polarization
%   transformation associated with one locally uniform birefringent fiber
%   segment:
%
%       U(Ω) =
%       exp[
%           +i/2 * (Δφ + Δτ Ω) * (n · σ)
%       ],
%
%   where
%
%       Ω = ω - ω_0.
%
%   The polarization-independent common phase is omitted because it does
%   not affect the reduced polarization state.
%
% Input:
%   omega_offset - Angular-frequency offset
%
%                      Ω = ω - ω_0
%
%                  [rad/s]. Finite real numeric scalar.
%
%   delta_phase  - Signed differential phase
%
%                      Δφ = Δφ(ω_0)
%
%                  between the two local polarization eigenmodes at the
%                  carrier frequency [rad]. Finite real numeric scalar.
%
%   delta_tau    - Signed differential group-delay parameter
%
%                      Δτ = dΔφ/dω |_(ω_0)
%
%                  [s]. Finite real numeric scalar.
%
%                  The physical differential group delay is
%
%                      DGD = |Δτ|.
%
%   axis         - Three-component real Bloch vector n identifying the
%                  oriented local birefringence axis. The vector is
%                  normalized internally.
%
%                  With the convention adopted in the thesis, the +1
%                  eigenstate of n · σ corresponds to the slow local
%                  eigenmode and the -1 eigenstate to the fast mode.
%
% Output:
%   U            - 2-by-2 unitary polarization operator.
%
% Notes:
%   The first-order differential phase is
%
%       α(Ω) = Δφ + Δτ Ω.
%
%   Therefore,
%
%       U(Ω) = exp[+i α(Ω) (n · σ) / 2].
%
%   Since the normalized operator n · σ satisfies
%
%       (n · σ)^2 = I_2,
%
%   the exponential can be evaluated analytically as
%
%       U =
%       cos(α/2) I_2
%       + i sin(α/2) (n · σ).
%
%   Reversing the oriented axis together with the signs of Δφ and Δτ
%   represents the same physical birefringent segment.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 4
        error('pmd_segment_unitary:InvalidNumInputs', ...
            ['Expected exactly 4 input arguments: omega_offset, ', ...
             'delta_phase, delta_tau, axis.']);
    end

    if ~isnumeric(omega_offset) || ~isscalar(omega_offset) || ...
            ~isreal(omega_offset) || ~isfinite(omega_offset)
        error('pmd_segment_unitary:InvalidOmegaOffset', ...
            'omega_offset must be a finite real numeric scalar.');
    end

    if ~isnumeric(delta_phase) || ~isscalar(delta_phase) || ...
            ~isreal(delta_phase) || ~isfinite(delta_phase)
        error('pmd_segment_unitary:InvalidDeltaPhase', ...
            'delta_phase must be a finite real numeric scalar.');
    end

    if ~isnumeric(delta_tau) || ~isscalar(delta_tau) || ...
            ~isreal(delta_tau) || ~isfinite(delta_tau)
        error('pmd_segment_unitary:InvalidDeltaTau', ...
            'delta_tau must be a finite real numeric scalar.');
    end

    if ~isnumeric(axis) || ~isreal(axis) || ...
            ~isvector(axis) || numel(axis) ~= 3
        error('pmd_segment_unitary:InvalidAxis', ...
            'axis must be a real numeric vector with exactly three elements.');
    end

    if any(~isfinite(axis), 'all')
        error('pmd_segment_unitary:InvalidAxisValues', ...
            'axis must contain only finite values.');
    end

    axis = axis(:);

    axis_norm = norm(axis);

    if axis_norm == 0
        error('pmd_segment_unitary:NullAxis', ...
            'axis must be a non-null three-component vector.');
    end

    axis = axis / axis_norm;


    % =========================
    % Main computation
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    n_dot_sigma = ...
        axis(1) * sigma_x + ...
        axis(2) * sigma_y + ...
        axis(3) * sigma_z;

    % First-order frequency-dependent differential phase.
    alpha = delta_phase + delta_tau * omega_offset;

    % SU(2) closed-form exponential:
    %
    %   exp(+i alpha n.sigma / 2)
    %   =
    %   cos(alpha/2) I + i sin(alpha/2) n.sigma.

    U = ...
        cos(alpha / 2) * eye(2) + ...
        1i * sin(alpha / 2) * n_dot_sigma;

end