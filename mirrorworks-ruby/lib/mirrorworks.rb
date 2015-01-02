require 'optparse'
require 'fileutils'
require 'rsync'
require 'json'

VERSION = '0.2.1'
CONF_AT = File.join(Dir.home, '.mirrorworksrc.json')

class Mirrorworks

  def initialize
    @conf = {}
  end

  private

  def parse_config
    unless File.readable? CONF_AT
      raise "Can't read #{CONF_AT}. Use 'setup' command to make example conf."
    end
    File.open(CONF_AT, 'r') {|f| @conf = JSON.parse(f.read)}
  end

  def each_reflection(args)
    if args.empty?
      # use all reflections if none are given
      @conf['reflections'].each {|ref| yield ref}
    else
      args.each do |arg|
        selected = nil
        @conf['reflections'].each do |ref|
          if arg == ref['name']
            selected = ref
            break
          end
        end
        if selected.nil?
          raise "No reflection '#{arg}'"
        else
          yield selected
        end
      end
    end
  end

  def setup
    src = File.join(File.dirname(__FILE__), '..', 'example.mirrorworksrc.json')
    raise "#{CONF_AT} already exists. Nothing to do." if File.exists? CONF_AT
    FileUtils.cp(src, CONF_AT)
    puts "Created example config at #{CONF_AT}"
  end

  def transfer(src, dest, runtime_vars)
    src = src.gsub(' ', '\ ').gsub('(', '\(').gsub(')', '\)')
    dest = dest.gsub(' ', '\ ').gsub('(', '\(').gsub(')', '\)')
    opts = @conf['rsync_opts']
    opts << '--delete' if runtime_vars[:hard]
    opts << '--dry-run' if runtime_vars[:dry]
    puts "rsync #{opts.join(' ')} #{src} #{dest}" if runtime_vars[:verbose]
    result = Rsync.run(src, dest, opts)
    raise result.error unless result.success?
    result.changes.each do |c|
      unless c.update_type == :no_update
        summary = c.summary.empty? ? "\t" : c.summary
        puts summary << "\t" << c.filename
      end
    end
  end

  def push(args, runtime_vars)
    each_reflection(args) do |ref|
      mode = ref['pushmode'].nil? ? 'soft' : ref['pushmode'].downcase
      if mode == 'ignore'
        puts "---- Ignoring push for #{ref['name']} ----"
      else
        runtime_vars[:hard] = true if mode == 'hard'
        puts ">>>> Pushing #{ref['name']} >>>>"
        src = ref['local']
        dest = ref['remote']
        transfer(src, dest, runtime_vars)
      end
      puts
    end
  end

  def pull(args, runtime_vars)
    each_reflection(args) do |ref|
      mode = ref['pullmode'].nil? ? 'soft' : ref['pullmode'].downcase
      if mode == 'ignore'
        puts "---- Ignoring pull for #{ref['name']} ----"
      else
        runtime_vars[:hard] = true if mode == 'hard'
        puts "<<<< Pulling #{ref['name']} <<<<"
        src = ref['remote']
        dest = ref['local']
        transfer(src, dest, runtime_vars)
      end
      puts
    end
  end

  def status(args, runtime_vars)
    puts 'Starting dry run. No changes will be made.'
    puts
    runtime_vars[:dry] = true
    push(args, runtime_vars)
    pull(args, runtime_vars)
    puts 'End of dry run.'
  end

  def list(args)
    each_reflection(args) do |ref|
      puts "Name: #{ref['name']}",
           "  Local:    #{ref['local']}",
           "  Remote:   #{ref['remote']}",
           "  Pushmode: #{ref['pushmode'].nil? ?
                          'soft' : ref['pushmode'].downcase}",
           "  Pullmode: #{ref['pullmode'].nil? ?
                          'soft' : ref['pullmode'].downcase}",
           ''
    end
  end

  def version
    puts VERSION
    exit
  end

  def help(opts_msg)
    puts opts_msg
    puts '',
         '  Commands:',
         '    setup       create example conf in home directory',
         '    push        push from local to remote',
         '    pull        pull from remote to local',
         '    status      get status of reflections',
         '    list        list reflections',
         '',
         "Reads json configuration file from #{CONF_AT}.",
         'All reflections will be used when none are specified.',
         'See the README.md for more information.'
    exit
  end

  public

  def run(args)
    begin
      runtime_vars = {}
      opts_msg = ''
      OptionParser.new do |opts|
        opts.banner = "Usage: mirrorworks [options] <command> [reflections]\n"
        opts.banner += '  Options:'
        opts.on('-V', '--version', 'print version and exit') {version}
        opts.on('-h', '--help', 'print help and exit') {help(opts_msg)}
        opts.on('-v', '--verbose', 'show rsync command when executing') do |v|
          runtime_vars[:verbose] = v
        end
        opts.on('-x', '--hard', 'delete extra files on transfer') do |x|
          runtime_vars[:hard] = x
        end
        opts_msg = opts.to_s
      end.parse! args

      help(opts_msg) if args.empty?

      command = args.shift
      parse_config unless command == 'setup'
      case command
      when 'push'
        push args, runtime_vars
      when 'pull'
        pull args, runtime_vars
      when 'status'
        status args, runtime_vars
      when 'list'
        list args
      when 'setup'
        setup
      else
        raise "No command '#{command}'"
      end
    rescue Exception => e
      puts e.message unless e.is_a? SystemExit
    end
  end
end
