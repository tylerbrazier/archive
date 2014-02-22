#!/usr/bin/env ruby

require 'mirrorworks/arg_handler'

class Mirrorworks

    def add(pair)
        raise "unimplemented"
    end

    def remove(pair)
        raise "unimplemented"
    end

    def pull(pair)
        raise "unimplemented"
    end

    def push(pair)
        raise "unimplemented"
    end

    def status(pair)
        raise "unimplemented"
    end

    private :add,
            :remove,
            :pull,
            :push,
            :status

    def run(args)

        $args = Arg_Handler.new(ARGV)

        case $args.operation
        when :add
            $args.reflections.each {|ref| add(ref)}
        when :remove
            $args.reflections.each {|ref| remove(ref)}
        when :pull
            $args.reflections.each {|ref| pull(ref)}
        when :push
            $args.reflections.each {|ref| push(ref)}
        when :status
            $args.reflections.each {|ref| status(ref)}
        end
    end

end # end class
