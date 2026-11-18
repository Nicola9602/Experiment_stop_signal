# Source: original/Analysis_stop_data_original.R. Statistical code retained.
# Descriptive statistics ----

#region 2. Descriptive statistics ----

# Summary statistics for SSRT 

dfi %>%
    group_by(group, content) %>%
    get_summary_stats(ssrt, type="mean_sd") %>%
    as.data.frame()

# Summary for SSD

dfi %>%
  group_by(group, content) %>%
  get_summary_stats(ssd, type = "mean_sd")

dfi %>% 
  group_by(group) %>%
  get_summary_stats(ssd, type="mean_sd")

# Summary statistics for rt in incorrect trials so failed stop responses

dfi %>%
  group_by(group, content) %>%
  get_summary_stats(usrt, type="mean_sd") %>%
  as.data.frame()

dfi %>%
  group_by(group) %>%
  get_summary_stats(usrt, type="mean_sd") %>%
  as.data.frame()

# Summary statistics for rt in go correct
dfi %>%
  group_by(group, content) %>%
  get_summary_stats(gort_correct, type="mean_sd") %>%
  as.data.frame()

dfi %>%
  group_by(group) %>%
  get_summary_stats(gort_correct, type="mean_sd") %>%
  as.data.frame()
  
# Summary statistics for p resp 

dfi %>%
  group_by(group, content) %>%
  get_summary_stats(presp, type = "mean_sd")

# Summary for go omission 

dfi %>%
  group_by(group, content) %>%
  get_summary_stats(go_omission, type ="mean_sd")

# Summary for go error
dfi %>%
  group_by(group, content) %>%
  get_summary_stats(go_error, type ="mean_sd")

#endregion ----


readr::write_csv(dfi %>% group_by(group, content) %>% get_summary_stats(ssrt, type="mean_sd"),
  "outputs/tables/stop/ssrt_group_content_summary.csv")

readr::write_csv(dfi %>% group_by(group, content) %>% get_summary_stats(ssd, type="mean_sd"),
  "outputs/tables/stop/ssd_group_content_summary.csv")

readr::write_csv(dfi %>% group_by(group) %>% get_summary_stats(ssd, type="mean_sd"),
  "outputs/tables/stop/ssd_group_summary.csv")

readr::write_csv(dfi %>% group_by(group, content) %>% get_summary_stats(usrt, type="mean_sd"),
  "outputs/tables/stop/usrt_group_content_summary.csv")

readr::write_csv(dfi %>% group_by(group) %>% get_summary_stats(usrt, type="mean_sd"),
  "outputs/tables/stop/usrt_group_summary.csv")

readr::write_csv(dfi %>% group_by(group, content) %>% get_summary_stats(gort_correct, type="mean_sd"),
  "outputs/tables/stop/gort_correct_group_content_summary.csv")

readr::write_csv(dfi %>% group_by(group) %>% get_summary_stats(gort_correct, type="mean_sd"),
  "outputs/tables/stop/gort_correct_group_summary.csv")

readr::write_csv(dfi %>% group_by(group, content) %>% get_summary_stats(presp, type="mean_sd"),
  "outputs/tables/stop/presp_group_content_summary.csv")

readr::write_csv(dfi %>% group_by(group, content) %>% get_summary_stats(go_omission, type="mean_sd"),
  "outputs/tables/stop/go_omission_group_content_summary.csv")

readr::write_csv(dfi %>% group_by(group, content) %>% get_summary_stats(go_error, type="mean_sd"),
  "outputs/tables/stop/go_error_group_content_summary.csv")

