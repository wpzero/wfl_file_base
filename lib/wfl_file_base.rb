require "wfl_file_base/version"

module WflFileBase

	class << self
		attr_reader :config
		def configure
			@config = WflFileBaseConfig.instance
			yield(@config) if block_given?
		end
	end


	class WflFileBaseConfig
		attr_accessor :root, :tmp_dir
		include Singleton
	end
end

require "wfl_file_base/file"
require "wfl_file_base/file_base"
require "wfl_file_base/record"
