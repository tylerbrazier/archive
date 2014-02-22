#!/usr/bin/env ruby

require "optparse"

USAGE = "Usage: mirrorworks [options] [reflections]"

class Arg_Handler

    attr_reader :switches,
                :operation,
                :help_message,
                :reflections

    def initialize(cmd_line_args)
        @switches = {}
        @operation = nil
        @reflections = []

        desc = {}  # descriptions of options
        desc[:help]   = "Show this help message and exit"
        desc[:list]   = "List reflections"
        desc[:hard]   = "Delete extra files on transfer"
        desc[:add]    = "Add a new reflection"
        desc[:remove] = "Remove a reflection"
        desc[:pull]   = "Download/pull from remote to local"
        desc[:push]   = "Upload/push from local to remote"
        desc[:status] = "Do a push + pull dry run to check status"

        multi_oper_err = "Give only one operation"

        OptionParser.new do |opts|
            opts.banner = USAGE

            opts.on("-h", "--help", desc[:help]) do |o|
                @help_message = opts.to_s
                switches[:help] = o
            end

            opts.on("-l", "--list", desc[:list]) do |o|
                switches[:list] = o
            end

            opts.on("-x", "--hard", desc[:hard]) do |o|
                switches[:hard] = o
            end

            opts.on("-A", "--add", desc[:add]) do |o|
                raise multi_oper_err unless @operation.nil?
                @operation = :add
            end

            opts.on("-R", "--remove", desc[:remove]) do |o|
                raise multi_oper_err unless @operation.nil?
                @operation = :remove
            end

            opts.on("-D", "--pull", desc[:pull]) do |o|
                raise multi_oper_err unless @operation.nil?
                @operation = :pull
            end

            opts.on("-U", "--push", desc[:push]) do |o|
                raise multi_oper_err unless @operation.nil?
                @operation = :push
            end

            opts.on("-S", "--status", desc[:status]) do |o|
                raise multi_oper_err unless @operation.nil?
                @operation = :status
            end
        end.parse! cmd_line_args # parse options and remove them from args

        if cmd_line_args.empty?
            puts "empty test"
        else
            puts "not empty"
        end
    end # end initialize
end # end class
