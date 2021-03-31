add-type -a system.speech
$s=[Speech.Synthesis.SpeechSynthesizer]::new()
$s.Speak("I'm Byteman")
$s|% d*