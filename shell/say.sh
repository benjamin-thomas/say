AUDIO_SAMPLE_DIR="$HOME/Documents/AudioSamples"
[ -d "$AUDIO_SAMPLE_DIR" ] || mkdir -p "$AUDIO_SAMPLE_DIR"

MP3_FILE="$AUDIO_SAMPLE_DIR/$(echo $@ | sha256sum | cut -d' ' -f1).mp3"

if [[ -f $MP3_FILE ]]; then
  mplayer "$MP3_FILE";
else
  mplayer -user-agent \
    "Mozilla/5.0" "http://translate.google.com/translate_tts?tl=en&q=$(echo $* | sed 's#\ #\+#g')" \
    -dumpstream -dumpfile "$MP3_FILE" >/dev/null 2>&1;
  echo playing $MP3_FILE
  mplayer "$MP3_FILE" >/dev/null 2>&1;
fi
