class Airport < ActiveRecord::Base
  belongs_to(:cities)
  require "httparty"

  # attr_accessor :cost
  #
  # def initialize(cost)
  #   self.cost = cost

  def airport_data
    raw_data = HTTParty.post("https://www.googleapis.com/qpxExpress/v1/trips/search?key=AIzaSyDqAnFxbvWwhyBZEGsZYN1lfGmIoOCE77k",
    :body => { request: { passengers: { adultCount: 1}, slice: [{origin: "PDX", destination: "SEA", date: "2015-09-25"},{origin: "SEA", destination: "PDX", date: "2015-10-10"}]}}.to_json,
    :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'})

    cheapest_costs = []
    cheapest_trips = []
    count = 0
    all_flights_data = raw_data.parsed_response.fetch("trips")
    all_flights_data.fetch("tripOption").each do |trip|
      if !cheapest_costs.include?(trip.fetch("saleTotal")) && count < 5
        cheapest_trips.push(trip)
        cheapest_costs.push(trip.fetch("saleTotal"))
        count += 1
      end
    end

    cheapest_costs.each do |cost|
      puts "---------------------"
      puts "|ONE POSSIBLE FLIGHT|"
      puts "---------------------"
      puts "Flight Cost: " + cost
      puts "From " + cheapest_trips[0].fetch("slice")[0].fetch("segment")[0].fetch("leg")[0].fetch("origin") + " to " + cheapest_trips[0].fetch("slice")[0].fetch("segment")[0].fetch("leg")[0].fetch("destination")
      puts "Duration: " + cheapest_trips[0].fetch("slice")[0].fetch("segment")[0].fetch("duration").to_s + " minutes"
    end

  end
end
