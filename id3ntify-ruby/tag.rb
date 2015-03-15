#!/usr/bin/env ruby

require 'taglib'

$args = Arg_Handler.new ARGV

# Called by set and edit methods. This does not check if img_path is good
# TODO mime type?
def set_pic(tag, img_path)
    return unless tag.class == TagLib::ID3v2::Tag

    # first remove existing (is this necessary?)
    tag.remove_frames('APIC')

    pic = TagLib::ID3v2::AttachedPictureFrame.new
    pic.description = "Cover"
    pic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
    pic.picture = File.open(img_path, 'rb') {|f| f.read}
    tag.add_frame(pic)
end


def clear(tag)
    $args.tags_to_clear.each do |type|
        if type == :cover
            tag.remove_frames('APIC') if tag.class == TagLib::ID3v2::Tag
        else
            # dynamic method call :)
            tag.send("#{type}=", nil)
        end
    end
end


def set(tag)
    $args.tags_to_set.each do |type,value|
        if type == :cover
            # check if file is readable
            raise "Unable to read #{value}" unless File.file?(value)
            set_pic (tag, value)
        else
            # dynamic method call :)
            tag.send("#{type}=", value)
        end
    end
end


def edit(tags)
    types = $args.tags_to_edit
    edits = {}
    if types.include? :all || types.include? :title
        print "Title: "
        edits[:title] = gets.chomp
    end
    if types.include? :all || types.include? :artist
        print "Artist: "
        edits[:artist] = gets.chomp
    end
    if types.include? :all || types.include? :album
        print "Album: "
        edits[:album] = gets.chomp
    end
    if types.include? :all || types.include? :track
        loop do
            print "Track: "
            edits[:track] = gets.chomp.to_i
            break if edits[:track] != 0
        end
    end
    if types.include? :all || types.include? :genre
        print "Genre: "
        edits[:genre] = gets.chomp
    end
    if types.include? :all || types.include? :year
        loop do
            print "Year: "
            edits[:year] = gets.chomp.to_i
            break if edits[:year] != 0
        end
    end
    if types.include? :all || types.include? :comment
        print "Comment: "
        edits[:comment] = gets.chomp
    end
    if types.include? :all || types.include? :cover
        loop do
            print "Cover (path): "
            edits[:cover] = gets.chomp
            break if File.file? (edits[:cover])
        end
    end

    tags.each do |tag|
        edits.each_pair do |k,v|
            if k == :cover
                set_pic (tag, v)
            else
                # dynamic method call :)
                tag.send("#{k}=", v)
            end
        end
    end
end


# Does not check if tag is correct type
def purge(tag)
    ### TODO how should i do this?
    #keep = ['TIT2','TOPE','TALB','TRCK','....']
    # or
#    keep = {}
#    keep[:title] = tag.title
#    keep[:artist] = tag.artist
#    keep[:album] = tag.album
#    keep[:track] = tag.track
#    keep[:genre] = tag.genre
#    keep[:year] = tag.year
#    keep[:comment] = tag.comment
    # and assign them again after removing everything?

    tag.frame_list.each do |frame|
        # do stuff here
    end
end


def process(filename)
    puts filename

    # NOTE it's important that we don't raise from here bc file needs to close
    TagLib::MPEG::File.open(filename) do |mp3file|
        begin
            tags = []
            if $args.versions_to_strip.include? (1)
                good = mp3file.strip(tags=TagLib::MPEG::File::ID3v1)
                raise "Unable to strip ID3v1 tags from #{filename}" unless good
            else
                tags << mp3file.id3v1_tag(create=true)
            end

            if $args.versions_to_strip.include? (2)
                good = !mp3file.strip(tags=TagLib::MPEG::File::ID3v2)
                raise "Unable to strip ID3v2 tags from #{filename}" unless good
            else
                tags << mp3file.id3v2_tag(create=true)
            end

            # clear
            tags.each {|tag| clear(tag)}

            # set
            tags.each {|tag| set(tag)}

            # edit
            edit(tags)

            # purge
            tags.each {|tag| purge(tag) if tag.class == TagLib::ID3v2::Tag}

        rescue Exception => e
            mp3file.save  # TODO do this here?
            puts e.message
        end
    end
end

def old_process(filename)
        tag = mp3file.id3v2_tag create=true # create id3v2 tag if doesn't exist
        data = {}
        data[:title]   = tag.title
        data[:artist]  = tag.artist
        data[:album]   = tag.album
        data[:track]   = tag.track
        data[:genre]   = tag.genre
        data[:year]    = tag.year
        data[:comment] = tag.comment
        data[:cover]   = tag.frame_list('APIC').join(',')
        if $options[:list]
            puts "Title:   #{data[:title]}"
            puts "Artist:  #{data[:artist]}"
            puts "Album:   #{data[:album]}"
            puts "Track:   #{data[:track]}"
            puts "Genre:   #{data[:genre]}"
            puts "Year:    #{data[:year]}"
            puts "Comment: #{data[:comment]}"
            puts "Cover:   #{data[:cover]}"
        end
        if $options[:strip] || $clear.include?("all")
            unless mp3file.strip then puts "Unable to strip #{filename}!" end
        else
            $clear.each do |tag_to_clear|
                case tag_to_clear
                when "title"
                    tag.title = nil
                when "artist"
                    tag.artist = nil
                when "album"
                    tag.album = nil
                when "track"
                    tag.track = nil
                when "genre"
                    tag.genre = nil
                when "year"
                    tag.year = nil
                when "comment"
                    tag.comment = nil
                when "cover"
                    tag.remove_frames('APIC')
                end
            end
        end
        frames = tag.frame_list
        frames.each do |frame|
            puts "#{frame.frame_id} #{frame.to_s}"
        end

        #puts tag.frame_list('TIT2').first.to_s

        #puts tag.frame_list.size
#        framelist = tag.frame_list
#        framelist.each {|frame| tag.remove_frame frame}
#        cover = tag.frame_list('APIC')
#        puts "APICs #{cover.size}"

        # strip returns true on success
        #if $options[:strip] then mp3file.strip end
        unless mp3file.save(tags=TagLib::MPEG::File::ID3v2, strip_others=true)
            puts "Unable to save #{filename}!"
        end
    end
end


if $args.switchs[:help]
    puts $args.help_message
    # TODO maybe more info if verbose?
    exit 0
end

# process for each argument
$args.files.each do |path|
    if File.directory? (path)
        Dir.glob("#{path}/**/*.mp3") {|filename| process(filename)}
    else
        process(path)
    end
end
