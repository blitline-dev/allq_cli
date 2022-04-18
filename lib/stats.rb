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
      return if stats.empty?

      tube_collection = stats
      key = tube_collection.delete('server_name')
      action_count = tube_collection.delete('action_count')
      job_get = tube_collection.delete('job_get')
      job_put = tube_collection.delete('job_put')
      vals = %w[ready reserved delayed buried parents avg tps]
      rows = []
      pastel = Pastel.new
      
      tube_collection.each do |tube, stats|
        ready = format(stats[vals[0]])
        reserved = format(stats[vals[1]])
        delayed = format(stats[vals[2]])
        buried = format(stats[vals[3]])
        parents = format(stats[vals[4]])
        avg = format(stats[vals[5]])
        tps = format(stats[vals[6]])

        rows << [tube, ready, reserved, delayed, buried, parents, avg, tps]
      end

      headers = ['tube'] + vals
      table = TTY::Table.new header: headers, rows: rows, width: 140, resize: false
      puts ''
      puts ' Server -> ' + key.to_s + ':'
      puts table.render(:unicode, padding: [0, 2, 0, 2])
      puts "Total Action Count: #{nice_number(action_count)}\nGets: #{nice_number(job_get)}\nPuts: #{nice_number(job_put)}"
    end
  end

  def get_stats_each
    raw_stats = @admin.stats_get
    raw_stats.each do |agg|
      final_stats = {}
      final_stats['action_count'] = final_stats['action_count'].to_i + agg.action_count.to_i
      final_stats['job_get'] = final_stats['job_get'].to_i + agg.job_get.to_i
      final_stats['job_put'] = final_stats['job_put'].to_i + agg.job_put.to_i
      final_stats['server_name'] = agg.server_name
      agg.stats.each do |tube_ref|
        name = tube_ref.tube
        final_stats[name] = {} unless final_stats[name]
        final_stats[name]['ready'] = final_stats[name]['ready'].to_i + tube_ref.ready.to_i
        final_stats[name]['reserved'] = final_stats[name]['reserved'].to_i + tube_ref.reserved.to_i
        final_stats[name]['delayed'] = final_stats[name]['delayed'].to_i + tube_ref.delayed.to_i
        final_stats[name]['buried'] = final_stats[name]['buried'].to_i + tube_ref.buried.to_i
        final_stats[name]['parents'] = final_stats[name]['parents'].to_i + tube_ref.parents.to_i
        if !tube_ref.tps.nil?
          final_stats[name]['avg'] = get_dynamic_avg(name + "avg", tube_ref.avg.to_f)
          final_stats[name]['tps'] = get_dynamic_avg(name + "tps", tube_ref.tps.to_f)
        else
          final_stats[name]['avg'] = -1
          final_stats[name]['tps'] = -1
        end

      end
      yield final_stats
    end
  end

  def get_stats_agg
    raw_stats = @admin.stats_get
    final_stats = {}

    raw_stats.each do |agg|
      if agg.stats.empty?
        puts 'Server found OK, but no data is in it'
        return {}
      end
      final_stats['action_count'] = final_stats['action_count'].to_i + agg.action_count.to_i
      final_stats['job_get'] = final_stats['job_get'].to_i + agg.job_get.to_i
      final_stats['job_put'] = final_stats['job_put'].to_i + agg.job_put.to_i
      agg.stats.each do |tube_ref|
        name = tube_ref.tube
        final_stats[name] = {} unless final_stats[name]
        final_stats[name]['ready'] = final_stats[name]['ready'].to_i + tube_ref.ready.to_i
        final_stats[name]['reserved'] = final_stats[name]['reserved'].to_i + tube_ref.reserved.to_i
        final_stats[name]['delayed'] = final_stats[name]['delayed'].to_i + tube_ref.delayed.to_i
        final_stats[name]['buried'] = final_stats[name]['buried'].to_i + tube_ref.buried.to_i
        final_stats[name]['parents'] = final_stats[name]['parents'].to_i + tube_ref.parents.to_i
        if !tube_ref.tps.nil?
          final_stats[name]['avg'] = get_dynamic_avg(name + "avg", tube_ref.avg.to_f)
          final_stats[name]['tps'] = get_dynamic_avg(name + "tps", tube_ref.tps.to_f)
        else
          final_stats[name]['avg'] = -1
          final_stats[name]['tps'] = -1
        end
      end
    end
    final_stats
  end

  def all
    stats = get_stats_agg
    return if stats.empty?

    global = stats.delete('action_count')
    job_get =  stats.delete('job_get')
    job_put =  stats.delete('job_put')

    headers = stats.keys.sort
    vals = %w[ready reserved delayed buried parents avg tps]
    rows = []
    stats.keys.sort.each do |tube|
      ready = format(stats[tube][vals[0]])
      reserved = format(stats[tube][vals[1]])
      delayed = format(stats[tube][vals[2]])
      buried = format(stats[tube][vals[3]])
      parents = format(stats[tube][vals[4]])
      avg = format(stats[tube][vals[5]])
      tps = format(stats[tube][vals[6]])

      rows << [tube, ready, reserved, delayed, buried, parents, avg, tps]
    end
    headers = ['tube'] + vals
    table = TTY::Table.new header: headers, rows: rows, width: 140, resize: false
    puts table.render(:unicode, padding: [0, 2, 0, 2])
    puts "Total Action Count: #{nice_number(global)}\nGets: #{nice_number(job_get)}\nPuts: #{nice_number(job_put)}"
  end

  def format(val)
    pastel = Pastel.new
    if val.to_i > 0
      return pastel.yellow(val.to_s)
    end
    val.to_s
  end
end
