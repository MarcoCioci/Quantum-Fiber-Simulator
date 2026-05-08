function purity = compute_purity(rho)
% COMPUTE_PURITY  Compute the purity Tr(ρ^2) of a density matrix.
%
% Objective:
%   Evaluate the purity of a quantum state represented by a density matrix.
%   This quantity is defined as
%
%       γ = Tr(ρ^2)
%
%   and is used to distinguish pure and mixed states:
%
%       γ = 1    for a pure state
%       γ < 1    for a mixed state
%
% Input:
%   rho - NxN density matrix representing a quantum state
%
% Output:
%   purity - scalar value equal to Tr(ρ^2)
%
% Notes:
%   The function is intended for density operators, so the input should be
%   square, Hermitian, and have unit trace up to numerical tolerance.
%   Small numerical imaginary residues in the final result are removed only
%   after verifying that they are negligible.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        error('compute_purity:InvalidNumInputs', ...
              'Expected exactly 1 input argument.');
    end

    if ~isnumeric(rho)
        error('compute_purity:InvalidType', ...
              'Input rho must be numeric.');
    end

    if isempty(rho)
        error('compute_purity:EmptyInput', ...
              'Input rho must not be empty.');
    end

    if ndims(rho) ~= 2
        error('compute_purity:InvalidDimensions', ...
              'Input rho must be a 2-D matrix.');
    end

    [num_rows, num_cols] = size(rho);

    if num_rows ~= num_cols
        error('compute_purity:InvalidSize', ...
              'Input rho must be square.');
    end

    tolerance = 1e-12;  % Tolerance for structural quantum-state checks

    if norm(rho - rho', 'fro') > tolerance
        error('compute_purity:NonHermitianInput', ...
              'Input rho must be Hermitian up to numerical tolerance.');
    end

    if abs(trace(rho) - 1) > tolerance
        error('compute_purity:InvalidTrace', ...
              'Input rho must have trace equal to 1 up to numerical tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    rho_squared = rho * rho;
    purity = trace(rho_squared);

    if abs(imag(purity)) > tolerance
        error('compute_purity:NonRealOutput', ...
              'Computed purity has a non-negligible imaginary part.');
    end

    purity = real(purity);

end