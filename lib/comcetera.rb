require 'open-uri'
require 'timeout'

class Comcetera
  attr_accessor :operator_code, :msisdn

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  class << self
    attr_accessor :username, :password, :timeout, :retries

    def timeout
      @timeout ||= 2
    end

    def retries
      @retries ||= 2
    end
    
    def password
      @password || raise("No password set for Comcetera")
    end

    def username
      @username || raise("No username set for Comcetera")
    end

    # Attempt an operator lookup based on msisdn.
    def detect(msisdn)
      attempts = 0
      while attempts <= self.retries
        attempts += 1
        begin
          Timeout::timeout(self.timeout) do
            body=open("http://api.comcetera.com/npl?user=#{self.username}&pass=#{self.password}&msisdn=#{msisdn}").read
            msisdn, operator_code = body.split("\n")[1].split(" ") # 2nd line, last word is the operator hexcode
            return new(:operator_code => operator_code, :msisdn => msisdn)
          end
        rescue Timeout::Error, SystemCallError => e
          # ignore
        end
      end
      nil
    end
  end
end
