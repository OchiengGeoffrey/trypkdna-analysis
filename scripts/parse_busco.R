library(tidyverse)

# Path to BUSCO results
busco_dir <- "00_preflight/results/busco"

# Find all summary files recursively (your file is in ovi_busco/)
files <- list.files(busco_dir,
                    pattern = "short_summary.*\\.txt",
                    recursive = TRUE,
                    full.names = TRUE)

if (length(files) == 0) {
  stop("No BUSCO summary files found.")
}

# Function to parse BUSCO summary (handles percentages and counts)
parse_busco <- function(file) {
  text <- readLines(file)
  # Find the line starting with "C:"
  summary_line <- text[grepl("^C:", text)]
  
  # Extract numbers with percentages and counts
  # Example: "C:97.8%[S:97.7%,D:0.0%],F:0.5%,M:1.8%,n:5397"
  # Or older format without %: "C:97.8[S:97.7,D:0.0],F:0.5,M:1.8,n:5397"
  
  # Remove % signs if present
  cleaned <- gsub("%", "", summary_line)
  
  # Extract using regex
  # Pattern: C:(\d+\.?\d*).*S:(\d+\.?\d*).*D:(\d+\.?\d*).*F:(\d+\.?\d*).*M:(\d+\.?\d*).*n:(\d+)
  matches <- str_match(cleaned,
                       "C:([0-9.]+).*S:([0-9.]+).*D:([0-9.]+).*F:([0-9.]+).*M:([0-9.]+).*n:([0-9]+)")
  
  if (is.na(matches[1])) {
    # Try alternative format where numbers are counts inside brackets
    # Example: "C:97.8%[S:97.7%,D:0.0%],F:0.5%,M:1.8%,n:5397"
    # But the above regex should work. If not, fallback:
    matches <- str_match(cleaned,
                         "C:([0-9.]+).*S:([0-9.]+).*D:([0-9.]+).*F:([0-9.]+).*M:([0-9.]+).*n:([0-9]+)")
  }
  
  data.frame(
    Genome = gsub("_short_summary.*", "", basename(file)),
    Complete = as.numeric(matches[2]),
    Single = as.numeric(matches[3]),
    Duplicated = as.numeric(matches[4]),
    Fragmented = as.numeric(matches[5]),
    Missing = as.numeric(matches[6]),
    Total = as.numeric(matches[7])
  )
}

# Parse all files
busco_data <- bind_rows(lapply(files, parse_busco))

# Convert to percentages (if not already percentages)
# Our numbers are already percentages, but ensure they are ≤100
busco_pct <- busco_data %>%
  mutate(
    Single_pct = Single,
    Duplicated_pct = Duplicated,
    Fragmented_pct = Fragmented,
    Missing_pct = Missing
  )

# Reshape for plotting
busco_long <- busco_pct %>%
  select(Genome, Single_pct, Duplicated_pct, Fragmented_pct, Missing_pct) %>%
  pivot_longer(-Genome, names_to = "Category", values_to = "Percent")

# Clean category names for legend
busco_long <- busco_long %>%
  mutate(Category = recode(Category,
                           "Single_pct" = "Complete & single-copy (S)",
                           "Duplicated_pct" = "Complete & duplicated (D)",
                           "Fragmented_pct" = "Fragmented (F)",
                           "Missing_pct" = "Missing (M)"))

# Plot
p <- ggplot(busco_long, aes(x = Genome, y = Percent, fill = Category)) +
  geom_bar(stat = "identity", width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = c(
    "Complete & single-copy (S)" = "#4C72B0",
    "Complete & duplicated (D)" = "#55A868",
    "Fragmented (F)" = "#F1C40F",
    "Missing (M)" = "#E74C3C"
  )) +
  theme_minimal(base_size = 12) +
  labs(
    title = "BUSCO Assessment Results",
    subtitle = paste("Lineage: trypanosoma_odb12 |", nrow(busco_data), "genome(s)"),
    y = "Percentage (%)",
    x = "",
    fill = "Category"
  ) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"),
        axis.text.x = element_text(angle = 0, hjust = 0.5))

# Save plot to the same directory as the summary file
output_dir <- dirname(files[1])  # gets the directory containing the first summary file
ggsave(file.path(output_dir, "busco_plot.png"), p, width = 8, height = 5, dpi = 300)
ggsave(file.path(output_dir, "busco_plot.pdf"), p, width = 8, height = 5)

# Print to console
print(p)
cat("Plot saved to:", file.path(output_dir, "busco_plot.png"), "\n")
