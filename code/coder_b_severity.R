## coder_b_severity.R — COVID Severity and Healthcare Utilization
## Coder B: Xiyuan Zhao

here::i_am("code/coder_b_severity.R")
source(here::here("code", "utils.R"))

config <- read_config()
df <- load_data(config)
df <- apply_filters(df, config)

# ── Table 2: COVID Classification Distribution ────────────────────────────────
class_table <- df %>%
  count(clasiffication_final, name = "n") %>%
  mutate(pct = round(n / sum(n) * 100, 1)) %>%
  rename(Classification = clasiffication_final)

table_2 <- knitr::kable(class_table,
                         caption = "Table 2. COVID Classification Distribution")
saveRDS(table_2, here::here("output", "coder_b", "table_2.rds"))

# ── Figure 3: Patient Type by Age Group ───────────────────────────────────────
# Recode patient_type
df <- df %>%
  mutate(
    patient_type_label = case_when(
      patient_type == "returned home" | patient_type == 1 ~ "Outpatient",
      patient_type == "hospitalization" | patient_type == 2 ~ "Hospitalized",
      TRUE ~ as.character(patient_type)
    )
  )

fig3_data <- df %>%
  filter(!is.na(age_group), !is.na(patient_type_label)) %>%
  count(age_group, patient_type_label)

fig3 <- ggplot(fig3_data, aes(x = age_group, y = n, fill = patient_type_label)) +
  geom_col(position = "dodge") +
  labs(title = "Figure 3. Patient Type by Age Group",
       x = "Age Group", y = "Count", fill = "Patient Type") +
  scale_fill_brewer(palette = "Set2") +
  theme_covid()

ggsave(here::here("output", "coder_b", "fig3_patient_type_age.png"),
       plot = fig3, width = 9, height = 5, dpi = 300)

# ── Figure 4: Medical Unit Level Distribution ─────────────────────────────────
# USMER: 1 = first level, 2 = second level, 3 = third level (approximate)
df <- df %>%
  mutate(
    usmer_label = case_when(
      usmer == "Yes" | usmer == 1 ~ "USMER (primary care)",
      usmer == "No"  | usmer == 2 ~ "Non-USMER (hospital)",
      TRUE ~ as.character(usmer)
    )
  )

fig4_data <- df %>%
  count(usmer_label) %>%
  mutate(pct = round(n / sum(n) * 100, 1))

fig4 <- ggplot(fig4_data, aes(x = usmer_label, y = n, fill = usmer_label)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = paste0(pct, "%")), vjust = -0.5) +
  labs(title = "Figure 4. Medical Unit Type Distribution",
       x = NULL, y = "Count") +
  guides(fill = "none") +
  scale_fill_brewer(palette = "Pastel1") +
  theme_covid()

ggsave(here::here("output", "coder_b", "fig4_medical_unit.png"),
       plot = fig4, width = 8, height = 5, dpi = 300)

cat("Coder B outputs saved to output/coder_b/\n")
