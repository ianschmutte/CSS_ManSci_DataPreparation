# Code to read and clean RAIS data prior to preparation for analysis

25 November 2020
Ian Schmutte
`schmutte@uga.edu`

The code in these folders reads the raw identified RAIS microdata provided by Brazil's MTE and cleans them in preparation for research. There are three assets here:

* `RAIS_rawdata_manifest.txt` lists the raw input text files received from MTE.
* `01_build_integrated_RAIS` contains code that reads the raw files into SAS-formatted datasets
* `02_IRAIS-research-database` contains code that cleans the SAS-formatted datasets produced by `01_build_integrated_RAIS`, processing them into a set of year-level match-specific and establishment-specific datasets. The code imposes some basic consistency requirements. It also generates a set of establishment- and worker-specific files that include characteristics that do not vary over time. Details are included in a README in this subfolder.

This code is provided for informational purposes as part of the replication archive. This archive has not been prepared to facilitate "button-press" replication. For assistance running this code, please contact Ian Schmutte (`schmutte@uga.edu).

## Basic Details

* `01_build_integrated_RAIS`
  * Inputs: raw text files listed in  `RAIS_rawdata_manifest.txt`
  * Outputs: `irais&yr..sas7bdat` for each year, 2002-2017
  * Notes:
    * Location of output files is controlled in a header file. See  `01_build_integrated_RAIS/README.md` for details.

* `02_IRAIS-research-database`
  * Inputs: `irais&yr..sas7bdat` for each year, 2002-2017
  * Outputs:
    * `rais_match_uniq_&year..sas7bdat` for each year 2002-2017
    * `rais_plant_uniq_&year..sas7bdat` for each year 2002-2017
    * `educ_best.sas7bdat`
    * `race_gender_age_best.sas7bdat`
