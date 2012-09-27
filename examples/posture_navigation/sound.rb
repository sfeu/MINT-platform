require 'sdl'

module Sound

  def Sound.init
    SDL::init(SDL::INIT_AUDIO)
    SDL::Mixer.open(22050, SDL::Mixer::DEFAULT_FORMAT, 2, 512)
    @zoom = SDL::Mixer::Wave.load(File.join(File.dirname(__FILE__), "sounds", "click1.wav"))
    @click2 = SDL::Mixer::Wave.load(File.join(File.dirname(__FILE__), "sounds","click.wav"))
    @plop = SDL::Mixer::Wave.load(File.join(File.dirname(__FILE__), "sounds","plop.wav"))
    @windup = SDL::Mixer::Wave.load(File.join(File.dirname(__FILE__), "sounds","windup.wav"))
  end

  def Sound.play_click
    # STDOUT.puts " in play"
    SDL::Mixer.play_channel(0, @zoom, 0)
  end

  def Sound.play_click2
    # STDOUT.puts " in play"
    SDL::Mixer.play_channel(0, @click2, 0)
  end

  def Sound.play_plop
    SDL::Mixer.play_channel(0, @plop, 0)
  end

  def Sound.play_windup
    SDL::Mixer.play_channel(0, @windup, 0)
  end

end



