# SEMRICS
Spin-Echo MRI Contrast Simulator

This is a small GUI which will simulate acquisition-weighted spin-echo magnetic resonance images from Mo, T1 and T2 maps.

A short and self-explanatory user manual is attached.

Screenshots are included in the "Docs + Figures" directory.

## Installation
Clone this repo to a folder in your MATLAB workspace, browse to the folder containing SEMRICS.m, then modify the MATLAB path:

```addpath(genpath(pwd));```

```savepath;```

## Usage
From the MATLAB IDE, run the function:

```SEMRICS.m```

## The File menu
This has four entries:

```Open Data Set```

This reads in (anonymized) Mo, T1 and T2 maps from a pickled MAT file, calculates the weighted image at the current slice (in accordance with the parameters on the main screen) and displays the current slice.

```Save Results```

Options are single slices or stacks of the parameter maps, also of the weighted image, as well as a weighted-image DICOM stack.
Parameters are always saved by default. These are written to an XLSX file in a sub-folder of the Results directory corresponding to the currently selected data set.

```Import Parameters```

Read in the settings from an XLSX file and apply them to the current data set.

```Save Parameters```

As in "Save Results".

## Parameters
These are grouped together on the GUI.

- Each image displayed has windowing sliders and a choice of colormap.
- The current slice is selected with a slider.
- The image weighting is selected from a group of radio-buttons.
- The TR/TE sequence parameters are set from sliders; noise can also be added to the synthetic image.
- Various Export options may be selected.
- Captions may be written over the images, or disabled.

Note that all sliders are "live" and continuously responsive.




