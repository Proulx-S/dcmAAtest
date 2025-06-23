function outputPath = modifyDicomCoordinates(dicomPath, targetFields, outputDirName)
    % MODIFYDICOMCOORDINATES Modify DICOM coordinates using specified target fields
    %   outputPath = modifyDicomCoordinates(dicomPath, targetFields, outputDirName)
    %
    % Inputs:
    %   dicomPath - Path to the input Siemens DICOM file
    %   targetFields - Cell array of target field names to extract from protocol
    %   outputDirName - Name of subdirectory to create in parent directory (e.g., 'modified', 'rewritten')
    %
    % Outputs:
    %   outputPath - Full path to the modified DICOM file
    %
    % This function:
    % 1. Reads the DICOM file
    % 2. Extracts coordinates from the specified target fields
    % 3. Applies coordinate transformation
    % 4. Creates a subdirectory named 'outputDirName' in the parent directory of dicomPath
    % 5. Saves the modified DICOM file in that subdirectory with the original filename
    %
    % Example:
    %   outputPath = modifyDicomCoordinates('input.dcm', targetFields, 'modified')
    %   % Creates: parentDir/modified/input.dcm
    %   % Returns: full path to the modified file
    
    % Check if dicm2nii is available, download if not
    if ~exist('dicm_hdr', 'file')
        fprintf('Downloading dicm2nii toolbox...\n');
        url = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/e5a13851-4a80-11e4-9553-005056977bd0/c5ce193c-31e2-4149-ac28-c6d14a9bd6f4/packages/zip';
        zipFile = websave('dicm2nii.zip', url);
        unzip(zipFile, 'dicm2nii');
        delete(zipFile);
        addpath(genpath('dicm2nii'));
        fprintf('dicm2nii toolbox downloaded and added to path.\n');
    end
    
    fprintf('Processing DICOM file: %s\n', dicomPath);
    
    % Read DICOM file
    info = dicominfo(dicomPath);
    info2 = dicm_hdr(dicomPath);
    
    % Check if this is a Siemens DICOM with MrPhoenixProtocol
    if ~isfield(info2, 'CSASeriesHeaderInfo') || ~isfield(info2.CSASeriesHeaderInfo, 'MrPhoenixProtocol')
        error('This DICOM file does not contain Siemens MrPhoenixProtocol information.');
    end
    
    % Extract values from specified target fields
    fieldValues = extractProtocolFields(info2.CSASeriesHeaderInfo.MrPhoenixProtocol, targetFields);
    
    % Check if all required fields were found
    missingFields = cellfun(@isempty, fieldValues);
    if any(missingFields)
        error('Missing required protocol fields: %s', strjoin(targetFields(missingFields), ', '));
    end
    
    fprintf('Extracted values:\n');
    fprintf('In-plane rotation: %s radians\n', fieldValues{1});
    fprintf('Position (Sag, Cor, Tra): [%s, %s, %s]\n', fieldValues{2}, fieldValues{3}, fieldValues{4});
    fprintf('Normal (Sag, Cor, Tra): [%s, %s, %s]\n', fieldValues{5}, fieldValues{6}, fieldValues{7});
    
    % Compute the offset between DICOM and scanner coordinates
    scannerPosition = str2double({fieldValues{2}, fieldValues{3}, fieldValues{4}})';
    offset = info2.SlicePosition_PCS - scannerPosition;
    
    fprintf('Scanner position: [%.6f, %.6f, %.6f]\n', scannerPosition(1), scannerPosition(2), scannerPosition(3));
    fprintf('DICOM position: [%.6f, %.6f, %.6f]\n', info2.SlicePosition_PCS(1), info2.SlicePosition_PCS(2), info2.SlicePosition_PCS(3));
    fprintf('Translation offset: [%.6f, %.6f, %.6f]\n', offset(1), offset(2), offset(3));
    
    % Transform scanner coordinates to patient coordinates
    imagePosition = scannerPosition + offset;
    
    % Extract scanner normal and in-plane rotation
    scannerNormal = str2double({fieldValues{5}, fieldValues{6}, fieldValues{7}});
    inPlaneRot = str2double(fieldValues{1});
    
    % Convert scanner normal to patient orientation
    imageOrientation = scannerNormalToPatientOrientationExact(scannerNormal, inPlaneRot);
    
    fprintf('Scanner normal: [%.6f, %.6f, %.6f]\n', scannerNormal(1), scannerNormal(2), scannerNormal(3));
    fprintf('In-plane rotation: %.6f radians (%.2f degrees)\n', inPlaneRot, inPlaneRot * 180 / pi);
    fprintf('Patient orientation: [%.6f, %.6f, %.6f, %.6f, %.6f, %.6f]\n', imageOrientation);
    
    % Create modified DICOM
    infoModified = info;
    infoModified.ImagePositionPatient = imagePosition;
    infoModified.SliceLocation     = infoModified.ImagePositionPatient(end);
    infoModified.ImageOrientationPatient = imageOrientation;
    
    % Generate output path by creating subdirectory in parent directory
    [filepath, name, ext] = fileparts(dicomPath);
    filepath = fileparts(filepath);
    outputDir = fullfile(filepath, outputDirName);
    
    % Create the output directory if it doesn't exist
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
        fprintf('Created output directory: %s\n', outputDir);
    end
    
    outputPath = fullfile(outputDir, [name ext]);
    
    % Save the modified DICOM file
    fprintf('Writing modified DICOM: %s\n', outputPath);
    imageData = dicomread(dicomPath);
    dicomwrite(imageData, outputPath, infoModified);
    
    fprintf('✓ DICOM modification completed successfully!\n');
    fprintf('Output file: %s\n', outputPath);
end 