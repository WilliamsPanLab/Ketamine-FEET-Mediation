# Ketamine-FEET-Mediation

This repo contains steps to run mediation analysis between brain activation in response to Facial Expressions of Emotion Task (FEET) and altered states of consciousness after acute ketamine administration.

## High-level steps
- [Pre-requisite](###pre-requisite)
- [data preprocessing and preparation](###-data-preprocessing-and-preparation)
  - [fMRI data](####-fmri-data)
  - [CADSS and 5D-ASC](####-cadss-and-5d-asc)
- [data analysis](###-data-analysis)
  - [fMRI Analysis of Variance (ANOVA)](####-fmri-analysis-of-variance-(anova))
  - [Linear mixed model analysis for CADSS and 5D-ASC](####-linear-mixed-model-analysis-for-cadss-and-5d-asc)
  - [Mediation analysis](####-mediation-analysis)
  
### Pre-requisite
#### Hardware requirements
All stpes could be done on a standard research computer with reasonable CPUs and RAM. Except that the preprocessing was done on high performance cluster based on the recommendations from [fmriprep](https://fmriprep.org/en/stable/faq.html#how-much-cpu-time-and-ram-should-i-allocate-for-a-typical-fmriprep-run).

#### Software requirements

##### OS requirements

the analysis was conducted and only tested for running on macOS Mojave (10.14.1) and Monterey (12.2.1).

##### Softwares
- [Matlab_R2020b](https://www.mathworks.com/products/new_products/release2020b.html) for neuroimaging analysis
  -  Matlab dependencies: [SPM8](https://www.fil.ion.ucl.ac.uk/spm/software/spm8/), [DPABI_V6.0_210501](http://rfmri.org/content/dpabi-v60-and-dpabinet-v10-were-released).
- [R version 4.0.5](https://www.r-project.org/) for non-neuroimaging analysis and mediation analysis
  - R dependencies: rio, ggplot2, lme4, tidyverse, sjPlot, coefplot2, performance, see, broom.mixed, kableExtra, janitor, ggeffects, dplyr, gridExtra, qqplotr, emmeans, pbkrtest, knitr,ggpubr, here, table1, psych, broom,lsr, rstatix, formatR, RVAideMemoire, labelled, cowplot, readr, svglite, rmcorr, cowplot, grid, gtable, RColorBrewer, extrafont, corrplot, grDevices,icesTAF, gganimate, lmerTest


### data preprocessing and preparation
#### fMRI data
1. Preprocessing: [fmriprep-20.2.3.job](https://github.com/WilliamsPanLab/Ketamine-FEET-Mediation/blob/b1ee4f796c71b1707de6bc68edbf99c3c6c7ff38/fmri/Preprocessing/fmriprep-20.2.3.job)

Results included in this paper come from preprocessing performed using fMRIPrep 20.2.3, details can be found [here](https://github.com/WilliamsPanLab/Ketamine-FEET-Mediation/blob/5d5a29331a3e20494244e72c544fee06472ac069/neuroimaging_preprocessing.md).

2. Quality control: [summarizing_motion_spikes](https://github.com/WilliamsPanLab/Ketamine-FEET-Mediation/blob/b1ee4f796c71b1707de6bc68edbf99c3c6c7ff38/fmri/summarizing_motion_spikes.m)
Quality control diagnostics included visual inspection of the raw fMRI timeseries for artifacts and signal dropout, and a review of the fMRIprep summary report for each participant. Participants’ data were excluded if more than 25% (37/148) of time points were detected as motion spikes. Volumes with frame-wise displacement >0.5 mm or std DVARS >1.5 are defined as motion spikes. One participant’s data for the 0.05 mg/kg was excluded. One participant was not able to complete brain scans due to nausea under the 0.5 mg/kg condition. One participant was unreachable after the completion of the first two scan visits (placebo and 0.5 mg/kg) and is missing the 0.05 mg/kg data. This resulted in n = 13, 11, and 12 for placebo, 0.05mg/kg and 0.5mg/kg conditions, respectively.

3. Definition of region of interest (ROI): As established in our previous work, we defined ROIs with an automated meta-analysis approach using neurosynth.org. Specifically, we used Neurosynth uniformity (previously called forwardinference) maps with a false discovery rate (FDR) threshold of .01 for the search terms of anterior insula and amygdala. We imposed a restriction that the peak of the ROIs should have a minimum z-score of 6. For the anterior insula, we also excluded voxels with a z-score <5 to keep only the most relevant voxels spatially located in the anterior portion of the insula via visual inspection. For the amygdala, neurosynth maps were restricted by anatomically defined boundaries from the Automated Anatomical Labeling atlas. The established ROIs can be found [here](https://github.com/WilliamsPanLab/2021-masks).

4. Generating activation maps: Preprocessed data were entered into a general linear model at the individual level using [SPM8](https://www.fil.ion.ucl.ac.uk/spm/software/spm8/). Each block of emotional expressions was convolved with a canonical hemodynamic response function, and the blocks were used as regressors in the general linear model, as were motion spikes. Activation maps for threat (fear and anger facial expressions) relative to neutral faces, and for happy relative to neutral faces, were estimated to examine ketamine-induced brain activity change in response to negative and positive emotions.


#### CADSS and 5D-ASC
Addressing data missingness: for each subject’s questionnaire data under a certain dose condition, if the missing items were fewer than 10% of the total item numbers of the questionnaire, we replaced missing items with the group mean of that dose condition. This brought the sample size of CADSS to be n = 13, n = 12, n = 13 for placebo, 0.05 mg/kg, and 0.5 mg/kg and of 5D-ASC to be n = 13 for all three drug visits.


### data analysis
#### fMRI Analysis of Variance (ANOVA)

To examine our second objective to test the dose-dependent effects of ketamine on brain activity in response to emotional expressions, we conducted a one-way repeated Analysis of Variance in SPM — with dose as the within-participant factor — on the activation maps for threat faces (consisting of both anger and fear faces) relative to neutral faces, and happy faces relative to neutral faces. Based on the pre-specified primary focus of anterior insula and amygdala neural targets, we constrained our voxel-wise analysis using masks consisting of bilateral anterior insula and amygdala. Conducting within-region voxel-wise analyses instead of deriving an average value per region of interest (ROI) enabled us to focus on the ROIs while still obtaining precision in detecting which part within the region is showing an effect. The definition for ROIs of anterior insula and amygdala was established in our previous work. To correct for multiple comparisons, a voxel threshold of p < 0.001 and a Gaussian random field theory (GRF) family-wise error (FWE) cluster-level correction at p < 0.05 was applied. For clusters that survived multiple comparison corrections, we extracted the peak voxel activation (fMRI beta estimate) for all three conditions and conducted planned contrasts using paired t-tests between each pair of dose conditions, as we did with the ASC data.



#### Linear mixed model analysis for CADSS and 5D-ASC
To examine dose-dependent effects of ketamine on CADSS-assessed subcomponents of dissociation and 5D-ASC-assessed other ASCs, we used linear mixed effects models (LMMs) with dose (placebo, 0.05mg/kg or 0.5mg/kg) as the fixed effect and participant as a random effect using the lmer package (https://cran.r-project.org/web/packages/lme4/index.html) in R. Time and dose-by-time interaction were added if applicable (Suppl. Methods). Age and biological sex were included as covariates. We implemented an FDR correction to control for the testing of multiple scale sub-components. For significant dose-dependent effects, post-hoc paired t-tests were also run to compare 0.5 mg/kg versus placebo, 0.05 mg/kg versus placebo, and 0.5 mg/kg versus 0.05 mg/kg, to reveal which drug dose condition drove the effect.


#### Mediation analysis
To address our third objective — to test whether specific aspects of ketamine-induced dissociation and other ASCs mediate the effect of dose on acute changes in neural activity during emotional processing — we utilized the Averaged Causal Mediation Effect mediation model because it is powerful for understanding mechanisms of action with dose as the independent variable (0.5mg/kg versus placebo, the X variable), altered states as the mediators (the M variables), and the neural activity of the anterior insula and amygdala in response to emotional faces as the dependent variables (the Y variables). To test our working hypothesis that ketamine will reduce neural activity reflecting relief of negative affective states, mediators included depersonalization and derealization from the CADSS and blissful state from the 5D-ASC. To test our working hypothesis that ketamine will increase neural activity reflecting exacerbation of negative affective states, mediators included dissociative amnesia from the CADSS, as well as anxiety and impaired control and cognition from the 5D-ASC. Mediation models were implemented using the [mediation package](https://cran.r-project.org/web/packages/mediation/index.html) combined with the [lmer package](to add!!!).




