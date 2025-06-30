function fieldValues = extractProtocolFields(protocolText, fieldNames)
    % EXTRACTPROTOCOLFIELDS Extract specific field values from MrPhoenixProtocol
    %   fieldValues = extractProtocolFields(protocolText, fieldNames)
    %   
    %   Inputs:
    %       protocolText - MrPhoenixProtocol text string
    %       fieldNames - Cell array of field names to extract
    %   
    %   Outputs:
    %       fieldValues - Cell array of field values in the same order as fieldNames
    %                    (empty string if field not found)
    
    
    % Find ASCCONV section - look for the actual format with additional text
    % Find the start of the ASCCONV section by looking for the BEGIN marker
    startIdx = regexp(protocolText, '### ASCCONV BEGIN.*?###', 'once');
    endIdx = strfind(protocolText, '### ASCCONV END ###');
    
    if isempty(startIdx) || isempty(endIdx)
        fprintf('ASCCONV section not found in protocol text\n');
        return;
    end
    
    % Extract ASCCONV text (include the BEGIN marker and everything up to END)
    ascconvText = protocolText(startIdx:endIdx+length('### ASCCONV END ###')-1);
    
    if ~exist('fieldNames', 'var') || isempty(fieldNames)
        % Create temporary file and write ASCCONV text to it
        fieldValues = [tempname, '.txt'];
        fid = fopen(fieldValues, 'w');
        if fid ~= -1
            fprintf(fid, '%s', ascconvText);
            fclose(fid);
        else
            fprintf('Error: Could not create temporary file\n');
            fieldValues = '';
        end

        return;
    end

    % Split into lines for processing
    lines = strsplit(ascconvText, '\n');
    
    % Initialize return value
    fieldValues = cell(size(fieldNames));
    
    % Process each field
    for fieldIdx = 1:length(fieldNames)
        fieldName = fieldNames{fieldIdx};
        fieldValue = '';
        
        % Search for the field in the lines
        for i = 1:length(lines)
            line = lines{i};
            if contains(line, fieldName) && contains(line, '=')
                % Extract the value after the = sign
                parts = strsplit(line, '=');
                if length(parts) >= 2
                    fieldValue = strtrim(parts{2});
                    break;
                end
            end
        end
        
        % Store the value in the same order as the input fieldNames
        fieldValues{fieldIdx} = fieldValue;
    end
end 