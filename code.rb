# Piece length in seconds
piece_length = 30*6
# piece_length = 60 # For testing purposes
ii_length = piece_length*(1/3)
V_length  = piece_length*(1/6)
I_length  = piece_length*(2/6)
# base_iterations = 2
base_iterations = 4
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
    sleep ii_length
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
      play curr, attack: pattack(length, iterations), sustain: psustain(length, iterations), release: prelease(length, iterations)
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
