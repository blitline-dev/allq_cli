class ClearBuried < Base
  def process
    tube = ask_for_tube('DELETE')

    what_to_do = prompt.select('Delete or Kick?', %w[delete kick])


    job = @client.peek_get(tube, buried: true)
    while job && job.id do
        if what_to_do == 'delete'
        	@client.job_delete(job.id)
        else
          @client.kick_put(tube)
        end
        job = @client.peek_get(tube, buried: true)
    end

  end
end
