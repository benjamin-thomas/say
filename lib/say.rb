require 'fileutils'
require 'digest/sha2'
require 'cgi'
require 'logger'

class AudioSample
  def initialize(opts)
    @message = opts.fetch(:message)
    @lang = opts.fetch(:lang)
    @sleep = opts.fetch(:sleep)
    @repeat = opts.fetch(:repeat)
    @dir = opts[:folder] ||= "#{ENV['HOME']}/Documents/AudioSamples/#{@lang}"

    @filename = digest_filename
    @filepath = "#{@dir}/#{@filename}"

    # FIXME: buggy
    #log_file = File.dirname(__FILE__) + '/../log/say.log'

    @log = Logger.new(STDOUT)
    create_missing_dirs
    download unless File.exists? @filepath
  end

  def play
    sleep_for(@sleep)

    loop do
      play_chime

      @log.info { "Playing: #{@filepath}" }
      system %Q_mplayer "#{@filepath}" >/dev/null 2>&1_
      sleep_for(@repeat)
    end
  end

  private

  def play_chime
    root_path = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    chime_path =  "#{root_path}/assets/sounds/chime.mp3"
    system %Q_mplayer "#{chime_path}" >/dev/null 2>&1_
    sleep 1
  end

  def sleep_for(given_value)
    return if given_value.nil?

    sleep_value = convert_time_value(given_value)
    @log.info { "Sleeping #{given_value} (#{sleep_value}s)" }
    sleep sleep_value
  end

  def convert_time_value(given_value)
    if given_value.end_with? "s"
      sleep_value = given_value.to_i
    elsif given_value.end_with? "m"
      sleep_value = given_value.to_i * 60
    elsif given_value.end_with? "h"
      sleep_value = given_value.to_i * 60 ** 2
    else
      sleep_value = given_value.to_i
    end
  end

  def digest_filename
    "#{Digest::SHA256.hexdigest(@message)}.mp3"
  end

  def download
    query = CGI.escape(@message)
    url = "http://translate.google.com/translate_tts?tl=#{@lang}&q=#{query}"
    cmd = %Q_mplayer -user-agent "Mozilla/5.0" "#{url}" -dumpstream -dumpfile "#{@filepath}" >/dev/null 2>&1_

    if !File.exist?(@filepath)
      warn("Could not create: #{@filepath}")
      exit 1
    end

    @log.info { "Message downloaded: #{@message}." }
    system cmd
  end

  def create_missing_dirs
    unless Dir.exists? @dir
      FileUtils.mkdir_p @dir
      @log.info { "Directory created: #{@dir}." }
    end
  end
end # class AudioSample
