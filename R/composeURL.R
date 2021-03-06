## http://www.unidata.ucar.edu/software/thredds/current/tds/reference/NetcdfSubsetServiceReference.html

##################################################################
## Main Function
##################################################################
composeURL <- function(var, day, run, spatial, timeFrame,
                       service, point=FALSE){

    if (!is.null(spatial)) {
        ## Bounding Box or Long-Lat
        if (point) {## getPoint
            spatial <- paste0('&point=true',
                              '&longitude=', spatial[1],
                              '&latitude=', spatial[2])
            
        } else { ## getRaster
            ext <- extent(spatial)
            spatial <- paste0('&north=', ymax(ext),
                              '&west=', xmin(ext),
                              '&east=', xmax(ext),
                              '&south=', ymin(ext))
        }
    } else spatial <- ''
    ## Multiple variables are allowed if point=TRUE
    if (point) var <- paste(var, collapse=',') else var <- var[1]
    
    fun <- switch(service,
                  meteogalicia = 'urlMG',
                  openmeteo = 'urlOM',
                  gfs = 'urlGFS',
                  nam = 'urlNAM',
                  rap = 'urlRAP',
                  stop('Unknown service'))

    do.call(fun, list(var = var, day = day, run = run,
                      spatial = spatial, timeFrame = timeFrame))

}

##################################################################
## MeteoGalicia
##################################################################
urlMG <- function(var, day, run, spatial, timeFrame){
    today <- Sys.Date()
    ## meteogalicia stores 14 days of operational forecasts
    ## After 14 days the forecasts are moved to the WRF_HIST folder
    if (today - day <= 14) {
        mainURL <- 'http://mandeo.meteogalicia.es/thredds/ncss/grid/wrf_2d_'
        paste0(mainURL, '12km',
               '/fmrc/files/', ymd(day),
               '/wrf_arw_det_history_d02',
               '_', ymd(day),
               '_', paste0(run, '00'),
               '.nc4?var=', var,
               spatial, timeFrame)
    } else {
        ## Historical forecasts. Only run 0 is available
        mainURL <- 'http://mandeo.meteogalicia.es/thredds/ncss/grid/modelos/WRF_HIST/d02/'
        year <- format(day, '%Y')
        month <- format(day, '%m')
        paste0(mainURL,
               year, '/',
                          month, '/',
               'wrf_arw_det_history_d02_',
               ymd(day),
               '_', '0000',
               '.nc4?var=', var,
               spatial, timeFrame)
    }
}

##################################################################
## Global Forecast
##################################################################
urlGFS <- function(var, day, run, spatial, timeFrame) {
    Ym <- format(day, format='%Y%m')
    mainURL <- 'http://nomads.ncdc.noaa.gov/thredds/ncss/grid/gfs-004/'
    run <- paste0(run, '00')
    timeFrame <- sprintf('%03d', timeFrame)
    paste0(mainURL, Ym, '/', ymd(day), '/',
           'gfs_4_', ymd(day), '_', run, '_', timeFrame,
           '.grb2?var=', var, spatial)
}

##################################################################
## North American Mesoscale Forecast System (NAM) 
##################################################################
urlNAM <- function(var, day, run, spatial, timeFrame) {
    Ym <- format(day, format='%Y%m')
    mainURL <- 'http://nomads.ncdc.noaa.gov/thredds/ncss/grid/nam218/'
    run <- paste0(run, '00')
    timeFrame <- sprintf('%03d', timeFrame)
    paste0(mainURL, Ym, '/', ymd(day), '/',
           'nam_218_', ymd(day), '_', run, '_', timeFrame,
           '.grb?var=', var, spatial)
}
##################################################################
## Rapid Refresh (RAP) 
##################################################################
urlRAP <- function(var, day, run, spatial, timeFrame) {
    Ym <- format(day, format='%Y%m')
    mainURL <- 'http://nomads.ncdc.noaa.gov/thredds/ncss/grid/rap130/'
    run <- paste0(run, '00')
    timeFrame <- sprintf('%03d', timeFrame)
    paste0(mainURL, Ym, '/', ymd(day), '/',
           'rap_130_', ymd(day), '_', run, '_', timeFrame,
           '.grb2?var=', var, spatial)
}

##################################################################
## OpenMeteo
##################################################################
urlOM <- function(var, day, run, spatial, timeFrame) {
    mainURL <- 'http://dap.ometfn.net/eu12-pp_'
    paste0(mainURL,
           ymd(day), run,
           paste0('_', timeFrame),
           '.nc.nc?',var)
}

