class Base
  def initialize
    url = base_url
    allq_conf = Allq::Configuration.new do |config|
      config.host = url
    end

    raw_client = Allq::ApiClient.new(allq_conf)
    @client = Allq::ActionsApi.new(raw_client)
    @admin = Allq::AdminApi.new(raw_client)
    @dynamic_average = {}
  end

  def base_url
    ENV['ALLQ_LOCAL_URL'] || '127.0.0.1:8090'
  end

  def get_text(v, num)
    if v == 'ready'
      "\033[35;1m" + v + ' ' + nice_number(num) + "\033[0m"
    elsif v == 'reserved'
      "\033[32;1m" + v + ' ' + nice_number(num) + "\033[0m"
    else
      v + ' ' + nice_number(num)
    end
  end

  def nice_number(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
   end

  def ask_for_tube(action)
    prompt = TTY::Prompt.new(active_color: :cyan)
    tube = prompt.select("#{action}: Which tube?", get_all_tube_names)
    tube
  end

  def get_number(question)
    prompt = TTY::Prompt.new
    n = prompt.ask(question) do |q|
      q.required true
      q.validate /[0-9]*/
    end
    n.to_i
  end

  def display_job(job)
    table = TTY::Table.new(multiline: true, column_widths: [30, 60]) do |t|
      t << ['job_id', job.id]
      t << ['expireds', job.expireds]
      t << ['releases', job.releases]
      t << ['body', "\e[3m(see below)\e[0m"]
    end
    puts table.render(:unicode, padding: [0, 2, 0, 2])
    puts job.body
  end

  def get_all_tube_names
    raw_stats = @admin.stats_get
    final_stats = {}

    raw_stats.each do |agg|
      agg.stats.each do |tube_ref|
        name = tube_ref.tube
        final_stats[name] = {} unless final_stats[name]
      end
    end

    final_stats.keys
  end

  def get_dynamic_avg(name, val)
    @dynamic_average[name] = [] if @dynamic_average[name].nil?
    @dynamic_average[name] << val
    output = @dynamic_average[name].sum(0.0) / @dynamic_average[name].size
    output.round(2)
  end



end
