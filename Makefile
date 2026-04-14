RSCRIPT = Rscript

.PHONY: all clean install coder_a coder_b coder_c report

all: report

## install: restore R package environment from renv.lock
install:
	$(RSCRIPT) -e "renv::restore(prompt = FALSE)"

## coder_a: demographics and comorbidity profile (Lidong Yu)
coder_a: output/coder_a/table_1.rds

output/coder_a/table_1.rds: code/coder_a_demographics.R code/utils.R config/config.yml data/covid_sub.csv
	$(RSCRIPT) code/coder_a_demographics.R

## coder_b: COVID severity and healthcare utilization (Xiyuan Zhao)
coder_b: output/coder_b/table_2.rds

output/coder_b/table_2.rds: code/coder_b_severity.R code/utils.R config/config.yml data/covid_sub.csv
	$(RSCRIPT) code/coder_b_severity.R

## coder_c: clinical outcomes analysis (Yuqing Huang)
coder_c: output/coder_c/table_3.rds

output/coder_c/table_3.rds: code/coder_c_outcomes.R code/utils.R config/config.yml data/covid_sub.csv
	$(RSCRIPT) code/coder_c_outcomes.R

## report: render final integrated HTML report
report: report/final_report.html

report/final_report.html: report/final_report.Rmd output/coder_a/table_1.rds output/coder_b/table_2.rds output/coder_c/table_3.rds
	$(RSCRIPT) code/render_report.R

## clean: remove all generated outputs
clean:
	rm -f output/coder_a/* output/coder_b/* output/coder_c/*
	rm -f report/final_report.html
