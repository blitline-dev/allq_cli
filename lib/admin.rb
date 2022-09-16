class Admin < Base
  def process
    prompt = TTY::Prompt.new
    what = prompt.select('Admin Action', %w[get_all_reserved])

    raise "You must have 'socat' installed on your machine for this to work" unless system("socat -h &>/dev/null")

    get_all_reserved if what == 'get_all_reserved'
  end

  def get_all_reserved
    data = {
      'action' => 'admin',
      'params' => {
        'action_type' => 'get_reserved_jobs'
      }
    }
    begin
      all = call_raw_socat(data)
      all_hash = all['result']
      all_hash.each do |k,v|
        parsed = JSON.parse(v)
        if parsed['body']
          parsed['body'] = Base64.decode64(parsed['body'])
        end
        ap parsed
      end
    rescue => ex
      puts "Couldn't get data from server"
      puts ex.full_message
    end
  end
end
