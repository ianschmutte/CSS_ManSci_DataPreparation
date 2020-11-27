# External files and resources for preparation of the IRAIS research database

25 November 2020
Ian M. Schmutte
`schmutte@uga.edu`

This folder contains `cnae20_xwalk10x20_preferred.sas7bdat` which provides a concordance between different versions of the industrial classification scheme (CNAE) used by Brazil's statistical agencies.

The raw data are from an Excel file retrieved from [https://cnae.ibge.gov.br/estrutura/atividades-economicas-estrutura/cnae] on October 16, 2018.

* `CNAE20_Correspondencia20x10.xls` contains the concordance mapping CNAE 2.0 codes into 1.0 codes

The sas7bdat is based on a hand-converted version of the above with three variables:

* CNAE1
* CNAE2
* PREFERRED

For example, the CNAE 1.0 to 2.0 concordance has one entry for each CNAE 1.0 code together with the different possible CNAE 2.0 that correspond to the kinds of industrial activity previously grouped under that single CNAE 1.0 code. The variable PREFERRED = "X" to indicate which of the associated 2.0 codes contains the majority of industrial output previously in the CNAE 1.0 code.
