#### 100_prisma_flow.R ####
#### Purpose: generate PRISMA 2020 flow diagram (black & white, publication-ready) ####
####
#### Input : prisma_flow data frame loaded by 01_read_data.R
####          (read from data/data.xlsx, sheet "PRISMA_Flow")
#### Output: figures/PRISMA_flow.pdf  (vector, preferred for thesis)
####         figures/PRISMA_flow.png  (300+ dpi raster fallback)
####
#### Numbers come from the Excel sheet — Excel is the single source of truth.
#### To update: edit data.xlsx, re-run 01_read_data.R, then re-source this file.

#### 1. Load setup and data ####
source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/00_setup.R")
source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/01_read_data.R")

# Additional packages needed only for diagram rendering
extra_pkgs <- c("DiagrammeR", "DiagrammeRsvg", "rsvg")
for (p in extra_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
  library(p, character.only = TRUE)
}


#### 2. Extract numbers from prisma_flow data frame ####
# After janitor::clean_names() the columns are `stage` and `n`.
# get_n(): pulls the n value matched by a regex against the stage label.
get_n <- function(pattern) {
  row <- prisma_flow[grepl(pattern, prisma_flow$stage, ignore.case = TRUE), ]
  if (nrow(row) == 0) stop("Pattern not found in PRISMA_Flow: ", pattern)
  as.integer(gsub("\\D.*$", "", as.character(row$n[1])))
  # gsub("\\D.*$", "", x): strips trailing non-digit content, e.g. "16  (= 15 + 1)" -> "16"
}

n_total       <- get_n("^Total records identified$")
n_dup         <- get_n("^Duplicates removed$")
n_after_dedup <- get_n("^Records after deduplication$")
n_ta_screened <- get_n("^Title/Abstract screened$")
n_ta_excl     <- get_n("^Excluded at Title/Abstract$")
n_ft_sought   <- get_n("^Full-text assessed$")    # same n is used for "sought" and "assessed"
n_ft_assessed <- n_ft_sought
n_ft_excl     <- get_n("^Excluded at Full-text$")
n_incl        <- get_n("^Studies included in meta-analysis$")  # parses 16 from "16  (= 15 + 1)"
n_cite_added  <- 1                                              # one study from backward citation searching
n_incl_reports <- 20                                            # report-level count (kept here; not in sheet)


#### 3. Parse E-code exclusion reasons from the same sheet ####
# Match rows whose stage looks like "  - E1: ...", capturing the E-code and short label.
ecode_rows <- prisma_flow[grepl("^\\s*-\\s*E\\d+", prisma_flow$stage), ]
ecode_rows$n <- suppressWarnings(as.integer(ecode_rows$n))

# Short labels for the diagram (Excel labels are too long to fit in a box)
short_labels <- c(
  E1  = "Not RCT",
  E2  = "Age outside 10\u201319",
  E3  = "Not CBT / lacks CR + behavioural",
  E4  = "Guided intervention",
  E5  = "Depression not primary / no cutoff",
  E6  = "Active comparator",
  E7  = "Insufficient data for effect size",
  E8  = "Conference abstract or protocol",
  E9  = "Comorbid condition confounds outcome",
  E10 = "Limited generalisability",
  E11 = "Duplicate publication",
  E12 = "Full text unavailable",
  E13 = "Registered trial, no outcome data"
)

# Extract E-code key (e.g. "E4") from each stage string
ecode_rows$key <- sub("^.*?(E\\d+).*$", "\\1", ecode_rows$stage)
ecode_rows$label <- short_labels[ecode_rows$key]

# Drop reasons with n = 0 (cleaner diagram)
ecode_rows <- ecode_rows[ecode_rows$n > 0, ]

excl_lines <- paste0(
  "   \u2022 ", ecode_rows$label, " (", ecode_rows$key, "): n = ", ecode_rows$n,
  "\\l", collapse = ""
)

# Sanity check: parsed E-code total must match the headline n_ft_excl
stopifnot(sum(ecode_rows$n) == n_ft_excl)


#### 4. Build DOT graph ####
dot <- sprintf('
digraph PRISMA {
  graph [layout = dot, rankdir = TB, splines = ortho, nodesep = 0.35, ranksep = 0.5,
         compound = true]
  node  [shape = box, style = "filled,solid", fillcolor = white, color = black,
         fontname = "Helvetica", fontsize = 10, margin = "0.18,0.12"]
  edge  [color = black, arrowhead = normal, arrowsize = 0.7]

  // ---- Section labels (left column, plaintext) ----
  ident   [label = "Identification", shape = plaintext, fontsize = 12, fontname = "Helvetica-Bold"]
  screen  [label = "Screening",      shape = plaintext, fontsize = 12, fontname = "Helvetica-Bold"]
  incl    [label = "Included",       shape = plaintext, fontsize = 12, fontname = "Helvetica-Bold"]

  // ---- Identification ----
  rec     [label = "Records identified from databases\\n(n = %d)\\nPubMed, Embase, Cochrane CENTRAL,\\nAPA PsycArticles", width = 3.4]
  dup     [label = "Records removed before screening:\\nDuplicate records removed (n = %d)", width = 3.4]

  // ---- Screening ----
  ta      [label = "Records screened\\n(n = %d)", width = 3.4]
  ta_x    [label = "Records excluded at title/abstract\\n(n = %d)", width = 2.8]
  ft_s    [label = "Reports sought for retrieval\\n(n = %d)", width = 3.4]
  ft_a    [label = "Reports assessed for eligibility\\n(n = %d)", width = 3.4]
  ft_x    [label = "Reports excluded (n = %d):\\l%s", width = 3.6]

  // ---- Citation search ----
  cite    [label = "Studies identified via\\nbackward citation searching\\n(n = %d)", width = 2.6]

  // ---- Included ----
  final   [label = "Studies included in meta-analysis\\n(n = %d studies / %d reports)", width = 3.4]

  // ---- Layout: align section headers with main column ----
  { rank = same; ident;  rec   }
  { rank = same; screen; ta    }
  { rank = same; incl;   final }

  // Invisible spine to keep section labels stacked on the left
  ident -> screen -> incl [style = invis]

  // ---- Edges: main vertical flow ----
  rec  -> dup
  dup  -> ta
  ta   -> ta_x
  ta   -> ft_s
  ft_s -> ft_a
  ft_a -> ft_x
  ft_a -> final
  cite -> final
}
',
n_total, n_dup,
n_ta_screened, n_ta_excl,
n_ft_sought, n_ft_assessed, n_ft_excl, excl_lines,
n_cite_added,
n_incl, n_incl_reports
)


#### 5. Render and export ####
g <- DiagrammeR::grViz(dot)
svg_code <- DiagrammeRsvg::export_svg(g)

fig_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

rsvg::rsvg_pdf(charToRaw(svg_code), file = file.path(fig_dir, "PRISMA_flow.pdf"), width = 1600)
rsvg::rsvg_png(charToRaw(svg_code), file = file.path(fig_dir, "PRISMA_flow.png"), width = 2400)

cat("100_prisma_flow.R completed successfully.\n",
    "  ->", file.path(fig_dir, "PRISMA_flow.pdf"), "\n",
    "  ->", file.path(fig_dir, "PRISMA_flow.png"), "\n