function patientOrientation = scannerNormalToPatientOrientationExact(scannerNormal, inPlaneRot)
    % SCANNERNORMALTOPATIENTORIENTATIONEXACT Exact conversion using Siemens' method
    %   patientOrientation = scannerNormalToPatientOrientationExact(scannerNormal, inPlaneRot)
    %
    % This function uses the exact transformation method discovered through
    % reverse engineering of the DICOM orientation. It provides more accurate
    % results than the standard function.
    %
    % Inputs:
    %   scannerNormal - 1x3 scanner normal vector (Sag, Cor, Tra)
    %   inPlaneRot - in-plane rotation in radians (from protocol)
    %
    % Outputs:
    %   patientOrientation - 6x1 vector in ImageOrientationPatient format
    
    % Ensure scanner normal is a column vector and normalized
    scannerNormal = scannerNormal(:) / norm(scannerNormal);
    
    % For HFS position, scanner normal directly maps to patient normal
    sliceNormal = scannerNormal;
    
    % Use [1,0,0] as the reference direction (this matches Siemens' approach)
    refVector = [1; 0; 0];
    
    % Project the reference vector into the slice plane
    projectedRef = refVector - dot(refVector, sliceNormal) * sliceNormal;
    projectedRef = projectedRef / norm(projectedRef);
    
    % Apply the in-plane rotation
    cosRot = cos(inPlaneRot);
    sinRot = sin(inPlaneRot);
    
    rotatedRowDir = cosRot * projectedRef + sinRot * cross(sliceNormal, projectedRef);
    rotatedRowDir = rotatedRowDir / norm(rotatedRowDir);
    
    % Column direction is perpendicular to both normal and row
    colDir = cross(sliceNormal, rotatedRowDir);
    colDir = colDir / norm(colDir);
    
    % Return in ImageOrientationPatient format [rowDir; colDir]
    patientOrientation = [rotatedRowDir; colDir];
end 