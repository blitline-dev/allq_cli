class Peek < Base
  def process
    tube = ask_for_tube('Throttle')
    prompt = TTY::Prompt.new
    where = prompt.select('From where?', %w[ready buried])

    result = prompt.collect do
      key(:offset).ask('Offset?', convert: :int, default: 0)
    end
    offset = result[:offset]

    if where == 'ready'
      job = @client.peek_get(tube, offset: offset)
    elsif where == 'buried'
      job = @client.peek_get(tube, buried: true, offset: offset)
    end

    if job.body
      display_job(job)
    else
      puts 'No job found'
    end
  end
end
