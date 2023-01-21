# Ketamine-FEET-Mediation

This repo contains steps to run mediation analysis between brain activation in response to Facial Expressions of Emotion Task (FEET) and altered states of consciousness after acute ketamine administration.

## High-level steps
- [data preprocessing and preparation](###-data-preprocessing-and-preparation)
  - [fMRI data](####-fmri-data)
  - [CADSS and 5D-ASC](####-cadss-and-5d-asc)
- [data analysis](###-data-analysis)
  - [fMRI Analysis of Variance (ANOVA)](####-fmri-analysis-of-variance-(anova))
  - [Linear mixed model analysis for CADSS and 5D-ASC](####-linear-mixed-model-analysis-for-cadss-and-5d-asc)
  - [Mediation analysis](####-mediation-analysis)
  

### data preprocessing and preparation
#### fMRI data
1. Preprocessing: results included in this paper come from preprocessing performed using fMRIPrep 20.2.3, details can be found [here](https://github.com/WilliamsPanLab/Ketamine-FEET-Mediation/blob/5d5a29331a3e20494244e72c544fee06472ac069/neuroimaging_preprocessing.md).

2. Quality control: Quality control diagnostics included visual inspection of the raw fMRI timeseries for artifacts and signal dropout, and a review of the fMRIprep summary report for each participant. Participants’ data were excluded if more than 25% (37/148) of time points were detected as motion spikes. Volumes with frame-wise displacement >0.5 mm or std DVARS >1.5 are defined as motion spikes. One participant’s data for the 0.05 mg/kg was excluded. One participant was not able to complete brain scans due to nausea under the 0.5 mg/kg condition. One participant was unreachable after the completion of the first two scan visits (placebo and 0.5 mg/kg) and is missing the 0.05 mg/kg data. This resulted in n = 13, 11, and 12 for placebo, 0.05mg/kg and 0.5mg/kg conditions, respectively.

3. Definition of region of interest (ROI): As established in our previous work, we defined ROIs with an automated meta-analysis approach using neurosynth.org. Specifically, we used Neurosynth uniformity (previously called forwardinference) maps with a false discovery rate (FDR) threshold of .01 for the search terms of anterior insula and amygdala. We imposed a restriction that the peak of the ROIs should have a minimum z-score of 6. For the anterior insula, we also excluded voxels with a z-score <5 to keep only the most relevant voxels spatially located in the anterior portion of the insula via visual inspection. For the amygdala, neurosynth maps were restricted by anatomically defined boundaries from the Automated Anatomical Labeling atlas. The established ROIs can be found [here](https://github.com/WilliamsPanLab/2021-masks).








#### CADSS and 5D-ASC

### data analysis
#### fMRI Analysis of Variance (ANOVA)

#### Linear mixed model analysis for CADSS and 5D-ASC

#### Mediation analysis




