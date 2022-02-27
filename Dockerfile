# load existing image
FROM rocker/tidyverse:4.1.0

# install packages needed
RUN R -e "install.packages('ggsci')"
RUN R -e "install.packages('rvest')"

# copy the necessary files from the folder into the image
COPY /web-scraping-VivaReal.R /web-scraping-VivaReal.R

# run the R script
CMD Rscript /web-scraping-VivaReal.R