#!/usr/bin/env ruby
require 'awesome_print'
require 'optparse'

module VBOX

  ALIASES  = {'clonevm'=>'clone', 'destroy'=>'delete', 'rm'=>'delete'}

  class CLI
    def initialize argv = ARGV
      @argv = argv
    end

    def banner
      bname = File.basename(__FILE__)
      r = []
      r <<  "USAGE:"
      r <<  "\t#{bname} [options]                           - list VMs"
      r <<  "\t#{bname} [options] <vm_name>                 - show VM params"
      r <<  "\t#{bname} [options] <vm_name> <param>=<value> - change VM params (name, cpus, usb, etc)"
      r <<  "\t#{bname} [options] <vm_name> <command>       - make some action (start, reset, etc) on VM"

      r <<  ""
      r <<  "COMMANDS:"
      (COMMANDS+['snapshots']).sort.each do |c|
        r <<  "\t#{c}"
      end
      r <<  ""
      r <<  "OPTIONS:"
      r.join("\n")
    end

    def run
      @options = { :verbose => 0 }
      optparser = OptionParser.new do |opts|
        opts.banner = banner

        opts.on "-m", "--[no-]multiple",
        "(default: auto) assume <vm_name> is a wildcard,",
        "and run on multiple VMs.",
        "All glob(7) patterns like *,?,[a-z] are supported",
        "plus additional pattern {1-20} which matches","a sequence of numbers: 1,2,3,...,19,20" do |x|
          @options[:multiple] = x
        end
        opts.on "-n", "--dry-run", "do not change anything, just print commands to be invoked" do
          @options[:dry_run] = true
        end
        opts.on "-v", "--verbose", "increase verbosity" do
          @options[:verbose] ||= 0
          @options[:verbose] += 1
        end
        opts.on "-c", "--clones N", Integer, "clone: make N clones" do |x|
          @options[:clones] = x
        end
        a = 'new last take make'.split.map{ |x| [x, x.upcase] }.flatten
        opts.on "-snapshot", "--snapshot MODE", a, "clone: use LAST shapshot or make NEW" do |x|
          @options[:snapshot] = x.downcase
        end
        opts.on "-H", "--headless", "start: start VM in headless mode" do
          @options[:headless] = true
        end
        opts.on "-h", "--help", "show this message" do
          puts @help
          exit
        end
      end
      @help = optparser.help
      @argv = optparser.parse(@argv)

      # disable glob matching if first arg is a UUID
      unless @options.key?(:multiple)
        @options[:multiple] = "{#{@argv.first}}" !~ UUID_RE
      end

      @vbox = VBOX::CmdLineAPI.new(@options)

      if @argv.size == 0 || @argv.last == 'list'
        vms = @vbox.list_vms
        @vbox.list_vms(:running => true).each do |vm|
          vms.find{ |vm1| vm1.uuid == vm.uuid }.state = :running
        end

        if @argv.size == 2 && @argv.last == 'list'
          if @options[:multiple]
            @globs = _expand_glob(@argv.first).flatten
            vms = vms.keep_if{ |vm| _fnmatch(vm.name) }
          else
            vms = vms.keep_if{ |vm| vm.name == @argv.first }
          end
        end

        longest = (vms.map(&:name).map(&:size)+[4]).max

        puts "%-*s %5s %6s  %-12s %s".gray % [longest, *%w'NAME MEM DIRSZ STATE UUID']
        vms.each do |vm|
          if @options[:verbose] > 0
            @vbox.get_vm_details vm
            state = (vm.state == :poweroff) ? '' : vm.state.to_s.upcase
            s = sprintf "%-*s %5d %6s  %-12s %s", longest, vm.name, vm.memory_size||0, vm.dir_size||0,
              state, vm.uuid
          else
            state = (vm.state == :poweroff) ? '' : vm.state.to_s.upcase
            s = sprintf "%-*s %5s %6s  %-12s %s", longest, vm.name, '', '',
              state, vm.uuid
          end
          s = s.green if vm.state == :running
          puts s
        end
      else
        name = @argv.shift
        cmd  = @argv.shift || 'show' # default command is 'show'

        cmd = ALIASES[cmd] if ALIASES[cmd]
        if @options[:multiple]
          _run_multiple_cmd cmd, name
        else
          _run_cmd cmd, name
        end
      end
    end

    # expand globs like "d{1-30}" to d1,d2,d3,d4,...,d29,d30
    def _expand_glob glob
      if glob[/\{(\d+)-(\d+)\}/]
        r = []
        $1.to_i.upto($2.to_i) do |i|
          r << _expand_glob(glob.sub($&,i.to_s))
        end
        r
      else
        [glob]
      end
    end

    def _fnmatch fname
      @globs.each do |glob|
        return true if File.fnmatch(glob, fname)
      end
      false
    end

    def _run_multiple_cmd cmd, name
      vms = @vbox.list_vms
      @globs = _expand_glob(name).flatten
      vms.each do |vm|
        if _fnmatch(vm.name)
          _run_cmd cmd, vm.name
        end
      end
    end

    def _run_cmd cmd, name
      if COMMANDS.include?(cmd)
        @vbox.send cmd, name
      elsif cmd['=']
        # set some variable, f.ex. "macaddress1=BADC0FFEE000"
        @vbox.modify name, *cmd.split('=',2)
      elsif cmd == 'snapshots'
        @vbox.get_snapshots(name).each do |x|
          printf "%s  %s\n", x.uuid, x.name
        end
      else
        STDERR.puts "[!] unknown command #{cmd.inspect}".red
        puts @help
        exit 1
      end
    end
  end

end


if $0 == __FILE__
  VBOX::CLI.new.run
end