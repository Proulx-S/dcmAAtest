# Better header information for MRI acquired using Siemens' Auto-Align
starts exploring doIt.m
## Background: Auto-Align counteracts head pose changes during a long scanning session
When using Siemens' Auto-Align (AA), the prescription of each run is adjusted to follow head pose changes. This is great to maintain restricted fov (e.g. single-slice) acquisitions on the same piece of brain during a long scanning session or across sessions.
In the example below, we see the head moving across runs (grayscale head scouts) and the Auto-Aligned acquisition (colorscale single-slice) following that movement.

<img width="300" alt="sctNfunSagCrop" src="https://github.com/user-attachments/assets/224dd2b6-dfe8-4a18-b650-ef9a08d2e85d" />

## Problem: Visualization (and registration) of multiple auto-aligned images is difficult due to different scanner-space coordinates
One usually overlay function images (two single-slice images each from a different auto-aligned run, in color below) on top of a reference anatomical image (grayscale image below).

<img width="246" alt="Screenshot 2025-06-20 at 4 59 14 PM" src="https://github.com/user-attachments/assets/0953641c-cfac-4292-bd7f-b5ce4fbdcc13" />

Here the two slices appear out of register because auto-align indeed changed the slice prescription for each. We however know that the slice prescription change properly tracked the head. So for this overlay, we would want both slices to show in the same position. It has been surprisingly hard for me to acheive that! The workaround I use is to rewrite one of the single-slice image with the header of the other. That however failed if the two single-slice acquisitions have e.g. different voxel sizes.

## Toward a robust solution
I'm sure other hacks could work but I'm looking for a robust solution. Towards that, in this repo I tried to find auto-align related information in the dicom header and modify the header to "undo" auto-align and display the slice at the originally prescribed location.

### Auto-align information deep in the dicom header, in Siemens CSA MrPhoenixProtocol section
My best guess at slice prescription are those fields:<br>
'sSliceArray.asSlice[0].dInPlaneRot'<br>
'sSliceArray.asSlice[0].sPosition.dSag'<br>
'sSliceArray.asSlice[0].sPosition.dCor'<br>
'sSliceArray.asSlice[0].sPosition.dTra'<br>
'sSliceArray.asSlice[0].sNormal.dSag'<br>
'sSliceArray.asSlice[0].sNormal.dCor'<br>
'sSliceArray.asSlice[0].sNormal.dTra'<br>
I suspect this is slice prescription after auto-align transformation, but I am not sure.

Then these other fields:<br>
'sAAInitialOffset.SliceInformation.dInPlaneRot'<br>
'sAAInitialOffset.SliceInformation.sPosition.dSag'<br>
'sAAInitialOffset.SliceInformation.sPosition.dCor'<br>
'sAAInitialOffset.SliceInformation.sPosition.dTra'<br>
'sAAInitialOffset.SliceInformation.sNormal.dSag'<br>
'sAAInitialOffset.SliceInformation.sNormal.dCor'<br>
'sAAInitialOffset.SliceInformation.sNormal.dTra'<br>
appears to be the slice prescription "as prescribed", so before auto-align transformation. Again I am not sure. Note that these fields are not accessible with matlab dicominfo--I got them with dicm2nii toolbox.

### Reverse engineering AA slice prescription in dicom header
I suspect the sSliceArray.asSlice[0] is used to derive image orientation and position at the time of dicom creation, so recreating the dicom using sAAInitialOffset.SliceInformation fields instead would be a solution very close to the root. This is what this repo is attempting. If successful, the two single slices in the second picture should align perfectly.

## Preliminary results
The dicoms of the two different and independently auto-aligned runs, recreated using sAAInitialOffset.SliceInformation and converted to nifti with dcm2niix, now show very similar orientation but a large z position offset, so something is wrong. Recreating one of the dicom using sSliceArray.asSlice[0] should also align perfectly with the original dicom: they do algin very closely but show significant x and y offsets and inplace rotation.

So I am doing something wrong here. Note that I don't understant very well how spatial information is encoded, and that I heavily used AI (within Cursor) to generate that code, so no real surprise here.

## Help needed
I need help to figure this out. First step: robustly recover and display images at the orientation/position that was originally prescribed (not at the position it was acquired after AA adjustment). I would be happy with just that--I would just rewrite all my dicoms in matlab--but a more usable solution would be to dump the relevant information in the BIDS json sidecar file (https://github.com/bids-standard/bids-specification/discussions/2141) or have a flag in dcm2niix to specify whether you want your image at the originally prescribed or auto-aligned scanner-space location (https://github.com/rordenlab/dcm2niix/issues/944).

## Acknowledgment
Thanks to Simon Thalén and Carlos Castillo Passi for their insigth<br>
Thanks to the developper of dicm2nii (https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/e5a13851-4a80-11e4-9553-005056977bd0/c5ce193c-31e2-4149-ac28-c6d14a9bd6f4/packages/zip)
