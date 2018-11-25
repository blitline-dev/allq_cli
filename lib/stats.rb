require_relative 'base'

class Stats < Base

  def process(t)
    if t == :all
      all
    elsif t == :each
      each
    else
      raise "#{t} : Not supported"
    end
    puts
  end

  def each
    get_stats_each do |stats|
      global = stats["action_count"].to_i
      headers = []
      vals = %w{ready reserved delayed buried parents}
      rows = []
      tube_collection = stats
			action_count = tube_collection.delete("action_count")
			key = tube_collection.delete("server_name")
			headers = []
			tube_collection.each do |name, tube|
        headers << name
		    vals.each_with_index do |v, i|
    		   st = tube
       		 rows[i] = [] unless rows[i]
       		 rows[i] << get_text(v, st[v])
    		end
      end
      puts ""
      puts " Server -> " + key.to_s + ":"
      table = TTY::Table.new header: headers, rows: rows,  width: 140, resize: true
      puts table.render(:unicode,  padding: [0,2,0,2])
    end
  end

  def get_stats_each
        raw_stats = @admin.stats_get

        raw_stats.each do |agg|
					final_stats = {}
          final_stats["action_count"] = final_stats["action_count"].to_i + agg.action_count.to_i
					final_stats["server_name"] = agg.server_name
          agg.stats.each do |tube_ref|
            name = tube_ref.tube
            final_stats[name] = {} unless final_stats[name]
            final_stats[name]["ready"] = final_stats[name]["ready"].to_i + tube_ref.ready.to_i
            final_stats[name]["reserved"] = final_stats[name]["reserved"].to_i + tube_ref.reserved.to_i
            final_stats[name]["delayed"] = final_stats[name]["delayed"].to_i + tube_ref.delayed.to_i
            final_stats[name]["buried"] = final_stats[name]["buried"].to_i + tube_ref.buried.to_i
            final_stats[name]["parents"] = final_stats[name]["parents"].to_i + tube_ref.parents.to_i
          end
          yield final_stats
        end
  end

  def get_stats_agg
        raw_stats = @admin.stats_get
        final_stats = {}

        raw_stats.each do |agg|
					final_stats["action_count"] = final_stats["action_count"].to_i + agg.action_count.to_i
          agg.stats.each do |tube_ref|
            name = tube_ref.tube
            final_stats[name] = {} unless final_stats[name]
            final_stats[name]["ready"] = final_stats[name]["ready"].to_i + tube_ref.ready.to_i
            final_stats[name]["reserved"] = final_stats[name]["reserved"].to_i + tube_ref.reserved.to_i
            final_stats[name]["delayed"] = final_stats[name]["delayed"].to_i + tube_ref.delayed.to_i
            final_stats[name]["buried"] = final_stats[name]["buried"].to_i + tube_ref.buried.to_i
            final_stats[name]["parents"] = final_stats[name]["parents"].to_i + tube_ref.parents.to_i
          end 
        end
        return final_stats
  end

  def all
    stats = get_stats_agg
    puts "Failed to get stats!" unless stats && stats.to_s.size > 0
    global = stats.delete("action_count")
    headers = stats.keys.sort
    vals = %w{ready reserved delayed buried parents}
    rows = []
    vals.each_with_index do |v, i|
      headers.each  do |h|
        st = stats[h]
        rows[i] = [] unless rows[i]
        rows[i] << get_text(v, st[v])
      end
    end

    table = TTY::Table.new header: headers, rows: rows, width: 140, resize: false
    puts table.render(:unicode,  padding: [0,2,0,2])
    puts "Total Action Count: #{nice_number(global)}"
  end

end

