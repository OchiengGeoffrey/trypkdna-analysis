# ============================================================
# Figure 1: ATPase γ Codon Phylogeny
# ============================================================

library(ape)
library(ggtree)
library(ggplot2)
library(treeio)

# ------------------------------------------------------------
# Create output directories if they do not exist
# ------------------------------------------------------------

dirs <- c(
  "01_comparative_genomics/outputs/figures",
  "00_manuscript/figures"
)

for (d in dirs) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# ------------------------------------------------------------
# Read IQ-TREE consensus tree
# ------------------------------------------------------------

tree <- read.tree(
  "01_comparative_genomics/results/tree/ATPase_gamma.contree"
)

# ------------------------------------------------------------
# Publication-friendly labels
# ------------------------------------------------------------

# Color scheme based on kDNA status
kDNA_colors <- c(
  "T. brucei TREU927 (WT)" = "#4CAF50",  # Kinetoplastic (Green)
  "T. equiperdum OVI (WT)" = "#FF9800",  # Dyskinetoplastic WT (Orange)
  "T. equiperdum IVM-t1 (WT)" = "#FF9800",  # Dyskinetoplastic WT (Orange)
  "T. evansi STIB805 (A281del)" = "#F44336",  # Akinetoplastic (Red)
  "T. evansi MU09 (A281del)" = "#F44336",  # Akinetoplastic (Red)
  "T. evansi RoTat (WT)" = "#4CAF50",  # Akinetoplastic (Red)
  "T. evansi MU10 (M282L*)" = "#9C27B0",  # Akinetoplastic Type B (Purple)
  "T. equiperdum BoTat (A273P)" = "#2196F3"   # Dyskinetoplastic escape (Blue)
)

tree$tip.label <- dplyr::recode(
  tree$tip.label,

  "T_brucei_TREU927" =
    "T. brucei TREU927",

  "T_equiperdum_BoTat" =
    "T. equiperdum BoTat (A273P)",

  "T_evansi_MU10" =
    "T. evansi MU10 (M282L*)",

  "T_equiperdum_IVMt1" =
    "T. equiperdum IVM-t1",

  "T_evansi_MU09" =
    "T. evansi MU09 (A281del)",

  "T_evansi_STIB805" =
    "T. evansi STIB805 (A281del)",

  "T_evansi_RoTat" =
    "T. evansi RoTat",

  "T_equiperdum_OVI" =
    "T. equiperdum OVI"
)

# ------------------------------------------------------------
# Generate figure
# ------------------------------------------------------------

p <- ggtree(tree, size=0.5) +

  geom_tiplab(
      size=3.4,
      fontface="bold.italic",
      offset=0.0008
  ) +

  geom_text2(
      aes(
        subset = !isTip & !is.na(as.numeric(label)),
      label = label
    ),
      nudge_x = -0.001,
      nudge_y = 0.18,
      size=3.2,
      fontface = "bold",
      color = "black"
  ) +

  # Prevent tip label clipping on the right boundary
  hexpand(0.45) +        # Adds 45% padding to the right x-axis
  coord_cartesian(clip = "off") +

  theme_tree2() +

  labs(
      title="ATP Synthase γ Codon Phylogeny",
      subtitle="IQ-TREE (KOSI07+FU+I), 1000 UFBoot replicates",
      x="Genetic distance (substitutions/site)"
  ) +

  theme(
      plot.title=element_text(face="bold",hjust=0.5),
      plot.subtitle = element_text(hjust = 0.5),
      plot.margin = margin(t = 10, r = 20, b = 10, l = 10,
      unit = "pt")
  )

# Display in interactive session
print(p)

# ------------------------------------------------------------
# Save figure to all output locations
# ------------------------------------------------------------

for (d in dirs) {

  ggsave(
    filename = file.path(d, "Figure1_ATPase_gamma_tree.pdf"),
    plot = p,
    width = 8,
    height = 6
  )

  ggsave(
    filename = file.path(d, "Figure1_ATPase_gamma_tree.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 600
  )
}

# ============================================================
# Generate figure caption
# ============================================================

caption <- "
FIGURE 1. ATP Synthase γ Subunit Phylogeny

Phylogenetic tree of ATPase γ codon sequences from eight Trypanosoma strains, 
inferred using IQ-TREE with the KOSI07+FU+I model and 1000 UFBoot replicates. 
Bootstrap support values are shown at internal nodes. Tip labels are color-coded 
by kDNA phenotype: green (kinetoplastic), orange (dyskinetoplastic with wild-type 
ATPase γ), blue (dyskinetoplastic with A273P escape mutation), red (akinetoplastic 
Type A with A281del), and purple (akinetoplastic Type B).

The alignment contained 290 constant sites and 7 parsimony-informative sites 
(ω = 0.202), indicating strong purifying selection. T. equiperdum OVI retains 
wild-type ATPase γ despite dyskinetoplasty, suggesting ATPase γ alone is 
insufficient to explain kDNA retention phenotypes.

*MU10 contains a heterozygous M282L variant in VCF data but retained M in the 
final consensus sequence.
"

writeLines(
  caption,
  "00_manuscript/figures/Figure1_caption.txt"
)

# ------------------------------------------------------------
# Finished
# ------------------------------------------------------------

cat("\nFigure successfully saved to:\n")

for (d in dirs) {
  cat(" -", file.path(d, "Figure1_ATPase_gamma_tree.pdf"), "\n")
  cat(" -", file.path(d, "Figure1_ATPase_gamma_tree.png"), "\n")
}

cat("\nNote: MU10 carries a heterozygous M282L variant (*).\n")