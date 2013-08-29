#!/usr/bin/env ruby-local-exec

require 'fileutils'
require 'digest/sha2'
require 'cgi'
require 'logger'

class AudioSample
  def initialize(opts)
    @message = opts[:message]
    @lang = opts[:lang] ||= "en"
    @dir = opts[:folder] ||= "#{ENV['HOME']}/Documents/AudioSamples/#{@lang}"

    @filename = digest_filename
    @filepath = "#{@dir}/#{@filename}"


    log_file = File.dirname(__FILE__) + '/../log/say.log'
    @log = Logger.new(log_file)
    create_missing_dirs
    download unless File.exists? @filepath
  end

  def play
    @log.info { "Playing: #{@filepath}" }
    system %Q_mplayer "#{@filepath}" >/dev/null 2>&1_
  end

  private

  def digest_filename
    "#{Digest::SHA256.hexdigest(@message)}.mp3"
  end

  def download
    query = CGI.escape(@message)
    url = "http://translate.google.com/translate_tts?tl=#{@lang}&q=#{query}"
    cmd = %Q_mplayer -user-agent "Mozilla/5.0" "#{url}" -dumpstream -dumpfile "#{@filepath}" >/dev/null 2>&1_
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

def say(message)
  as = AudioSample.new(message: message)
  as.play
end

