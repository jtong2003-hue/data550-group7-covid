## coder_a_demographics.R — Demographics and Comorbidity Profile
## Coder A: Lidong Yu
## Added by Lidong Yu for DATA550 assignment

here::i_am("code/coder_a_demographics.R")
source(here::here("code", "utils.R"))

config <- read_config()
df <- load_data(config)
df <- apply_filters(df, config)

# ── Table 1: Patient Demographics Summary ─────────────────────────────────────
demo_summary <- df %>%
  summarise(
    `Total Patients` = n(),
    `Mean Age` = round(mean(age, na.rm = TRUE), 1),
    `Median Age` = median(age, na.rm = TRUE),
    `Male (n)` = sum(sex == "Male", na.rm = TRUE),
    `Male (%)` = round(mean(sex == "Male", na.rm = TRUE) * 100, 1),
    `Female (n)` = sum(sex == "Female", na.rm = TRUE),
    `Female (%)` = round(mean(sex == "Female", na.rm = TRUE) * 100, 1)
  )

table_1 <- knitr::kable(demo_summary,
                         caption = "Table 1. Patient Demographics Summary")
saveRDS(table_1, here::here("output", "coder_a", "table_1.rds"))

# ── Figure 1: Age Distribution Histogram ──────────────────────────────────────
median_age <- df %>%
  group_by(sex) %>%
  summarise(med = median(age, na.rm = TRUE), .groups = "drop")

fig1 <- ggplot(df, aes(x = age, fill = sex)) +
  geom_histogram(binwidth = 5, position = "identity", alpha = 0.6) +
  geom_vline(data = median_age, aes(xintercept = med, color = sex),
             linetype = "dashed", linewidth = 1) +
  labs(title = "Figure 1. Age Distribution by Sex",
       x = "Age", y = "Count", fill = "Sex", color = "Median Age") +
  scale_x_continuous(breaks = seq(0, 100, 10)) +
  theme_covid()

ggsave(here::here("output", "coder_a", "fig1_age_distribution.png"),
       plot = fig1, width = 9, height = 5, dpi = 300)

# ── Figure 2: Comorbidity Prevalence Bar Chart ────────────────────────────────
comorbidity_cols <- c("diabetes", "copd", "asthma", "inmsupr",
                      "hipertension", "other_disease", "cardiovascular",
                      "obesity", "renal_chronic", "tobacco")

comorbidity_labels <- c(
  diabetes = "Diabetes", copd = "COPD", asthma = "Asthma",
  inmsupr = "Immunosuppression", hipertension = "Hypertension",
  other_disease = "Other Disease", cardiovascular = "Cardiovascular",
  obesity = "Obesity", renal_chronic = "Renal Chronic", tobacco = "Tobacco"
)

prev_df <- df %>%
  summarise(across(all_of(comorbidity_cols), ~mean(. == 1, na.rm = TRUE) * 100)) %>%
  pivot_longer(everything(), names_to = "comorbidity", values_to = "prevalence") %>%
  mutate(label = comorbidity_labels[comorbidity]) %>%
  arrange(prevalence)

prev_df$label <- factor(prev_df$label, levels = prev_df$label)

fig2 <- ggplot(prev_df, aes(x = label, y = prevalence)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Figure 2. Comorbidity Prevalence (%)",
       x = NULL, y = "Prevalence (%)") +
  theme_covid()

ggsave(here::here("output", "coder_a", "fig2_comorbidity_prevalence.png"),
       plot = fig2, width = 9, height = 5, dpi = 300)

cat("Coder A outputs saved to output/coder_a/\n")
