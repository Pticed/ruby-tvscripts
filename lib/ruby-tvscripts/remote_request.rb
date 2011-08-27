class RemoteRequest
  def initialize(method)
    method = 'get' if method.nil?
    @opener = self.class.const_get(method.capitalize)
  end

  def read(url)
    data = @opener.read(url)
    data
  end

  private
    class Get
      def self.read(url)
        attempt_number=0
        errors=""
        begin
          attempt_number=attempt_number+1
          if (attempt_number > 10) then
            return nil
          end

          file = Net::HTTP.get_response URI.parse(url)
          if (file.message != "OK") then
            raise InvalidResponseFromFeed, file.message
          end
        rescue Timeout::Error => err
          puts "Timeout Error: #{err}, sleeping for 10 secs, and trying again (Attempt #{attempt_number})."
          sleep 10
          retry
        rescue Errno::ECONNREFUSED => err
          puts "Connection Error: #{err}, sleeping for 10 secs, and trying again (Attempt #{attempt_number})."
          sleep 10
          retry
        rescue SocketError => exception
          puts "Socket Error: #{exception}, sleeping for 10 secs, and trying again (Attempt #{attempt_number})."
          sleep 10
          retry
        rescue EOFError => exception
          puts "Socket Error: #{exception}, sleeping for 10 secs, and trying again (Attempt #{attempt_number})."
          sleep 10
          retry
        rescue InvalidResponseFromFeed => err
          puts "Invalid response: #{err}, sleeping for 10 secs, and trying again (Attempt #{attempt_number})."
          sleep 10
          retry
        rescue => err
          puts "Invalid response: #{err}, sleeping for 10 secs, and trying again (Attempt #{attempt_number})."
          sleep 10
          retry
        else
          return file.plain_body
        end
      end
    end
end

class InvalidResponseFromFeed < RuntimeError
  def initialize(info)
  @info = info
  end
end
