
# Overview of a TPMA review

The purpose of each TPMA review is to consider if existing TPMA should be 
updated or new TPMA should be created. After conducting analyses, 
recommendations are made to the NHP board and decisions made to either adopt the
changes or not. The analyses and recommendations will be shared either way.

# Repo contents

The repo has the typical files (README, LICENSE, …) of a git repo, but to help 
with navigation, the below gives an overview of the other files:

Folders:

- `_freeze`- to store the latest renders of quarto files.
- `databricks` - for the databricks workbooks. Can have as many as needed for a 
TPMA review.
- `img` - to store images.
- `R` - to store R functions that can be used across quarto files. These 
functions should be usable for most TPMA reviews and are to help standardise 
outputs.
- `reference_data` - for reference data files.

Files:

- `_targets.R` for the targets.
- `*.qmd` and `_quarto.yml` are used to create the book.
- `deploy.R` is a short script to render the book and deploy it to our Posit 
connect server. There is code to publish the dev version (for the project team, 
works in progress only) or the live version (public facing, so 
completed/signed off work only).

For more information on quarto books and freeze see: 
<https://connect.strategyunitwm.nhs.uk/standardising_data_analytical_code/contributing.html#sec-contributing-quarto-books>.

# Suggested steps for a TPMA review

1. Create an issue using the `TPMA review - issue template`. This includes a 
list of some of the likely tasks to complete for a TPMA review and can be
amended/updated as necessary. Use sub-issues so they are linked. Remember to tag 
each issue as part of the TPMA Review Project 
(<https://github.com/orgs/The-Strategy-Unit/projects/30>).

1. Work on your issues in branches before merging into main.

1. Start a databricks workbook. Since TPMA code may be incorporated into the NHP
model, it is important to try to use existing functions and methods already in 
the model. So, recommend that TPMA wrangling is done in databricks in pyspark 
and using functions from the `nhp_data` package where possible.
    - Existing TPMA code: <https://github.com/The-Strategy-Unit/nhp_data/tree/28e223627090c5ec49d54b2d4d0a8f34ea39be1a/src/nhp/data/raw_data/mitigators>.
    - Previous TPMA reviews: <https://github.com/The-Strategy-Unit/nhp_tpma_review/tree/main/databricks>.

1. After wrangling TPMA data in databricks, aggregated data can be written to 
Azure at: `StrategyUnit/StrategyUnit/analytics_modelling/nhp_tpma_review/`. 
Please use a separate folder for each TPMA review.

1. Create a new quarto file for your new chapter. Remember to add it to 
`_quarto.yml` so it'll appear when the book is rendered. TPMA reviews will vary
in content, but there will be some overlap. So in the `R` folder, there are some
functions that can be used across TPMA reviews to standardise outputs. Also, 
recommend moving R wrangling to targets where possible. This'll reduce the code 
that is run every time the book is rendered.

1. When committing changes, do also commit the files in the `freeze` folder. 
This'll reduce the number of chapters that are run every time the book is 
rendered.

1. Deploy the report using the code in `deploy.R`. There is a dev version you 
can deploy to any time for sharing outputs with the project team. When the 
report is ready to go live, deploy to the live version.

1. If the recommendation from the NHP board is to incorporate the changes into 
the NHP model, after analyses are complete, create a handover resource for data 
science to work from. Start with your databricks workbook for the TPMA wrangling 
and strip out what's not needed. Add an overview of the TPMA review, including a
summary of the new TPMA code and a link to the TPMA review. For examples see 
previous TPMA handover workbooks at: 
<https://github.com/The-Strategy-Unit/nhp_tpma_review/tree/main/databricks>.
