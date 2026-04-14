## render_report.R — Render the final report
here::i_am("code/render_report.R")
rmarkdown::render(
  here::here("report", "final_report.Rmd"),
  output_dir = here::here("report")
)
