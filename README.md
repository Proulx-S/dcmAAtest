# Better header information for MRI acquired using Siemens' Auto-Align
## Background: Auto-Align counteracts head pose changes during a long scanning session
When using Siemens' Auto-Align (AA), the prescription of each run is adjusted to follow head pose changes. This is great to maintain restricted fov (e.g. single-slice) acquisitions on the same piece of brain during a long scanning session or across session.
In the example below, we see the head moving across runs (grayscale head scouts) and the Auto-Aligned acquisition (colorscale single-slice) following that movement.

![sctNfunSagCrop](https://github.com/user-attachments/assets/224dd2b6-dfe8-4a18-b650-ef9a08d2e85d){: width="400"}

## Problem: Visualization (and registration) of multiple auto-aligned images is difficult due to different scanner-space coordinates
One usually overlay function images (two single-slice images each from a different auto-aligned run, in color below) on top of a reference anatomical image (grayscale image below).

<img width="246" alt="Screenshot 2025-06-20 at 4 59 14 PM" src="https://github.com/user-attachments/assets/0953641c-cfac-4292-bd7f-b5ce4fbdcc13" />
Here the two slices appear out of register because auto-align indeed changed the slice prescription for each. We however know that the slice prescription change tracked the head, so we would want our visualization to reflect that.
