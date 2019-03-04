class ClearBuried < Base
  def process
    tube = ask_for_tube('DELETE')

    job = @client.peek_get(tube, buried: true)
    while job && job.id do
	@client.job_delete(job.id)
        job = @client.peek_get(tube, buried: true)
    end

  end
end
