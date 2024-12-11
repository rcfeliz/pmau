# install.packages("rJava")
# remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))

planos_de_acao <- fs::dir_ls("data-raw/pmau_planos_de_acao/")

planos_de_acao[1] |>
  tabulapdf::extract_tables()
