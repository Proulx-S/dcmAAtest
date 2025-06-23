clear all
close all

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


dicomOriginal  = fullfile(pwd, 'sub-vsmDrivenP3/013-vfMRI_fl3d_p4xp4x1p2_1e/orig/oneFrame.dcm')
dicomRewritten = modifyDicomCoordinates(dicomOriginal, targetFieldsRewrite, 'rewritten')
dicomModified  = modifyDicomCoordinates(dicomOriginal, targetFieldsModify , 'modified' )


delete(fullfile(fileparts(dicomOriginal), '*.nii'))
delete(fullfile(fileparts(dicomOriginal), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomOriginal), fileparts(dicomOriginal)));

delete(fullfile(fileparts(dicomRewritten), '*.nii'))
delete(fullfile(fileparts(dicomRewritten), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomRewritten), fileparts(dicomRewritten)));

delete(fullfile(fileparts(dicomModified), '*.nii'))
delete(fullfile(fileparts(dicomModified), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomModified), fileparts(dicomModified)));






dicomOriginal  = fullfile(pwd, 'sub-vsmDrivenP3/037-vfMRI_fl3d_p4xp4x1p2_1e/orig/oneFrame.dcm')
dicomRewritten = modifyDicomCoordinates(dicomOriginal, targetFieldsRewrite, 'rewritten')
dicomModified  = modifyDicomCoordinates(dicomOriginal, targetFieldsModify , 'modified' )


delete(fullfile(fileparts(dicomOriginal), '*.nii'))
delete(fullfile(fileparts(dicomOriginal), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomOriginal), fileparts(dicomOriginal)));

delete(fullfile(fileparts(dicomRewritten), '*.nii'))
delete(fullfile(fileparts(dicomRewritten), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomRewritten), fileparts(dicomRewritten)));

delete(fullfile(fileparts(dicomModified), '*.nii'))
delete(fullfile(fileparts(dicomModified), '*.json'))
system(sprintf('dcm2niix -o "%s" "%s"', fileparts(dicomModified), fileparts(dicomModified)));




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
