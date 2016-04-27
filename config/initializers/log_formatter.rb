class Logger::RakudaFormat < Logger::Formatter
  include ActiveSupport::TaggedLogging::Formatter
  def call(severity, timestamp, program, message)
    format = "[%s] %5s: %s\n"
    format % ["#{timestamp.to_s(:db)}", severity, msg2str(message)]
  end
end

class Logger::RakudaTraceFormat < Logger::Formatter
  include ActiveSupport::TaggedLogging::Formatter
  def call(severity, timestamp, program, message)
    format = "[%s] %s\n"
    format % ["#{timestamp.to_s(:db)}", msg2str(message)]
  end
end
