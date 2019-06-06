class ApplicationConsumer < Racecar::Consumer
  def with_metrics
    puts PrometheusExporter::Client.default.inspect
    start = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    yield
  rescue RuntimeError => e
    raise e
  ensure
    duration = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - start
    PrometheusExporter::Client.default.send_json(
      type: 'racecar',
      name: self.class.name,
      duration: duration
    )
  end
end
