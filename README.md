# Better header information for MRI acquired using Siemens' Auto-Align
## Background: Auto-Align counteracts head pose changes during a long scanning session
When using Siemens' Auto-Align (AA), the prescription of each run is adjusted to follow head pose changes. This is great to maintain restricted fov (e.g. single-slice) acquisitions on the same piece of brain during a long scanning session or across session.
In the example below, we see the head moving across runs (grayscale head scouts) and the Auto-Aligned acquisition (colorscale single-slice) following that movement.
<img width="542" alt="image" src="https://github.com/user-attachments/assets/f8487856-8759-4b95-8e0d-1163db76d822" />

## Problem: Visualization (and registration) of multiple auto-aligned images is difficult due to different scanner-space coordinates
![Description](https://github.com/username/repo-name/raw/main/path/to/gif.gif)
