class Clear < Base
  def process
    tube = ask_for_tube('DELETE')
    prompt = TTY::Prompt.new(color: :red)
    c = prompt.ask('CONFIRM: Retype name of queue you are deleting: ')
    if c == tube
      @client.tube_delete(tube)
      puts "DELETED #{tube}"
    else
      puts '...skipping'
    end
  end
end
