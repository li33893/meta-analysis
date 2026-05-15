### 08_publication_bias.R 
# Small-study effects / publication bias (post-intervention only)
# Methods: contour-enhanced funnel plot, Egger's test,
#          Pustejovsky & Rodgers (2019), trim-and-fill


### 1. Load saved model ###

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"
figures_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/figures"

model_post <- readRDS(file.path(results_dir, "models", "model_post.rds"))

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/01_read_data.R")


### 2. Contour-enhanced funnel plot (only for console)###

col.contour <- c("gray75", "gray85", "gray95")

funnel(model_post,
       contour = c(0.9, 0.95, 0.99),  # 对应三条p值边界
       col.contour = col.contour,
       studlab = TRUE)


### 2. Egger's test (only for console)###
eggers <- metabias(model_post, method.bias = "Egger")
print(eggers)

### 3. Pustejovsky & Rodgers (2019) — actually this one would be enough, we save the egger's test code only for method clarity ###
pust <- metabias(model_post, method.bias = "Pustejovsky")
print(pust)


### 4. Trim-and-fill (only for console)###
tf <- trimfill(model_post)
summary(tf)


### 5. Define plot functions ###

draw_contour <- function() {
  funnel(model_post,
         xlim        = c(-1.5, 2),
         contour     = c(0.9, 0.95, 0.99),
         col.contour = col.contour,
         studlab     = TRUE,
         cex.studlab = 0.7)
  legend(x = 1.1, y = 0.01,
         legend = c("p < 0.10", "p < 0.05", "p < 0.01"),
         fill   = col.contour, bty = "n")
  title("Contour-Enhanced Funnel Plot (Post-intervention)")
}

draw_trimfill <- function() {
  funnel(tf,
         xlim        = c(-1.5, 2),
         contour     = c(0.9, 0.95, 0.99),
         col.contour = col.contour)
  legend(x = 1.1, y = 0.01,
         legend = c("p < 0.10", "p < 0.05", "p < 0.01"),
         fill   = col.contour, bty = "n")
  title("Trim-and-Fill Funnel Plot (Post-intervention)")
}


### 6. Save figures ###

png(file.path(figures_dir, "funnel_contour_post.png"),
    width = 2400, height = 2000, res = 300)
draw_contour()
dev.off()

png(file.path(figures_dir, "funnel_trimfill_post.png"),
    width = 2400, height = 2000, res = 300)
draw_trimfill()
dev.off()

cat("Publication bias diagnostics complete. Funnel plots saved to figures/\n")