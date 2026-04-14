## coder_c_outcomes.R — Clinical Outcomes Analysis
## Coder C: Yuqing Huang

here::i_am("code/coder_c_outcomes.R")
source(here::here("code", "utils.R"))

config <- read_config()
df <- load_data(config)
df <- apply_filters(df, config)

# Restrict to confirmed COVID cases for outcome analysis
df_confirmed <- df %>% filter(clasiffication_final %in% 1:3)

# ── Table 3: Outcome Summary Table ────────────────────────────────────────────
calc_outcome <- function(x) {
  n <- sum(x == 1, na.rm = TRUE)
  total <- sum(!is.na(x))
  pct <- n / total
  se <- sqrt(pct * (1 - pct) / total)
  ci_low <- round((pct - 1.96 * se) * 100, 1)
  ci_high <- round((pct + 1.96 * se) * 100, 1)
  data.frame(
    Count = n,
    Percentage = round(pct * 100, 1),
    CI_95 = paste0("(", ci_low, ", ", ci_high, ")")
  )
}

outcome_table <- bind_rows(
  calc_outcome(df_confirmed$died) %>% mutate(Outcome = "Died"),
  calc_outcome(df_confirmed$intubed_bin) %>% mutate(Outcome = "Intubated"),
  calc_outcome(df_confirmed$icu_bin) %>% mutate(Outcome = "ICU Admitted")
) %>%
  select(Outcome, Count, Percentage, CI_95) %>%
  rename(`95% CI` = CI_95)

table_3 <- knitr::kable(outcome_table,
                         caption = "Table 3. Outcome Summary (Confirmed COVID Cases)")
saveRDS(table_3, here::here("output", "coder_c", "table_3.rds"))

# ── Figure 5: Mortality Rate by Age Group ─────────────────────────────────────
mort_age <- df_confirmed %>%
  filter(!is.na(age_group)) %>%
  group_by(age_group) %>%
  summarise(
    n = n(),
    deaths = sum(died == 1, na.rm = TRUE),
    rate = deaths / n,
    se = sqrt(rate * (1 - rate) / n),
    ci_low = rate - 1.96 * se,
    ci_high = rate + 1.96 * se,
    .groups = "drop"
  )

fig5 <- ggplot(mort_age, aes(x = age_group, y = rate * 100)) +
  geom_col(fill = "tomato", width = 0.6) +
  geom_errorbar(aes(ymin = ci_low * 100, ymax = ci_high * 100),
                width = 0.2) +
  labs(title = "Figure 5. Mortality Rate by Age Group",
       subtitle = "Among confirmed COVID-19 cases, with 95% CI",
       x = "Age Group", y = "Mortality Rate (%)") +
  theme_covid()

ggsave(here::here("output", "coder_c", "fig5_mortality_age.png"),
       plot = fig5, width = 8, height = 5, dpi = 300)

# ── Figure 6: Outcomes by Number of Comorbidities ─────────────────────────────
outcome_comorb <- df_confirmed %>%
  filter(!is.na(comorbidity_group)) %>%
  group_by(comorbidity_group) %>%
  summarise(
    `Mortality` = mean(died == 1, na.rm = TRUE) * 100,
    `Intubation` = mean(intubed_bin == 1, na.rm = TRUE) * 100,
    `ICU Admission` = mean(icu_bin == 1, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  pivot_longer(-comorbidity_group, names_to = "outcome", values_to = "rate")

fig6 <- ggplot(outcome_comorb,
               aes(x = comorbidity_group, y = rate,
                   color = outcome, group = outcome)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  labs(title = "Figure 6. Outcomes by Number of Comorbidities",
       subtitle = "Among confirmed COVID-19 cases",
       x = "Number of Comorbidities", y = "Rate (%)",
       color = "Outcome") +
  scale_color_brewer(palette = "Dark2") +
  theme_covid()

ggsave(here::here("output", "coder_c", "fig6_outcomes_comorbidity.png"),
       plot = fig6, width = 9, height = 5, dpi = 300)

cat("Coder C outputs saved to output/coder_c/\n")
## Reviewed and verified by Yuqing Huang on 2026-04-14
