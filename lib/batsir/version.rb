module Batsir
  module Version
    MAJOR = 0
    MINOR = 3
    PATCH = 7
    BUILD = 1
  end

  VERSION = [Version::MAJOR, Version::MINOR, Version::PATCH, Version::BUILD].compact.join('.')
end
