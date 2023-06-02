source("data-raw/setup.R")

# 投票区 ---------------------------------------------------------------------

curl_download("https://www.city.urayasu.lg.jp/_res/projects/default_project/_page_/001/022/366/urayasu_touhyouku_20220621_v01.csv",
              destfile = "data-raw/投票区.csv")
