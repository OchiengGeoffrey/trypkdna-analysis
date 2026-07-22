# ============================================================
# Table 1: ATPase γ Mutation Matrix
# ============================================================

library(dplyr)
library(gt)
library(tibble)

# ------------------------------------------------------------
# Output directories
# ------------------------------------------------------------

dirs <- c(
  "01_comparative_genomics/outputs/tables",
  "00_manuscript/tables"
)

for (d in dirs) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# ------------------------------------------------------------
# Table data
# ------------------------------------------------------------

table1_data <- tribble(
  ~Strain,   ~Species,         ~kDNA_phenotype,     ~`262`, ~`273`, ~`281`,     ~`282`,
  "TREU927", "T. brucei",      "Retained",          "L",    "A",    "A",        "M",
  "OVI",     "T. equiperdum",  "Retained",          "L",    "A",    "A",        "M",
  "IVM-t1",  "T. equiperdum",  "Retained",          "L",    "A",    "A",        "M",
  "BoTat",   "T. equiperdum",  "Dyskinetoplastic",  "L",    "P",    "A",        "M",
  "STIB805", "T. evansi",      "Dyskinetoplastic",  "L",    "A",    "A281del",  "M",
  "MU09",    "T. evansi",      "Dyskinetoplastic",  "L",    "A",    "A281del",  "M",
  "RoTat",   "T. evansi",      "Dyskinetoplastic",  "L",    "A",    "A",        "M",
  "MU10",    "T. evansi",      "Dyskinetoplastic",  "L",    "A",    "A",        "M/L*"
)

# ------------------------------------------------------------
# Save CSV
# ------------------------------------------------------------

for (d in dirs) {

  write.csv(
    table1_data,
    file.path(d, "Table1_ATPase_gamma_mutation_matrix.csv"),
    row.names = FALSE
  )

}

# ------------------------------------------------------------
# Create gt table
# ------------------------------------------------------------

table1_gt <- table1_data %>%
  gt() %>%

  tab_header(
    title = md(
      "**ATPase γ amino acid states at residues associated with dyskinetoplasty**"
    )
  ) %>%

  tab_spanner(
    label = "ATPase γ Residue Position",
    columns = c(`262`, `273`, `281`, `282`)
  ) %>%

  cols_label(
    Strain = "Strain",
    Species = "Species",
    kDNA_phenotype = "kDNA phenotype",
    `262` = "262",
    `273` = "273",
    `281` = "281",
    `282` = "282"
  ) %>%

  cols_align(
    align = "left",
    columns = c(Strain, Species, kDNA_phenotype)
  ) %>%

  cols_align(
    align = "center",
    columns = c(`262`, `273`, `281`, `282`)
  ) %>%

  # A273P
  tab_style(
    style = list(
      cell_text(weight = "bold"),
      cell_fill(color = "#D6EAF8")
    ),
    locations = cells_body(
      columns = `273`,
      rows = `273` == "P"
    )
  ) %>%

  # A281del
  tab_style(
    style = list(
      cell_text(weight = "bold"),
      cell_fill(color = "#FADBD8")
    ),
    locations = cells_body(
      columns = `281`,
      rows = `281` == "A281del"
    )
  ) %>%

  # M282L heterozygous
  tab_style(
    style = list(
      cell_text(weight = "bold"),
      cell_fill(color = "#E8DAEF")
    ),
    locations = cells_body(
      columns = `282`,
      rows = `282` == "M/L*"
    )
  ) %>%

  tab_footnote(
    footnote =
      "MU10 carries a heterozygous M282L variant confirmed by VCF inspection and reference-guided consensus analysis.",
    locations = cells_body(
      columns = `282`,
      rows = Strain == "MU10"
    )
  ) %>%

  tab_options(
    table.border.top.width = px(2),
    table.border.bottom.width = px(2),
    column_labels.border.top.width = px(1),
    column_labels.border.bottom.width = px(1),
    heading.align = "left"
  )

# ------------------------------------------------------------
# Display
# ------------------------------------------------------------

print(table1_gt)

# ------------------------------------------------------------
# Save outputs
# ------------------------------------------------------------

for (d in dirs) {

  html_path <- file.path(d, "Table1_ATPase_gamma_mutation_matrix.html")
  png_path  <- file.path(d, "Table1_ATPase_gamma_mutation_matrix.png")
  pdf_path  <- file.path(d, "Table1_ATPase_gamma_mutation_matrix.pdf")

  # 1. Save HTML table first
  gtsave(table1_gt, html_path)

  # 2. Render PNG from the saved HTML file
  webshot2::webshot(
    url = html_path,
    file = png_path,
    selector = "table",
    zoom = 2,
    expand = 10
  )

  # 3. Render PDF from the saved HTML file
  webshot2::webshot(
    url = html_path,
    file = pdf_path,
    selector = "table",
    zoom = 2
  )

}

cat(
  "\nTable 1 successfully exported to:\n",
  paste(dirs, collapse = "\n"),
  "\n"
)