function expectation_value_density = expectation_value_density(rho, O)
% EXPECTATION_VALUE_DENSITY  Compute the expectation value of an observable
% for a quantum state represented by a density matrix.
%
% Objective:
%   Given a density operator rho and an observable O acting on the same
%   Hilbert space, compute the expectation value using
%
%       <O> = Tr(rho * O)
%
%   This function is the density-matrix counterpart of the pure-state
%   expectation value formula.
%
% Input:
%   rho - square complex density matrix representing a quantum state
%
%   O   - square complex matrix representing an observable operator acting
%         on the same Hilbert space as rho
%
% Output:
%   expectation_value_density - scalar expectation value associated with O
%
% Notes:
%   This function is dimension-agnostic:
%     - 2x2 for single-qubit states
%     - 4x4 for two-qubit states
%     - in general, dxd for any finite-dimensional system
%
%   If rho corresponds to a pure state, i.e.
%
%       rho = |psi><psi|,
%
%   then this formula is equivalent to
%
%       <O> = <psi|O|psi>.
%
%   For Hermitian observables and valid density matrices, the expectation
%   value should be real up to numerical roundoff.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('expectation_value_density:InvalidNumInputs', ...
              'Expected exactly 2 input arguments: rho and O.');
    end

    if ~isnumeric(rho)
        error('expectation_value_density:InvalidTypeRho', ...
              'rho must be numeric.');
    end

    if ~isnumeric(O)
        error('expectation_value_density:InvalidTypeObservable', ...
              'O must be numeric.');
    end

    if isempty(rho)
        error('expectation_value_density:EmptyRho', ...
              'rho must be non-empty.');
    end

    if isempty(O)
        error('expectation_value_density:EmptyObservable', ...
              'O must be non-empty.');
    end

    if ndims(rho) ~= 2
        error('expectation_value_density:InvalidDimensionsRho', ...
              'rho must be a 2-D matrix.');
    end

    if ndims(O) ~= 2
        error('expectation_value_density:InvalidDimensionsObservable', ...
              'O must be a 2-D matrix.');
    end

    if size(rho, 1) ~= size(rho, 2)
        error('expectation_value_density:NonSquareRho', ...
              'rho must be square.');
    end

    if size(O, 1) ~= size(O, 2)
        error('expectation_value_density:NonSquareObservable', ...
              'O must be square.');
    end

    if ~isequal(size(rho), size(O))
        error('expectation_value_density:DimensionMismatch', ...
              'rho and O must have the same dimensions.');
    end

    if any(~isfinite(rho), 'all')
        error('expectation_value_density:NonFiniteRho', ...
              'rho must contain only finite values.');
    end

    if any(~isfinite(O), 'all')
        error('expectation_value_density:NonFiniteObservable', ...
              'O must contain only finite values.');
    end

    tol = 1e-12;

    if norm(rho - rho', 'fro') > tol
        error('expectation_value_density:NonHermitianRho', ...
              'rho must be Hermitian within numerical tolerance.');
    end

    if abs(trace(rho) - 1) > tol
        error('expectation_value_density:InvalidTraceRho', ...
              'rho must have unit trace within numerical tolerance.');
    end

    if norm(O - O', 'fro') > tol
        error('expectation_value_density:NonHermitianObservable', ...
              'O must be Hermitian within numerical tolerance.');
    end

    rho_eigenvalues = eig(rho);

    if any(real(rho_eigenvalues) < -tol)
        error('expectation_value_density:NonPositiveRho', ...
              'rho must be positive semidefinite within numerical tolerance.');
    end

    if max(abs(imag(rho_eigenvalues))) > tol
        error('expectation_value_density:ComplexEigenvaluesRho', ...
              'rho has eigenvalues with non-negligible imaginary part.');
    end


    % =========================
    % Main computation
    % =========================

    expectation_value_density = trace(rho * O);

    if abs(imag(expectation_value_density)) < tol
        expectation_value_density = real(expectation_value_density);
    else
        error('expectation_value_density:ComplexExpectationValue', ...
              'The expectation value must be real within numerical tolerance.');
    end

end