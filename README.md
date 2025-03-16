# LAMP

The scripts contained in this repository allow to reproduce analyses, results and figures from the publication *Shedding light on changes in subjective experience during an intensive contemplative retreat: the Lyon Assessment of Meditation Phenomenology (LAMP) questionnaire* in Biological Psychiatry Global Open Science ([link to open access publication](10.1016/j.bpsgos.2025.100474)).

To reproduce everything:

1. download the scripts
2. create a folder called `data` in the folder containing the scripts.
3. download the [data from OSF](https://osf.io/4wbk3/) and save it in `data`
4. Execute the .qmd file

The Quarto document contains all analyses, including code for figures. It sources the code from auxilliary R scripts:
- `load_data.R` loads the different types of data: phenomenological (LAMP data), psychometric and lifetime practice
- `load_variables.R` loads R objects describing the phenomenological dimensions
- `fun_gamm.R` provides functions for fitting, and extracting information from, generalized additive mixed models
- `fun_gbmt.R` provides functions for fitting and plotting the goodness-of-fit of group-based (multivariate) trajectory models
