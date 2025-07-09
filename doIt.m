clear all
close all

%% Dependencies
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



%% Showcasing CSA MrPhoenixProtocol fields that seems relevant
dicomPath = fullfile(pwd, 'sub-vsmDrivenP3/037-vfMRI_fl3d_p4xp4x1p2_1e/orig/oneFrame.dcm');
info2 = dicm_hdr(dicomPath);
MrPhoenixFile = extractProtocolFields(info2.CSASeriesHeaderInfo.MrPhoenixProtocol);
% when the second input to extractProtocolFields is omited, it will write MrPhoenixProtocol to a tmp file and output the path in fieldValues
movefile(MrPhoenixFile, fullfile(pwd, 'MrPhoenixProtocolExample.txt'));
MrPhoenixFile = fullfile(pwd, 'MrPhoenixProtocolExample.txt');
open(MrPhoenixFile)

% most relevant fields
targetFieldsRewrite = {
    'sSliceArray.asSlice[0].dInPlaneRot'
    'sSliceArray.asSlice[0].sPosition.dSag'
    'sSliceArray.asSlice[0].sPosition.dCor'
    'sSliceArray.asSlice[0].sPosition.dTra'
    'sSliceArray.asSlice[0].sNormal.dSag'
    'sSliceArray.asSlice[0].sNormal.dCor'
    'sSliceArray.asSlice[0].sNormal.dTra'
    };
targetFieldsModify = {
    'sAAInitialOffset.SliceInformation.dInPlaneRot'
    'sAAInitialOffset.SliceInformation.sPosition.dSag'
    'sAAInitialOffset.SliceInformation.sPosition.dCor'
    'sAAInitialOffset.SliceInformation.sPosition.dTra'
    'sAAInitialOffset.SliceInformation.sNormal.dSag'
    'sAAInitialOffset.SliceInformation.sNormal.dCor'
    'sAAInitialOffset.SliceInformation.sNormal.dTra'
    };


%% Showcase dicom fields to be modified to affect slice location/orientation after conversion to nifti
dicomPath = fullfile(pwd, 'sub-vsmDrivenP3/037-vfMRI_fl3d_p4xp4x1p2_1e/orig/oneFrame.dcm');
info = dicominfo(dicomPath);
info.ImagePositionPatient
info.SliceLocation
info.ImageOrientationPatient


%% Showcase other candidate fields
info2.CSAImageHeaderInfo.SlicePosition_PCS
info2.CSAImageHeaderInfo.PhaseEncodingDirectionPositive
info2.CSAImageHeaderInfo.ImaRelTablePosition
info2.SliceLocation
info2.ImageOrientationPatient
info2.ImagePositionPatient
info2.SlicePosition_PCS
info2.ImaRelTablePosition
info2.ImaAbsTablePosition
info2.TablePositionOrigin
info2.AcquisitionMatrix
info2.InPlanePhaseEncodingDirection
info2.ReferencedImageSequence

info.Private_0019_10xx_Creator
info.Private_0019_100b
info.Private_0019_100f
info.Private_0019_1008
info.Private_0019_1009
info.Private_0019_1011
info.Private_0019_1012
info.Private_0019_1013
info.Private_0019_1014
info.Private_0019_1015 % same as ImagePositionPatient or SlicePosition_PCS
info.Private_0019_1016
info.Private_0019_1017
info.Private_0019_1018



%% Modify run 1 (acquired toward the beginning of the session) header
% Read and modify the dicom headers
dicomOriginal  = fullfile(pwd, 'sub-vsmDrivenP3/013-vfMRI_fl3d_p4xp4x1p2_1e/orig/oneFrame.dcm')
dicomRewritten = modifyDicomCoordinates(dicomOriginal, targetFieldsRewrite, 'rewritten')
dicomModified  = modifyDicomCoordinates(dicomOriginal, targetFieldsModify , 'modified' )

% Convert to nifti
delete(fullfile(fileparts(dicomOriginal), '*.nii'))
delete(fullfile(fileparts(dicomOriginal), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomOriginal), fileparts(dicomOriginal)));

delete(fullfile(fileparts(dicomRewritten), '*.nii'))
delete(fullfile(fileparts(dicomRewritten), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomRewritten), fileparts(dicomRewritten)));

