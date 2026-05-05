function exp_val = expectation_value(state, O)
% EXPECTATION_VALUE  Compute the expectation value of an observable.
%
% Objective:
%   Compute the expectation value of an observable O for either:
%
%       pure state:      ⟨O⟩ = ψ' * O * ψ
%       density matrix:  ⟨O⟩ = Tr(ρ * O)
%
% Input:
%   state - quantum state, either:
%           - n x 1 pure-state vector ψ
%           - n x n density matrix ρ
%
%   O     - n x n Hermitian observable operator
%
% Output:
%   exp_val - scalar expectation value of O
%
% Notes:
%   This function is dimension-general.
%   It accepts both pure-state vectors and density matrices.
%   For Hermitian observables and valid quantum states, the result should be
%   real up to numerical roundoff.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('expectation_value:InvalidNumInputs', ...
              'Expected exactly 2 input arguments: state and O.');
    end

    if ~isnumeric(state)
        error('expectation_value:InvalidTypeState', ...
              'state must be numeric.');
    end

    if ~isnumeric(O)
        error('expectation_value:InvalidTypeObservable', ...
              'O must be numeric.');
    end

    if isempty(state)
        error('expectation_value:EmptyState', ...
              'state must be non-empty.');
    end

    if isempty(O)
        error('expectation_value:EmptyObservable', ...
              'O must be non-empty.');
    end

    if ~ismatrix(state)
        error('expectation_value:InvalidDimensionsState', ...
              'state must be a 2-D vector or matrix.');
    end

    if ~ismatrix(O)
        error('expectation_value:InvalidDimensionsObservable', ...
          'O must be a 2-D matrix.');
    end

    if any(~isfinite(state), 'all')
        error('expectation_value:NonFiniteState', ...
              'state must contain only finite values.');
    end

    if any(~isfinite(O), 'all')
        error('expectation_value:NonFiniteObservable', ...
              'O must contain only finite values.');
    end

    if size(O, 1) ~= size(O, 2)
        error('expectation_value:NonSquareObservable', ...
              'O must be square.');
    end

    tolerance = 1e-12;

    if norm(O - O', 'fro') > tolerance
        error('expectation_value:NonHermitianObservable', ...
              'O must be Hermitian within numerical tolerance.');
    end


    % =========================
    % State-type detection
    % =========================

    if isvector(state)

        state_type = 'pure';

        if size(state,2) ~= 1
            error('expectation_value:InvalidKetShape', ...
                  'Pure state must be a column vector (n x 1). Row vectors are not accepted.');
        end
        
        psi = state;
        n = length(psi);

        if ~isequal(size(O), [n n])
            error('expectation_value:DimensionMismatch', ...
                  'For a pure state, O must be n x n, where n = length(psi).');
        end

        if exist('is_normalized', 'file') == 2 && ~is_normalized(psi)
            warning('expectation_value:StateNotNormalized', ...
                    ['psi does not appear to be normalized. ', ...
                     'The returned value may not correspond to a valid physical expectation value.']);
        end

    elseif size(state, 1) == size(state, 2)

        state_type = 'density';
        rho = state;
        n = size(rho, 1);

        if ~isequal(size(O), [n n])
            error('expectation_value:DimensionMismatch', ...
                  'For a density matrix, rho and O must have the same dimensions.');
        end

        if norm(rho - rho', 'fro') > tolerance
            error('expectation_value:NonHermitianDensityMatrix', ...
                  'rho must be Hermitian within numerical tolerance.');
        end

        if abs(trace(rho) - 1) > tolerance
            error('expectation_value:InvalidTraceDensityMatrix', ...
                  'rho must have unit trace within numerical tolerance.');
        end

        rho_eigenvalues = eig(rho);

        if max(abs(imag(rho_eigenvalues))) > tolerance
            error('expectation_value:ComplexEigenvaluesDensityMatrix', ...
                  'rho has eigenvalues with non-negligible imaginary part.');
        end

        if any(real(rho_eigenvalues) < -tolerance)
            error('expectation_value:NonPositiveDensityMatrix', ...
                  'rho must be positive semidefinite within numerical tolerance.');
        end

    else

        error('expectation_value:InvalidStateShape', ...
              'state must be either a state vector or a square density matrix.');

    end


    % =========================
    % Main computation
    % =========================

    switch state_type

        case 'pure'
            exp_val = psi' * O * psi;

        case 'density'
            exp_val = trace(rho * O);

    end

    if abs(imag(exp_val)) < tolerance
        exp_val = real(exp_val);
    else
        error('expectation_value:ComplexExpectationValue', ...
              'The expectation value must be real within numerical tolerance.');
    end

end