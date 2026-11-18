# Saved analysis results

This report is built from previously saved aggregate CSVs and model RDS files.

## Available model files

- `outputs/models/go/accuracy_addiction.rds`
- `outputs/models/go/accuracy_glmer.rds`
- `outputs/models/go/accuracy_glmmtmb.rds`
- `outputs/models/go/accuracy_impulsivity.rds`
- `outputs/models/go/all_trial_rt_addiction.rds`
- `outputs/models/go/all_trial_rt_anova.rds`
- `outputs/models/go/all_trial_rt_bayes_factor.rds`
- `outputs/models/go/all_trial_rt_group_condition.rds`
- `outputs/models/go/all_trial_rt_impulsivity.rds`
- `outputs/models/go/all_trial_rt_simple.rds`
- `outputs/models/go/go_omissions_addiction.rds`
- `outputs/models/go/go_omissions_impulsivity.rds`
- `outputs/models/go/go_omissions_main.rds`
- `outputs/models/go/go_trial_rt_anova.rds`
- `outputs/models/go/go_trial_rt_mixed.rds`
- `outputs/models/stop/ssd_change_bayes_factor.rds`
- `outputs/models/stop/ssd_change_model.rds`
- `outputs/models/stop/ssd_group_condition.rds`
- `outputs/models/stop/ssd_simple.rds`
- `outputs/models/stop/ssrt_questionnaire_anova_results.rds`
- `outputs/models/stop/ssrt_questionnaire_impulsivity_model.rds`

## Aggregate tables

### accuracy_summary.csv

Rows: 8; columns: 5

```
      group condition trial_type mean_correct mean_incorrect
1   IGFirst        IG         go    0.9887968    0.011203227
2   IGFirst        IG       stop    0.0000000    1.000000000
3   IGFirst      Poem         go    0.9934300    0.006570005
4   IGFirst      Poem       stop    0.0000000    1.000000000
5 PoemFirst        IG         go    0.9954602    0.004539827
6 PoemFirst        IG       stop    0.0000000    1.000000000
7 PoemFirst      Poem         go    0.9966942    0.003305785
8 PoemFirst      Poem       stop    0.0000000    1.000000000
```

### all_trial_rt_emmeans.csv

Rows: 4; columns: 7

```
      group condition   emmean       SE  df asymp.LCL asymp.UCL
1   IGFirst        IG 555.6060 41.46940 Inf  474.3275  636.8845
2 PoemFirst        IG 678.6031 39.84269 Inf  600.5128  756.6933
3   IGFirst      Poem 613.7395 41.47011 Inf  532.4596  695.0195
4 PoemFirst      Poem 670.8941 39.84292 Inf  592.8034  748.9848
```

### demographics_by_gender.csv

Rows: 3; columns: 4

```
   gender  n mean_age   sd_age
1   Altro  1 26.00000       NA
2 Femmina 30 26.90000 9.678807
3 Maschio 19 26.26316 9.072805
```

### go_omission_summary.csv

Rows: 4; columns: 5

```
      group condition total_omission total_trials percent_omission
1   IGFirst        IG             50         4463        1.1203227
2   IGFirst      Poem             29         4414        0.6570005
3 PoemFirst        IG             22         4846        0.4539827
4 PoemFirst      Poem             16         4840        0.3305785
```

### go_omissions_emmeans.csv

Rows: 4; columns: 7

```
      group condition    emmean        SE  df asymp.LCL asymp.UCL
1   IGFirst        IG -5.242607 0.2887862 Inf -5.808617 -4.676596
2 PoemFirst        IG -5.932110 0.3108497 Inf -6.541365 -5.322856
3   IGFirst      Poem -5.706918 0.3036666 Inf -6.302094 -5.111743
4 PoemFirst      Poem -6.396422 0.3244634 Inf -7.032359 -5.760485
```

### go_trial_rt_emmeans.csv

Rows: 4; columns: 7

```
      group condition   emmean       SE  df asymp.LCL asymp.UCL
1   IGFirst        IG 566.1324 41.82648 Inf  484.1540  648.1108
2 PoemFirst        IG 688.7514 40.18545 Inf  609.9893  767.5134
3   IGFirst      Poem 622.1277 41.82714 Inf  540.1480  704.1074
4 PoemFirst      Poem 683.5619 40.18549 Inf  604.7998  762.3240
```

