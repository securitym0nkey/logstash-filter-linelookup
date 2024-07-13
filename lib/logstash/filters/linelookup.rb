# encoding: utf-8
require "logstash/filters/base"
require "socket"

class LogStash::Filters::Linelookup < LogStash::Filters::Base

  #
  # filter {
  #   linelookup {
  #     query => "%{[source][ip]}"
  #     socket_path => "/var/run/lookup.sock"
  #   }
  # }
  #
  config_name "linelookup"

  config :query, :validate => :string, :required => true
  config :target, :validate => :string, :required => true
  config :miss_value, :validate => :string, :default => ""
  config :socket_path, :validate => :string, :default => ""

  public
  def register
    @lookupconn = nil
    @connmu = Mutex.new
  end

  public
  def filter(event)
    retries = 2  
    begin

      @connmu.lock
      @lookupconn ||= connect
      @lookupconn.puts(event.sprintf(@query))
      @lookupconn.flush

      response = @lookupconn.gets.chop
      @connmu.unlock

      if response != @miss_value
        event.set(@target, response)
        filter_matched(event)
      end

    rescue => e
      @logger.warn("Failed to query lookup service", :event => event, :exception => e)
      @lookupconn = nil
      retries -= 1
      unless retries < 0
        retry
      else
        @logger.warn("Too many reties. Giving up.", :event => event)
        event.tag("_linelookup_failure")
      end
    end

  end # def filter
  
  private
  def connect

    Socket.unix(@socket_path)
  end

  def close
    @lookupconn.close
  end
end # class LogStash::Filters::Linelookup
