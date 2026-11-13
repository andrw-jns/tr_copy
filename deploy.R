# Code will render the book and then publish it:

# DEV version ------------------------------------------------------------------
# Shared only with project team:
quarto::quarto_publish_site(
  name = "nhp_tpma_review_dev",
  title = "nhp_tpma_review_dev",
  server = "connect.strategyunitwm.nhs.uk",
  render = "local"
)

# LIVE version -----------------------------------------------------------------
# Only to be run when want to publish for wider audience:
# (Has been commented out to prevent accidental publishing.)
# quarto::quarto_publish_site(
#   name = "nhp_tpma_review",
#   title = "nhp_tpma_review",
#   server = "connect.strategyunitwm.nhs.uk",
#   render = "local"
# )
