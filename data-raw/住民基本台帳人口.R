source("data-raw/setup.R")

# 住民基本台帳人口 ----------------------------------------------------------------

dir_create("data-raw/住民基本台帳人口")
curl_download("https://www.city.urayasu.lg.jp/_res/projects/default_project/_page_/001/022/137/urayasu_jyuuki.nen.cyou_20220401_v01.xls",
              destfile = "data-raw/住民基本台帳人口/令和4年4月1日.xls")
