class Throttle < Base
  def process
    tube = ask_for_tube('Throttle')
    tps = get_number('Set to what TPS?')
    throttle = Allq::Throttle.new(tps: tps, tube: 'throttled')
    @client.throttle_post(tube, throttle)
    puts 'Throttle set'
  end
end
