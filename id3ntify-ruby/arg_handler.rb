#!/usr/bin/ruby

require 'optparse'

USAGE = "Usage: tag.rb [options] files/dirs"
TAGS = [:all,:title,:artist,:album,:track,:genre,:year,:comment,:cover]

class Arg_Handler

    attr_reader :versions_to_strip,
                :tags_to_clear,
                :tags_to_set,
                :tags_to_edit,
                :switches,
                :help_message,
                :files

    def initialize(args)
        @versions_to_strip = []
        @tags_to_clear = []
        @tags_to_set = {}
        @tags_to_edit = []
        @switches = {}
        @files = []

        desc = {}   # descriptions for options
        desc[:strip]   = "Strip all ID3v[1,2] tags from files"
        desc[:clear]   = "Clear TAGS from each file"
        desc[:set]     = "Set each TAG=value for each file"
        desc[:edit]    = "Will be prompted to edit TAGS for each file"
        desc[:purge]   = "Remove all frames other than TAGS from ID3v2 tags"
        desc[:list]    = "List tag data for the files"
        desc[:verbose] = "Run verbosely"
        desc[:help]    = "Show this message and exit"
        OptionParser.new do |opts|
            opts.banner = USAGE

            # strip
            opts.on("--strip [1,2]", Array, desc[:strip]) do |versions|
                err_msg = "Invalid version argument for --strip"
                raise err_msg unless versions.size < 3

                versions.each do |v|
                    v = v.to_i
                    raise err_msg if v != 1 && v != 2
                    @versions_to_strip << v
                end
            end

            # clear
            opts.on("--clear [TAGS]", Array, desc[:clear]) do |tags|
                err_msg = "Invalid tag argument for --clear"

                tags.each do |tag|
                    tag = tag.to_sym
                    raise err_msg unless TAGS.include? tag
                    @tags_to_clear << tag
                end
            end

            # set
            opts.on("--set [TAG=value,...]", Array, desc[:set]) do |pairs|
                err_msg = "Invalid argument for --set"

                pairs.each do |pair|
                    spl = pair.split("=")

                    raise err_msg unless spl.size == 2

                    tag = spl[0].to_sym
                    raise err_msg unless TAGS.include? tag

                    @tags_to_set[tag] = spl[1]
                end
            end

            # edit
            opts.on("--edit [TAGS]", Array, desc[:edit]) do |tags|
                err_msg = "Invalid tag argument for --edit"

                tags.each do |tag|
                    tag = tag.to_sym
                    raise err_msg unless TAGS.include? tag
                    @tags_to_edit << tag
                end
            end

            # purge
            opts.on("-p", "--purge", desc[:purge]) do |p|
                @switches[:purge] = p
            end

            # list
            opts.on("-l", "--list", desc[:list]) do |l|
                @switches[:list] = l
            end

            # verbose
            opts.on("-v", "--verbose", desc[:verbose]) do |v|
                @switches[:verbose] = v
            end

            # help
            opts.on("-h", "--help", desc[:help]) do |h|
                @switches[:help] = h
                @help_message = opts.to_s
            end

        end.parse! args # parse options and remove them from args

        # parse the non-option args
        raise "Supply at least one file/dir" if args.empty?
        args.each do |arg|
            raise "File '#{arg}' doesn't exist" unless File.exists? arg
            @files << File.absolute_path(arg)
        end

    end # end initialize
end # end class

