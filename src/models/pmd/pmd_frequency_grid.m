function [omega_offsets, delta_omega] = pmd_frequency_grid(num_points, max_offset)
% PMD_FREQUENCY_GRID  Create a symmetric uniform angular-frequency-offset grid.
%
% Objective:
%   Generate a uniform grid of angular-frequency offsets around the carrier
%   frequency:
%
%       Ω_k ∈ [-Ω_max, +Ω_max],
%
%   where
%
%       Ω = ω - ω_0.
%
% Input:
%   num_points - Odd number of frequency nodes. Integer >= 3.
%
%   max_offset - Positive maximum angular-frequency offset
%
%                    Ω_max > 0
%
%                [rad/s]. Finite real numeric scalar.
%
% Output:
%   omega_offsets - num_points-by-1 vector of angular-frequency offsets
%                   Ω_k [rad/s].
%
%   delta_omega   - Uniform angular-frequency spacing
%
%                       ΔΩ = 2 Ω_max / (num_points - 1)
%
%                   [rad/s].
%
% Notes:
%   An odd number of nodes is adopted as a numerical convention so that
%   Ω = 0 is included exactly. The zero-offset node corresponds to the
%   carrier angular frequency ω_0,K of the propagation arm using the grid.
%
%   The returned delta_omega is the grid spacing and should not in general
%   be identified directly with the quadrature weights. The latter depend
%   on the numerical integration rule used for the spectral trace.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('pmd_frequency_grid:InvalidNumInputs', ...
            'Expected exactly 2 input arguments: num_points, max_offset.');
    end

    if ~isnumeric(num_points) || ~isscalar(num_points) || ...
            ~isreal(num_points) || ~isfinite(num_points)
        error('pmd_frequency_grid:InvalidNumPoints', ...
            'num_points must be a finite real numeric scalar.');
    end

    if num_points < 3 || num_points ~= floor(num_points)
        error('pmd_frequency_grid:InvalidNumPointsRange', ...
            'num_points must be an integer greater than or equal to 3.');
    end

    if mod(num_points, 2) == 0
        error('pmd_frequency_grid:EvenNumPoints', ...
            'num_points must be odd so that omega_offset = 0 is included.');
    end

    if ~isnumeric(max_offset) || ~isscalar(max_offset) || ...
            ~isreal(max_offset) || ~isfinite(max_offset)
        error('pmd_frequency_grid:InvalidMaxOffset', ...
            'max_offset must be a finite real numeric scalar.');
    end

    if max_offset <= 0
        error('pmd_frequency_grid:InvalidMaxOffsetRange', ...
            'max_offset must satisfy max_offset > 0.');
    end


    % =========================
    % Main computation
    % =========================

    % Uniform spacing over [-max_offset, +max_offset].

    delta_omega = 2 * max_offset / (num_points - 1);

    % Integer-centered construction guarantees that the central node is
    % exactly omega_offset = 0.

    half_num_points = (num_points - 1) / 2;

    omega_offsets = ...
        (-half_num_points:half_num_points)' * delta_omega;

end