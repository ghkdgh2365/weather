    namespace :data do
      desc "weather data save"
      task :weatherSave => :environment do
        require 'nokogiri'
        require 'open-uri'
        @time = Array.new
        @temp = Array.new
        @weather = Array.new
        @now_temp = Array.new
        @weather_size = 0
        @timeX = 0
        @tempX = 0
        @weatherX = 0
        # 기상청 홈페이지 열기
        doc = Nokogiri::HTML(open("http://m.kma.go.kr"))
        
        # 시간 뽑기(내일까지만)
        doc.css(".w-item-hr").each do |x|
          if @timeX < 10
            @time << x.inner_text if x.inner_text.include?("시")
            @timeX += 1
          end
        end
        @time.delete_at(3)#중복값 제거
        # 온도 뽑기(내일까지만)
        doc.css(".w-item li").each do |x|
          if x.inner_text.include?("℃") 
            unless x.inner_text.include?("최저") || x.inner_text.include?("/")
              if @tempX < 10
                @temp << x.inner_text
                @tempX += 1
              end
            end
          end
        end
        @temp.delete_at(3)
        # 날씨 뽑기
        doc.css(".w-item li:nth-child(5)").each do |x|
          if @weatherX < 10
            # if @weather_size <= @temp.size
              @weather << x.inner_text
              # @weather_size += 1
            # end
            @weatherX += 1
          end
        end
        @weather.delete_at(3)
        # 현재 날씨
        doc.css(".inf > p").each do |x|
          @now_temp << x.inner_text if x.inner_text.include?("℃") 
        end
        @now_temp = @now_temp.pop
        @todayweather = Weather.new
        @todayweather.w_time = @time
        @todayweather.w_temp = @temp
        @todayweather.w_weather = @weather
        @todayweather.save
        
        @mises = [] #미세먼지, 오존 정보 담을 통
        air = Nokogiri::HTML(open("https://www.airkorea.or.kr/dustForecast")) #에어코리아 크롤링
        
        # 미세,오존 정보 뽑기
        air.css(".inform_overall").each do |x|
          @mises << x.inner_text
        end
        
        @mise = Mise.new
        @mise.mise_info = @mises[0] #미세먼지 오늘꺼
        @mise.ozone_info = @mises[2] #오존 오늘꺼
        @mise.save
      end
    
    end
    