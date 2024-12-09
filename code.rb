# Piece length in seconds
piece_length = 60 * 5
#piece_length = 20 # For testing purposes
ii_length = piece_length*0.4
V_length  = piece_length*0.2
I_length  = piece_length*0.3
# base_iterations = 2
base_iterations = 32
ii_iterations = base_iterations
V_iterations = base_iterations
I_iterations = base_iterations

# 3 sections of the piece:
#  ii - 1.5 minutes of dancing around the ii chord
#  V  - 1.5 minutes on the V
#  I  - 3 minutes
# Going to run it in Fmaj so that the US dialtone (440a4, 350f4) can be present at the end (although my drone will be an octave or so lower)
# ii - Gmin
# V  - Cmaj
# I  - Fmaj
def drone_attack(len)
  return len*0.05
end
def drone_sustain(len)
  return len*0.85
end
def drone_release(len)
  return len*0.2 # let it bleed
end

##########
# DRONES #
##########
in_thread do
  drones = [[[:g3, :bb2], ii_length],  # I may switch it to a bb to be in the key, but I think the dissonance could be fun
            [[:c3, :e3], V_length],
            [[:f3, :a3], I_length]]
  drones.each do |notes, length|
    use_synth :beep
    play notes, attack: drone_attack(length), sustain: drone_sustain(length), release: drone_release(length)
    sleep length
  end
end


def pattack(len, iterations)
  return (len/iterations)*0.1
end
def psustain(len, iterations)
  return (len/iterations)*0.8
end
def prelease(len, iterations)
  return (len/iterations)*0.11 # let it bleed a little
end

##########
# CHORDS #
##########
in_thread do
  use_synth :beep
  sections = [[[chord(:g, :m7), chord(:g, :m9), chord(:g, :m11)], [ii_length, ii_iterations]],
              [[chord(:c, :major7), chord(:c, :maj9), chord(:c, :dom7)], [V_length, V_iterations]],
              [[chord(:f, :major), chord(:f, :major7)], [I_length, I_iterations]]]
  sections.each do |chord_options, (length, iterations)|
    iterations.times do
      curr = choose(chord_options)
      curr = invert_chord(curr, rrand_i(0, 4))
      play curr, attack: pattack(length, iterations), sustain: psustain(length, iterations), release: prelease(length, iterations), amp: 0.6
      sleep length/iterations
    end
  end
end

#########
# NOISE #
#########
in_thread do
  use_synth :noise
  noises = [[:g3, ii_length],  # I may switch it to a bb to be in the key, but I think the dissonance could be fun
            [:c3, V_length],
            [:f3, I_length]]
  noises.each do |note, length|
    play note, attack: drone_attack(length), sustain: drone_sustain(length), release: drone_release(length), amp: 0.1
    sleep length
  end
end

##########
# MELODY #
##########
#               1209 Hz	1336 Hz 1477 Hz 1633 Hz
#697 Hz 	1ⓘ 	2ⓘ 	3ⓘ 	Aⓘ
#770 Hz 	4ⓘ 	5ⓘ 	6ⓘ 	Bⓘ
#852 Hz 	7ⓘ 	8ⓘ 	9ⓘ 	Cⓘ
#941 Hz 	*ⓘ 	0ⓘ 	#ⓘ 	Dⓘ
# 1209: ~D#
# 1336: ~E
# 1477: ~F#
# 1633: ~G#
#  697: ~F
#  770: ~G
#  852: ~G#
#  941: ~A#
# These pitches don't make much sense in Fmaj of which the composite pitches are:
# F, G, A, A#, C, D, E
# The phone pitches are D#, E, F, F#, G, G#, A#
# The intervals are       h  h  h   h  h   w
# These don't make much sense
# My phone number and two composite call-response melodies are:
# 4     7      9      3     0
# D#:G, D#:G#, F#:G#, F#:F, E:A#
# 6     8     4     8     4
# F#:G, E:G#, D#:G, E:G#, D#:G
# The "call" can be the lower frequencies, and the response the higher
# G,  G#, G,  F, A#
# F#, E,  D#, E, D#
# Next we ought to shift it to fit the key better.
# G, A, G, F, A#
# F, E, D, E, D
# Finally I'll put the response in reverse so it ends on the tonic
# G, A, G, F, A#
# D, E, D, E, F
in_thread do
  use_synth :pretty_bell
  call = [:G4, :A4, :G4, :F4, :As4]
  response = [:D5, :E5, :D5, :E5, :F5]
  # Give the chords some time to percolate
  sleep ii_length/2
  # Play the call and then response for the rest of section ii
  l = (ii_length/2)/10
  play_pattern_timed call, [l, l, l, l, l]
  play_pattern_timed response, [l, l, l, l, l]
  plays = 20
  pause = (piece_length-ii_length)/plays
  (plays - 3).times do
    len = rrand(1, 2).clamp(pause/5)
    
    if one_in(2)
      play_pattern_timed call, 5.times.map {len}
    else
      play_pattern_timed response, 5.times.map {len}
    end
    sleep pause-(len*5)
  end
end
