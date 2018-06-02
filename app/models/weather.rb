
class Weather < ActiveRecord::Base
    serialize :w_time,Array
    serialize :w_temp,Array
    serialize :w_weather,Array
    
 
end
