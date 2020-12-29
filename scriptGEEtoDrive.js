
var MyFolder='allBadung'


var cropland = ee.Image("USGS/GFSAD1000_V1")
var cropland = cropland.mask(cropland.gt(0))

///=====================================================
/// ================ EVI  DOWNLOAD =====================
///=====================================================

var dataset = ee.ImageCollection('MODIS/MOD09GA_006_EVI')
                 .filterBounds(table)
                .filter(ee.Filter.date('2010-01-01', '2020-08-31'));
 
// GET cropland
var EVI = dataset.select('EVI')
            .map(function(image){
               return image.mask(cropland)
            })


//// get mean values 
EVI = EVI.map(function(image){
return image.set(image.reduceRegion(ee.Reducer.mean(), table, 30))
});

/// chnage date format
EVI = EVI.map(function(image){
  return image.set('timeFormat', image.date().format('dd-MM-yyyy'))
})

Export.table.toDrive({collection: EVI, 
                      description: 'EVI',
                      folder:MyFolder,
                      fileFormat: 'CSV',
                      selectors: ['timeFormat', 'EVI']})
                      



///=====================================================
/// ============== COVARS  DOWNLOAD ====================
///=====================================================

///=======
//RAIN 1981-01-01T00:00:00 - 2020-08-31T00:00:00
///=======
var dataset =  ee.ImageCollection('UCSB-CHG/CHIRPS/DAILY')
                 .filterBounds(table)
                .filter(ee.Filter.date('2010-01-01', '2020-08-31'));
 
// GET cropland
               
var RAIN = dataset.select('precipitation')
            .map(function(image){
               return image.mask(cropland)
            });

//// get mean values 
RAIN = RAIN.map(function(image){
return image.set(image.reduceRegion(ee.Reducer.mean(), table, 30))
});

/// chnage date format
RAIN = RAIN.map(function(image){
  return image.set('timeFormat', image.date().format('dd-MM-yyyy'))
});

Export.table.toDrive({collection: RAIN, 
                      description: 'RAIN',
                      folder:MyFolder,
                      fileFormat: 'CSV',
                      selectors: ['timeFormat', 'precipitation']});


///=======
//TEMPERATURE 2000-03-05T00:00:00 - 2020-10-30T00:00:00
///=======
var dataset =  ee.ImageCollection('MODIS/006/MOD11A1')
                 .filterBounds(table)
                .filter(ee.Filter.date('2010-01-01', '2020-08-31'));

var TEMP = dataset.select('LST_Day_1km') 


///CHNAGE FROM F TO C
var TEMP =TEMP.map(function(image){
  return image.multiply(0.02).subtract(273.15).copyProperties(image, ['system:time_start']);
});

//// get mean values 
TEMP = TEMP.map(function(image){
return image.set(image.reduceRegion(ee.Reducer.mean(), table, 30))
});

// GET cropland
var TEMP = TEMP.map(function(image){
               return image.mask(cropland)
            });


/// chnage date format
TEMP = TEMP.map(function(image){
  return image.set('timeFormat', image.date().format('dd-MM-yyyy'))
});

Export.table.toDrive({collection: TEMP, 
                      description: 'TEMP',
                      folder:MyFolder,
                      fileFormat: 'CSV',
                      selectors: ['timeFormat', 'LST_Day_1km']});


///=======
//WIND 1979-01-02T00:00:00 - 2020-07-09T00:00:00
///=======
var dataset = ee.ImageCollection('ECMWF/ERA5/DAILY')
                 .filterBounds(table)
                .filter(ee.Filter.date('2010-01-01', '2020-08-31'));
 
// GET cropland
               
var WIND = dataset.select('u_component_of_wind_10m')
            .map(function(image){
               return image.mask(cropland)
            });

//// get mean values 
WIND = WIND.map(function(image){
return image.set(image.reduceRegion(ee.Reducer.mean(), table, 30))
});


/// chnage date format
WIND = WIND.map(function(image){
  return image.set('timeFormat', image.date().format('dd-MM-yyyy'))
});

Export.table.toDrive({collection: WIND, 
                      description: 'WIND',
                      folder:MyFolder,
                      fileFormat: 'CSV',
                      selectors: ['timeFormat', 'u_component_of_wind_10m']});


///=======
//HUMIDITY  1979-01-01T00:00:00 - 2020-10-31T00:00:00
///=======
var dataset = ee.ImageCollection('NOAA/CFSV2/FOR6H')
                 .filterBounds(table)
                .filter(ee.Filter.date('2010-01-01', '2020-08-31'));
 
// GET cropland
               
var HUM = dataset.select('Specific_humidity_height_above_ground')
            .map(function(image){
               return image.mask(cropland)
            });

//// get mean values 
HUM = HUM.map(function(image){
return image.set(image.reduceRegion(ee.Reducer.mean(), table, 30))
});


/// chnage date format
HUM = HUM.map(function(image){
  return image.set('timeFormat', image.date().format('dd-MM-yyyy'))
});

Export.table.toDrive({collection: HUM, 
                      description: 'HUM',
                      folder:MyFolder,
                      fileFormat: 'CSV',
                      selectors: ['timeFormat', 'Specific_humidity_height_above_ground']});




///=======
//EVOTRANS  2001-01-01T00:00:00 - 2020-10-15T00:00:00
///=======
var dataset = ee.ImageCollection('MODIS/006/MOD16A2')
                 .filterBounds(table)
                .filter(ee.Filter.date('2010-01-01', '2020-08-31'));
 
// GET cropland
               
var ET = dataset.select('ET')
            .map(function(image){
               return image.mask(cropland)
            });

//// get mean values 
ET = ET.map(function(image){
return image.set(image.reduceRegion(ee.Reducer.mean(), table, 30))
});


/// chnage date format
ET = ET.map(function(image){
  return image.set('timeFormat', image.date().format('dd-MM-yyyy'))
});

Export.table.toDrive({collection: ET, 
                      description: 'ET',
                      folder:MyFolder,
                      fileFormat: 'CSV',
                      selectors: ['timeFormat', 'ET']});







                      

