function check_required_fields(input_struct, required_fields, error_id)
% CHECK_REQUIRED_FIELDS  Verify that all required fields are present.

    for field_idx = 1:numel(required_fields)

        field_name = required_fields{field_idx};

        if ~isfield(input_struct, field_name)
            error(error_id, 'Field "%s" not found.', field_name);
        end

    end

end