delete(fullfile(fileparts(dicomModified), '*.nii'))
delete(fullfile(fileparts(dicomModified), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomModified), fileparts(dicomModified)));





%% Modify run 2 (acquired toward the end of the session) header

% Read and modify the dicom headers
dicomOriginal  = fullfile(pwd, 'sub-vsmDrivenP3/037-vfMRI_fl3d_p4xp4x1p2_1e/orig/oneFrame.dcm')
dicomRewritten = modifyDicomCoordinates(dicomOriginal, targetFieldsRewrite, 'rewritten')
dicomModified  = modifyDicomCoordinates(dicomOriginal, targetFieldsModify , 'modified' )


% Convert to nifti
delete(fullfile(fileparts(dicomOriginal), '*.nii'))
delete(fullfile(fileparts(dicomOriginal), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomOriginal), fileparts(dicomOriginal)));

delete(fullfile(fileparts(dicomRewritten), '*.nii'))
delete(fullfile(fileparts(dicomRewritten), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomRewritten), fileparts(dicomRewritten)));

delete(fullfile(fileparts(dicomModified), '*.nii'))
delete(fullfile(fileparts(dicomModified), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomModified), fileparts(dicomModified)));



%% Visualize and summarize results
% Run1 vs run 2 original
% freeview sub-vsmDrivenP3/004-MEMP_4e_p3_hiBW_TR3500_TI1300_RMS_MEMP_4e_p3_hiBW_TR3500_TI1300_20241008161209_4.nii sub-vsmDrivenP3/013-vfMRI_fl3d_p4xp4x1p2_1e/orig/orig_vfMRI_fl3d_p4xp4x1p2_1e_20241008161209_13.nii sub-vsmDrivenP3/037-vfMRI_fl3d_p4xp4x1p2_1e/orig/orig_vfMRI_fl3d_p4xp4x1p2_1e_20241008161209_37.nii
% The two slices are not aligned. That is normal because the head position changed from run one to run 2 and autoalign correctly adjusted slice prescription to follow the head.

% Run1 original vs rewritten
% freeview sub-vsmDrivenP3/004-MEMP_4e_p3_hiBW_TR3500_TI1300_RMS_MEMP_4e_p3_hiBW_TR3500_TI1300_20241008161209_4.nii sub-vsmDrivenP3/013-vfMRI_fl3d_p4xp4x1p2_1e/orig/orig_vfMRI_fl3d_p4xp4x1p2_1e_20241008161209_13.nii sub-vsmDrivenP3/013-vfMRI_fl3d_p4xp4x1p2_1e/rewritten/rewritten_vfMRI_fl3d_p4xp4x1p2_1e_20241008161209_13.nii
% freeview sub-vsmDrivenP3/013-vfMRI_fl3d_p4xp4x1p2_1e/orig/orig_vfMRI_fl3d_p4xp4x1p2_1e_20241008161209_13.nii sub-vsmDrivenP3/013-vfMRI_fl3d_p4xp4x1p2_1e/rewritten/rewritten_vfMRI_fl3d_p4xp4x1p2_1e_20241008161209_13.nii
% In the rewritten file, we replaced the image orientation and position with that is computed from some values found deeper in the dicom header (CSA MrPheonixProtocol) which I think correspond to the slice prescription (used by the scanner, not by dcm2niix for the nifti creation).
% If we did this right, the rewritten file should align perfectly with the original one. They do not perfectly align... But kind of close (mostly inplane rotation and x y translation errors)

% Run1 vs run 2 modified
% freeview sub-vsmDrivenP3/004-MEMP_4e_p3_hiBW_TR3500_TI1300_RMS_MEMP_4e_p3_hiBW_TR3500_TI1300_20241008161209_4.nii sub-vsmDrivenP3/013-vfMRI_fl3d_p4xp4x1p2_1e/modified/modified_vfMRI_fl3d_p4xp4x1p2_1e_20241008161209_13.nii sub-vsmDrivenP3/037-vfMRI_fl3d_p4xp4x1p2_1e/modified/modified_vfMRI_fl3d_p4xp4x1p2_1e_20241008161209_37.nii
% Here the dicom are also modified but this time using slice prescription info that I think correspond to the slice prescription before autoalign.
% Here if we are right, run1 and run2 should be aligned. The orientation seems the same but not the position...
