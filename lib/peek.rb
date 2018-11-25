class Peek < Base
  def process
    tube = ask_for_tube("Throttle")
    prompt = TTY::Prompt.new
    where = prompt.select("From where?", %w(ready buried))
		if where == "ready"
			job = @client.peek_get(tube)
    elsif where == "buried"
      job = @client.peek_get(tube, buried: true)
    end
		if job.body
      display_job(job)
    else
	    puts "No job found"
    end
  end
end
