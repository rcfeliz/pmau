# prep --------------------------------------------------------------------
# tem que instalar o Java antes de baixar as coisas no R
# install.packages("rJava")
# remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))


# lista os pdfs -----------------------------------------------------------

planos_de_acao <- fs::dir_ls("data-raw/pmau_planos_de_acao/")


# extrai as tabelas dos pdfs ----------------------------------------------

mat <- planos_de_acao[1] |>
  tabulapdf::extract_tables(pages=1) |>
  purrr::pluck(1)

# clean -------------------------------------------------------------------

row_split <- function(x, rows) {
  lapply(rows, \(r) {
    if(length(r) == 1) return(matrix(x[r, ], nrow = 1))
    x[r, ]
  })
}

col_paste <- function(x, ...) {
  apply(x, 2, \(y) {as.vector(paste(y, ...))})
}

row_combine <- function(x, ...) {
  matrix(unlist(x), nrow = length(x), byrow = TRUE)
}

groups <- list(1:2, 4:10, 11:28, 29:39)

dat <- mat |>
  dplyr::mutate(
    dplyr::across(
      everything(),
      ~tidyr::replace_na(.x, "\n")
    )
  ) |>
  row_split(groups) |>
  purrr::map(\(x) {col_paste(x, collapse = " ")}) |>
  row_combine() |>
  tibble::as_tibble() |>
  dplyr::mutate(
    dplyr::across(
      everything(),
      ~stringr::str_squish(.x)
    )
  ) |>
  janitor::row_to_names(row_number = 1) |>
  janitor::clean_names() |>
  tidyr::unite(col = competencia, secretaria_setor_responsavel, x, sep = ", ") |>
  dplyr::mutate(
    competencia = stringr::str_replace_all(competencia, " e ", ", ")
  )

