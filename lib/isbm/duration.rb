module Isbm
  # Class that supports creation of ISO 8601 duration strings
  class Duration
    attr_accessor :years
    attr_accessor :months
    attr_accessor :days
    attr_accessor :hours
    attr_accessor :minutes
    attr_accessor :seconds

    # 'duration' is a hash that can contain any combination of the keys
    # :years, :months, :days, :hours, :minutes, :seconds mapped to a numeric value
    def initialize(duration)
      duration.keys.each do |key|
        raise ArgumentError.new "Invalid key: #{key}" unless VALID_SYMBOLS.include?(key)
      end

      duration.each do |key, value|
        raise ArgumentError.new "Value for #{key} cannot be less than 0" if value < 0
      end

      @years = duration[:years]
      @months = duration[:months]
      @days = duration[:days]
      @hours = duration[:hours]
      @minutes = duration[:minutes]
      @seconds = duration[:seconds]
    end

    def to_s
      date = []
      date << "#{@years}Y" unless @years.nil?
      date << "#{@months}M" unless @months.nil?
      date << "#{@days}D" unless @days.nil?

      time = []
      time << "#{@hours}H" unless @hours.nil?
      time << "#{@minutes}M" unless @minutes.nil?
      time << "#{@seconds}S" unless @seconds.nil?

      result = nil

      if !date.empty? || !time.empty?
        result = "P"
        result += date.join unless date.empty?
        result += "T" + time.join unless time.empty?
      end

      result
    end

    private

    VALID_SYMBOLS = [:years, :months, :days, :hours, :minutes, :seconds]
  end
end