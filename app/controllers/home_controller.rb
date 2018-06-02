require 'nokogiri'
require 'open-uri'
class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
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
    
    stationId = params[:stationId] # 정류장 ID 받기
    if stationId != nil
      # api 결과창 열기
      doc = 'http://openapi.gbis.go.kr/ws/rest/busarrivalservice/station?serviceKey=iLCc00ow2zE9U05qyUbxfw5Vh6jRYV%2FISVtGoizyINdTioSCpRhcRckIUl8LPVmm%2BQYuzB4hyqkIyMSkvnEspQ%3D%3D&stationId='+ stationId
      # xml 형식으로 뽑아서 담기
      @arriveData = Nokogiri::XML(open(doc)) #정류소 도착 정보 뽑아오기
      @routeId = Array.new #버스ID
      @predictTime1 = Array.new #첫 번째 버스 도착 시간
      @predictTime2 = Array.new #두 번째 버스 도착 시간
      @locationNo1 = Array.new #첫 번째 버스 남은 정거장 수
      @locationNo2 = Array.new #두 번째 버스 남은 정거장 수
      @busNameUrl = Array.new #버스 번호 찾기 위한 URL
      @busInfo = Array.new #버스 정보 담기
      @routeName = Array.new #버스 번호 담기
      #정류장에 오는 버스ID 담기
      @arriveData.xpath("//routeId").each do |x|
        @routeId << x.text
      end
      #버스 번호 찾을 수 있게 URL 뒤에 버스ID 붙이기
      @routeId.each do |x|
        @busNameUrl << "http://openapi.gbis.go.kr/ws/rest/busrouteservice/info?serviceKey=iLCc00ow2zE9U05qyUbxfw5Vh6jRYV%2FISVtGoizyINdTioSCpRhcRckIUl8LPVmm%2BQYuzB4hyqkIyMSkvnEspQ%3D%3D&routeId=" + x
      end
      #위의 주소로 버스 번호 들어있는 XML 불러오기
      @busNameUrl.each do |x|
        @busInfo << Nokogiri::XML(open(x))
      end
      #버스 번호 뽑아서 저장하기
      @busInfo.each do |x|
       @routeName << x.xpath("//routeName").text
      end
      #남은 정거장 수 뽑아서 저장(1)
      @arriveData.xpath("//locationNo1").each do |x|
        @locationNo1 << x.text
      end
      #남은 정거장 수 뽑아서 저장(2)
      @arriveData.xpath("//locationNo2").each do |x|
        @locationNo2 << x.text
      end
      #도착 시간 뽑아서 저장(1)
      @arriveData.xpath("//predictTime1").each do |x|
        @predictTime1 << x.text
      end
      #도착 시간 뽑아서 저장(2)
      @arriveData.xpath("//predictTime2").each do |x|
        @predictTime2 << x.text
      end
      
      @i = 0 # 반복문을 위한 변수 설정
    end
  end
  
  def searchStationId
    @i=0 # 반복문을 위한 변수 설정
    stationName = params[:station_name] #정류장명 받기
    # stationName = "수락리버시티아파트" # test로 박아 놓은 거
    keyword = URI.encode(stationName) # 한글(utf-8) url 로 변환
    
    #api 결과창 열기 
    doc = 'http://openapi.gbis.go.kr/ws/rest/busstationservice?serviceKey=iLCc00ow2zE9U05qyUbxfw5Vh6jRYV%2FISVtGoizyINdTioSCpRhcRckIUl8LPVmm%2BQYuzB4hyqkIyMSkvnEspQ%3D%3D&keyword=' + keyword

    #xml 형식으로 가져오기
    @searchStationId = Nokogiri::XML(open(doc))
    @mobileNo = Array.new
    @regionName = Array.new
    @stationId = Array.new
    @stationName = Array.new
    @x = Array.new
    @y = Array.new
    @searchStationId.xpath("//mobileNo").each do |x|
     @mobileNo << x.text
    end
    @searchStationId.xpath("//regionName").each do |x|
      @regionName << x.text
    end
    @searchStationId.xpath("//stationId").each do |x|
      @stationId << x.text
    end
    @searchStationId.xpath("//stationName").each do |x|
      @stationName << x.text
    end
    @searchStationId.xpath("//x").each do |x|
      @x << x.text
    end
    @searchStationId.xpath("//y").each do |x|
      @y << x.text
    end
  end
  
  def weather
    @weather = Weather.last
    @mise = Mise.last
  end
  
end
