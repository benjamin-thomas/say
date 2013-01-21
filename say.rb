#!/usr/bin/env ruby-local-exec

require 'fileutils'
require 'digest/sha2'
require 'cgi'

def play_audio(file)
  system %Q_mplayer "#{file}"_
end

def download_audio(msg)
  user_agent = "Mozilla/5.0"
  lang = "en"
  query = CGI.escape(msg)
  url = "http://translate.google.com/translate_tts?tl=#{lang}&q=#{query}"
  system %Q_mplayer -user-agent "Mozilla/5.0" "#{msg}" -dumpstream -dumpfile "#{out_file}"_
end

audio_sample_dir="#{ENV['HOME']}/Documents/AudioSamples"

unless Dir.exists? audio_sample_dir
  FileUtils.mkdir_p audio_sample_dir
end

say_msg = ARGV.join(" ")
mp3_file="#{audio_sample_dir}/#{Digest::SHA256.hexdigest(say_msg)}.mp3"

if File.exists? mp3_file
  play_audio mp3_file
else
  download_audio say_msg
  play_audio mp3_file
end

#
# if [[ -f $mp3_file ]]; then
#   mplayer "$mp3_file";
# else
#   mplayer -user-agent \
#     "Mozilla/5.0" "http://translate.google.com/translate_tts?tl=en&q=$(echo $* | sed 's#\ #\+#g')" \
#     -dumpstream -dumpfile "$mp3_file" >/dev/null 2>&1;
#   echo playing $mp3_file
#   mplayer "$mp3_file" >/dev/null 2>&1;
# fi
