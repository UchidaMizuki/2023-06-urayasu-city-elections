library(targets)

tar_option_set(
  packages = c("tidyverse", "fs", "readxl", "sf")
)

options(clustermq.scheduler = "multiprocess")

tar_source()

# Replace the target list below with your own:
list(
  # 設定等 ---------------------------------------------------------------------
  tar_target(
    regex_kansuji,
    "[一二三四五六七八九十]"
  ),
  
  # 住民基本台帳人口 ----------------------------------------------------------------
  tar_target(
    file_population_2022_04_01,
    "data-raw/住民基本台帳人口/令和4年4月1日.xls",
    format = "file"
  ),
  tar_target(
    population_2022_04_01,
    get_population(file_population = file_population_2022_04_01)
  ),
  
  # 境界 ----------------------------------------------------------------------
  tar_target(
    file_boundary,
    dir_ls("data-raw/境界/",
           regexp = "shp$"),
    format = "file"
  ),
  tar_target(
    boundary,
    get_boundary(file_boundary = file_boundary,
                 regex_kansuji = regex_kansuji)
  ),
  
  # 投票区 ---------------------------------------------------------------------
  tar_target(
    file_precinct,
    "data-raw/投票区.csv",
    format = "file"
  ),
  tar_target(
    precinct_chome, 
    get_precinct_chome(file_precinct = file_precinct,
                       boundary = boundary,
                       regex_kansuji = regex_kansuji)
  ),
  tar_target(
    precinct,
    get_precinct(precinct_chome = precinct_chome)
  )
)
