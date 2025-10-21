# frozen_string_literal: true

class ApplicationService
  def self.call(*)
    new(*).call
  end

  def call
    # raise NoMethodError
    raise NotImplementedError,
          "#{self.class} has not implemented method '#{__method__}'"
  end
end
