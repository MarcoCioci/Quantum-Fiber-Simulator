function ket = computational_basis(label)
% COMPUTATIONAL_BASIS  Return computational basis vector(s) for qubits.
%
% Objective:
%   Generate standard computational basis vectors for single-qubit or
%   multi-qubit systems using string labels.
%
% Input:
%   label - string specifying the basis state:
%           '0', '1'           (single qubit)
%           '00', '01', ...    (multi-qubit)
%
% Output:
%   ket   - column vector representing the corresponding basis state
%
% Notes:
%   - Basis ordering follows tensor product structure:
%         |ab⟩ = |a⟩ ⊗ |b⟩
%   - For multi-qubit states, the function builds the vector via repeated
%     tensor products.
%
% Example:
%   computational_basis('0')   -> [1; 0]
%   computational_basis('1')   -> [0; 1]
%   computational_basis('01')  -> tensor_product([1;0], [0;1])

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        error('computational_basis:InvalidNumInputs', ...
              'Expected 1 input argument.');
    end

    if ~ischar(label) && ~isstring(label)
        error('computational_basis:InvalidType', ...
              'label must be a string or character array.');
    end

    label = char(label);

    if isempty(label)
        error('computational_basis:EmptyLabel', ...
              'Label cannot be empty.');
    end

    if any(~ismember(label, ['0', '1']))
        error('computational_basis:InvalidLabel', ...
              'Label must contain only characters ''0'' or ''1''.');
    end


    % =========================
    % Main computation
    % =========================

    % Single-qubit basis vectors
    ket_0 = [1; 0];
    ket_1 = [0; 1];

    % Initialize with first qubit
    if label(1) == '0'
        ket = ket_0;
    else
        ket = ket_1;
    end

    % Build tensor product for multi-qubit case
    for k = 2:length(label)
        if label(k) == '0'
            next_ket = ket_0;
        else
            next_ket = ket_1;
        end

        ket = tensor_product(ket, next_ket);
    end

end