# From Questionnaire_analysis_original.R: loading and exclusions.
# run_questionnaire_analysis.R loads the dependencies and creates output folders.
dfq <- read_csv(file.path("data", "questionnaire_stop_signal_processed.csv"))

participants_to_drop <- c(9, 10, 18, 19)
dfq <- dfq[!dfq$ResponseId %in% participants_to_drop,]

glimpse(dfq)
summary(dfq)

# The original selects the eight questionnaire fields below.
data <- dfq %>% select(ResponseId, Age, Sex, Social, impulsivity_total, addiction_total, IGA_impulsivity_total, IGA_social_effect)
names(data) <- tolower(names(data))

dataLong <- data %>%
    pivot_longer(cols = c(impulsivity_total, addiction_total, iga_impulsivity_total, iga_social_effect),
    names_to = "variable", values_to = 'score')