### go_trial_rt_plot_summary.csv

Rows: 4; columns: 7

```
  condition     group  N       rt       sd       se        ci
1        IG   IGFirst 24 565.6240 202.0950 41.25247  85.33723
2        IG PoemFirst 26 689.9562 206.4781 40.49370  83.39833
3      Poem   IGFirst 24 623.5381 245.4190 50.09594 103.63135
4      Poem PoemFirst 26 683.5888 186.6450 36.60409  75.38753
```

### go_error_group_content_summary.csv

Rows: 4; columns: 6

```
       group content variable  n  mean    sd
1   IG_first      IG go_error 24 0.010 0.020
2   IG_first    Poem go_error 25 0.008 0.013
3 Poem_first      IG go_error 22 0.008 0.018
4 Poem_first    Poem go_error 25 0.004 0.007
```

### go_omission_group_content_summary.csv

Rows: 4; columns: 6

```
       group content    variable  n  mean    sd
1   IG_first      IG go_omission 24 0.026 0.050
2   IG_first    Poem go_omission 25 0.034 0.057
3 Poem_first      IG go_omission 22 0.024 0.044
4 Poem_first    Poem go_omission 25 0.030 0.043
```

### gort_correct_group_content_summary.csv

Rows: 4; columns: 6

```
       group content     variable  n    mean      sd
1   IG_first      IG gort_correct 24 580.208 215.732
2   IG_first    Poem gort_correct 25 606.640 238.814
3 Poem_first      IG gort_correct 22 660.818 208.281
4 Poem_first    Poem gort_correct 25 681.560 204.448
```

### gort_correct_group_summary.csv

Rows: 2; columns: 5

```
       group     variable  n    mean     sd
1   IG_first gort_correct 49 593.694 225.82
2 Poem_first gort_correct 47 671.851 204.26
```

### presp_group_content_summary.csv

Rows: 4; columns: 6

```
       group content variable  n  mean    sd
1   IG_first      IG    presp 24 0.499 0.055
2   IG_first    Poem    presp 25 0.480 0.052
3 Poem_first      IG    presp 22 0.485 0.069
4 Poem_first    Poem    presp 25 0.464 0.034
```

### ssd_emmeans.csv

Rows: 4; columns: 7

```
      group condition   emmean       SE  df asymp.LCL asymp.UCL
1   IGFirst        IG 327.9549 44.18172 Inf  241.3603  414.5495
2 PoemFirst        IG 457.2350 42.44853 Inf  374.0375  540.4326
3   IGFirst      Poem 398.5588 44.18213 Inf  311.9634  485.1542
4 PoemFirst      Poem 448.1615 42.44866 Inf  364.9637  531.3594
```

### ssd_group_content_summary.csv

Rows: 4; columns: 6

```
       group content variable  n    mean      sd
1   IG_first      IG      ssd 24 342.750 232.810
2   IG_first    Poem      ssd 25 377.840 243.869
3 Poem_first      IG      ssd 22 405.409 220.332
4 Poem_first    Poem      ssd 25 440.080 225.154
```

### ssd_group_summary.csv

Rows: 2; columns: 5

```
       group variable  n    mean      sd
1   IG_first      ssd 49 360.653 236.688
2 Poem_first      ssd 47 423.851 221.173
```

### ssd_plot_summary.csv

Rows: 4; columns: 7

```
  condition     group  N      SSD       sd       se        ci
1        IG   IGFirst 24 323.0954 221.9612 45.30764  93.72598
2        IG PoemFirst 26 453.1288 215.8235 42.32646  87.17298
3      Poem   IGFirst 24 394.5183 250.2151 51.07495 105.65659
4      Poem PoemFirst 26 443.8584 199.0122 39.02951  80.38278
```

### ssd_summary.csv

Rows: 4; columns: 8

```
  condition     group variable    n    mean      sd       se ci_width
1        IG   IGFirst      SSD 5225 315.799 233.500 3.230307 6.332752
2      Poem   IGFirst      SSD 5151 387.303 260.272 3.626450 7.109382
3        IG PoemFirst      SSD 5637 448.465 234.134 3.118462 6.113386
4      Poem PoemFirst      SSD 5606 441.491 221.248 2.954968 5.792882
```

