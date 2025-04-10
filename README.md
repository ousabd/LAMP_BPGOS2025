# Description

This repository contains the scripts required to reproduce analyses, results and figures from the publication *Shedding light on changes in subjective experience during an intensive contemplative retreat: the Lyon Assessment of Meditation Phenomenology (LAMP) questionnaire* in Biological Psychiatry Global Open Science ([link to open access publication](10.1016/j.bpsgos.2025.100474)).

**Publication authors:** Oussama Abdoun, Arnaud Poublan, Stéphane Offort, Giuseppe Pagnoni, Antoine Lutz

**Script authors:** Oussama Abdoun, Arnaud Poublan

**Script maintainer:** Oussama Abdoun

# Steps

1. Download the scripts
2. Create a folder called `data` in the folder containing the scripts.
3. Connect to your OSF account and request access to the [dataset](https://osf.io/4wbk3/)
4. Download all data files and move them to the `data` folder created in step 1
5. Execute the .qmd file

# Files

The Quarto document contains all analyses, including code for figures. It sources the code from auxilliary R scripts:
- `load_data.R` loads the different types of data: phenomenological (LAMP data), psychometric and lifetime practice
- `load_variables.R` loads R objects describing the phenomenological dimensions
- `fun_gamm.R` provides functions for fitting, and extracting information from, generalized additive mixed models
- `fun_gbmt.R` provides functions for fitting and plotting the goodness-of-fit of group-based (multivariate) trajectory models