### ssrt_group_content_summary.csv

Rows: 4; columns: 6

```
       group content variable  n    mean     sd
1   IG_first      IG     ssrt 24 233.750 36.176
2   IG_first    Poem     ssrt 25 219.360 33.092
3 Poem_first      IG     ssrt 22 246.182 42.120
4 Poem_first    Poem     ssrt 25 228.800 32.025
```

### ssrt_integration_plot_summary.csv

Rows: 4; columns: 7

```
  content      group  N     ssrt       sd       se       ci
1      IG   IG_first 24 233.7500 36.17620 7.384436 15.27587
2      IG Poem_first 22 246.1818 42.11960 8.979929 18.67478
3    Poem   IG_first 25 219.3600 33.09189 6.618378 13.65966
4    Poem Poem_first 25 228.8000 32.02473 6.404946 13.21916
```

### ssrt_questionnaire_fixed_effects.csv

Rows: 28; columns: 8

```
   effect                          term    estimate std.error   statistic
1   fixed                   (Intercept) 286.3943903 63.689161  4.49675248
2   fixed             impulsivity_total  -1.4747875  1.694977 -0.87009303
3   fixed                   ordersecond  60.7053402 86.156199  0.70459631
4   fixed impulsivity_total:ordersecond  -1.5990902  2.297604 -0.69598149
5   fixed                   (Intercept) 261.7671723 36.345780  7.20213377
6   fixed             impulsivity_motor  -2.4892148  2.924111 -0.85127227
7   fixed                   ordersecond  -2.8041097 49.302822 -0.05687524
8   fixed impulsivity_motor:ordersecond   0.3365860  3.958211  0.08503489
9   fixed                   (Intercept) 220.8589272 33.737531  6.54638677
10  fixed       impulsivity_attentional   0.7672356  2.472212  0.31034384
         df      p.value               predictor
1  83.70141 2.202157e-05       impulsivity_total
2  83.69795 3.867381e-01       impulsivity_total
3  41.64474 4.849835e-01       impulsivity_total
4  41.77254 4.902948e-01       impulsivity_total
5  83.88377 2.348746e-10       impulsivity_motor
6  83.87707 3.970419e-01       impulsivity_motor
7  40.81646 9.549221e-01       impulsivity_motor
8  40.59737 9.326516e-01       impulsivity_motor
9  83.49752 4.509568e-09 impulsivity_attentional
10 83.48533 7.570729e-01 impulsivity_attentional
```

### usrt_group_content_summary.csv

Rows: 4; columns: 6

```
       group content variable  n    mean      sd
1   IG_first      IG     usrt 24 505.208 205.030
2   IG_first    Poem     usrt 25 546.080 224.910
3 Poem_first      IG     usrt 22 577.955 191.300
4 Poem_first    Poem     usrt 25 594.640 187.799
```

### usrt_group_summary.csv

Rows: 2; columns: 5

```
       group variable  n    mean      sd
1   IG_first     usrt 49 526.061 214.152
2 Poem_first     usrt 47 586.830 187.559
```

### usrt_integration_plot_summary.csv

Rows: 4; columns: 7

```
  content      group  N     usrt       sd       se       ci
1      IG   IG_first 24 505.2083 205.0298 41.85153 86.57649
2      IG Poem_first 22 577.9545 191.2999 40.78528 84.81764
3    Poem   IG_first 25 546.0800 224.9100 44.98199 92.83827
4    Poem Poem_first 25 594.6400 187.7986 37.55972 77.51946
```

## Figures

- `go/accuracy_correct.png`
- `go/accuracy_incorrect.png`
- `go/accuracy_residual_qq.png`
- `go/all_trial_rt_condition_predicted.png`
- `go/all_trial_rt_residual_qq.png`
- `go/go_omission_counts.png`
- `go/go_omissions_predicted.png`
- `go/go_trial_rt_change.png`
- `go/go_trial_rt_means.png`
- `go/go_trial_rt_predicted.png`
- `go/go_trial_rt_residual_qq.png`
- `stop/ssd_group_condition_predicted.png`
- `stop/ssd_means.png`
- `stop/ssd_simple_predicted.png`
- `stop/ssrt_integration_density.png`
- `stop/ssrt_integration_means.png`
- `stop/usrt_integration_means.png`
